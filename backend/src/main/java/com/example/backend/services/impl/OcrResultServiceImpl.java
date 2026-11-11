package com.example.backend.services.impl;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.awt.Rectangle;
import javax.imageio.ImageIO;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.example.backend.dtos.responses.OcrResultResponseDto;
import com.example.backend.entities.Document;
import com.example.backend.entities.OcrResult;
import com.example.backend.mappers.OcrResultMapper;
import com.example.backend.repositories.DocumentRepository;
import com.example.backend.repositories.OcrResultRepository;
import com.example.backend.services.OcrResultService;
import com.example.backend.services.StorageService;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import net.sourceforge.tess4j.ITessAPI;
import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import net.sourceforge.tess4j.Word;

@Service
@RequiredArgsConstructor
public class OcrResultServiceImpl implements OcrResultService {
    private final OcrResultRepository ocrResultRepository;
    private final OcrResultMapper ocrResultMapper;
    private final DocumentRepository documentRepository;
    private final ObjectMapper objectMapper;
    private final StorageService storageService;

    // Tesseract is NOT thread-safe — all native calls must be serialised
    private static final Object TESS_LOCK = new Object();

    @Value("${app.ocr.tessdata-path}")
    private String tessdatePath;

    @Transactional
    @Override
    public OcrResultResponseDto scan(UUID userId, UUID docId) {
        Document doc = findOwnDocument(userId, docId);
        if (doc.getDeletedAt() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Document is in trashed");
        }

        File imageFile = storageService.load(doc.getImagePath()).toFile();

        long start = System.nanoTime();
        String text;
        List<Word> words;

        synchronized (TESS_LOCK) {
            Tesseract tesseract = new Tesseract();
            tesseract.setDatapath(tessdatePath);
            tesseract.setLanguage(toTessLang(doc.getLanguage()));

            try {
                // Use File overload — Tesseract's leptonica library handles JPEG,
                // PNG, TIFF, WebP and CMYK natively, bypassing Java ImageIO limits.
                text = tesseract.doOCR(imageFile);

                // Try to get word-level bounding boxes via BufferedImage.
                // If ImageIO can't decode the format (e.g. CMYK JPEG), gracefully
                // fall back to an empty list so OCR text is still returned.
                BufferedImage img = readSafe(imageFile);
                if (img != null) {
                    words = tesseract.getWords(img, ITessAPI.TessPageIteratorLevel.RIL_WORD);
                } else {
                    words = List.of();
                }
            } catch (TesseractException e) {
                throw new ResponseStatusException(
                        HttpStatus.INTERNAL_SERVER_ERROR, "OCR failed: " + e.getMessage(), e);
            }
        }

        int latencyMs = (int) ((System.nanoTime() - start) / 1_000_000);
        double confidence = words.stream()
                .mapToDouble(Word::getConfidence)
                .average()
                .orElse(0);

        OcrResult result = ocrResultRepository
                .findByDocumentIdAndDocumentFolderUserId(docId, userId)
                .orElseGet(OcrResult::new);
        result.setDocument(doc);
        result.setRawText(text == null ? "" : text.trim());
        result.setAiCorrectedText(null);
        result.setBoundingBox(toBoundingBoxJson(words));
        result.setConfidenceScore(confidence);
        result.setEngineUsed("tesseract");
        result.setOcrLatencyMs(latencyMs);
        ocrResultRepository.save(result);
        doc.setContent(result.getRawText());
        return ocrResultMapper.toResponse(result);
    }

    @Transactional(readOnly = true)
    @Override
    public OcrResultResponseDto get(UUID userId, UUID docId) {
        OcrResult ocrResult = ocrResultRepository
                .findByDocumentIdAndDocumentFolderUserId(docId, userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "OCR Result not found!"));
        return ocrResultMapper.toResponse(ocrResult);
    }

    // ── helpers ────────────────────────────────────────────────────────────────

    /**
     * Tries to read the image with ImageIO and normalise it to plain RGB.
     * Returns {@code null} (never throws) if the format is unsupported —
     * callers should handle the null case gracefully.
     */
    private BufferedImage readSafe(File imageFile) {
        try {
            BufferedImage src = ImageIO.read(imageFile);
            if (src == null) return null;

            // Already plain RGB — no conversion needed
            if (src.getType() == BufferedImage.TYPE_INT_RGB) return src;

            // Redraw on a fresh RGB canvas (handles alpha, indexed, 16-bit, etc.)
            BufferedImage rgb = new BufferedImage(
                    src.getWidth(), src.getHeight(), BufferedImage.TYPE_INT_RGB);
            Graphics2D g = rgb.createGraphics();
            g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,
                    RenderingHints.VALUE_INTERPOLATION_BICUBIC);
            g.setColor(java.awt.Color.WHITE);
            g.fillRect(0, 0, src.getWidth(), src.getHeight());
            g.drawImage(src, 0, 0, null);
            g.dispose();
            return rgb;
        } catch (IOException e) {
            return null;
        }
    }

    private Document findOwnDocument(UUID userId, UUID docId) {
        return documentRepository.findByIdAndFolderUserId(docId, userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Document is not found!"));
    }

    private String toTessLang(String language) {
        return switch (language) {
            case "km" -> "khm";
            case "en" -> "eng";
            case "km+en" -> "khm+eng";
            default -> throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST, "Unsupported language");
        };
    }

    private String toBoundingBoxJson(List<Word> words) {
        List<Map<String, Object>> items = new ArrayList<>();
        for (Word w : words) {
            Rectangle box = w.getBoundingBox();
            items.add(Map.of(
                    "text", Objects.toString(w.getText(), ""),
                    "confidence", w.getConfidence(),
                    "x", box.x,
                    "y", box.y,
                    "width", box.width,
                    "height", box.height));
        }
        try {
            return objectMapper.writeValueAsString(items);
        } catch (JsonProcessingException e) {
            throw new IllegalStateException("Could not build bounding box JSON", e);
        }
    }
}
