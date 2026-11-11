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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
    private static final Logger log = LoggerFactory.getLogger(OcrResultServiceImpl.class);

    private final OcrResultRepository ocrResultRepository;
    private final OcrResultMapper ocrResultMapper;
    private final DocumentRepository documentRepository;
    private final ObjectMapper objectMapper;
    private final StorageService storageService;

    // Tesseract native library is not thread-safe: synchronize all native calls
    private static final Object TESS_LOCK = new Object();

    @Value("${app.ocr.tessdata-path}")
    private String configuredTessdataPath;

    @Transactional
    @Override
    public OcrResultResponseDto scan(UUID userId, UUID docId) {
        Document doc = findOwnDocument(userId, docId);
        if (doc.getDeletedAt() != null) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Document is in trashed");
        }

        File imageFile = storageService.load(doc.getImagePath()).toFile();
        if (!imageFile.exists() || imageFile.length() == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Document image file not found on disk");
        }

        String tessPath = resolveTessdataPath();
        String lang = toTessLang(doc.getLanguage());
        log.info("Starting OCR scan for docId={} using tessdata={} and lang={}", docId, tessPath, lang);

        long start = System.nanoTime();
        String text;
        List<Word> words = List.of();

        synchronized (TESS_LOCK) {
            Tesseract tesseract = new Tesseract();
            tesseract.setDatapath(tessPath);
            tesseract.setLanguage(lang);

            try {
                // OCR via File directly: Leptonica decodes images natively with zero Java ImageIO issues
                text = tesseract.doOCR(imageFile);

                // Word-level bounding boxes (optional - gracefully fallback to empty if decode fails)
                try {
                    BufferedImage img = readSafe(imageFile);
                    if (img != null) {
                        words = tesseract.getWords(img, ITessAPI.TessPageIteratorLevel.RIL_WORD);
                    }
                } catch (Throwable t) {
                    log.warn("Bounding box calculation skipped: {}", t.getMessage());
                }
            } catch (TesseractException e) {
                log.error("Tesseract scan failed: {}", e.getMessage(), e);
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
     * Dynamically finds the valid tessdata directory containing .traineddata files.
     * Searches configured path, environment variable, and standard Linux / Docker paths.
     */
    private String resolveTessdataPath() {
        String envPrefix = System.getenv("TESSDATA_PREFIX");
        List<String> candidates = new ArrayList<>();
        if (envPrefix != null && !envPrefix.isBlank()) {
            candidates.add(envPrefix);
        }
        if (configuredTessdataPath != null && !configuredTessdataPath.isBlank()) {
            candidates.add(configuredTessdataPath);
        }
        // Standard Linux paths across Ubuntu 20.04, 22.04 (Jammy/Docker), 24.04, Debian
        candidates.add("/usr/share/tesseract-ocr/4.00/tessdata");
        candidates.add("/usr/share/tesseract-ocr/5/tessdata");
        candidates.add("/usr/share/tessdata");
        candidates.add("/usr/local/share/tessdata");

        for (String path : candidates) {
            File dir = new File(path);
            if (dir.exists() && dir.isDirectory()) {
                File khm = new File(dir, "khm.traineddata");
                File eng = new File(dir, "eng.traineddata");
                if (khm.exists() || eng.exists()) {
                    return dir.getAbsolutePath();
                }
            }
        }
        return configuredTessdataPath != null ? configuredTessdataPath : "/usr/share/tessdata";
    }

    private BufferedImage readSafe(File imageFile) {
        try {
            BufferedImage src = ImageIO.read(imageFile);
            if (src == null) return null;

            if (src.getType() == BufferedImage.TYPE_INT_RGB) return src;

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
        } catch (Throwable e) {
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
