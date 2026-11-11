package com.example.backend.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

import java.util.List;
import java.util.Map;

/**
 * Calls Google Gemini (Generative Language API) to correct Khmer OCR text.
 * Falls back gracefully to the raw Tesseract output when the API key is
 * missing, the request fails, or the response is malformed.
 */
@Service
public class GeminiService {

    private static final Logger log = LoggerFactory.getLogger(GeminiService.class);

    private final RestClient restClient;
    private final String apiKey;
    private final String modelUrl;
    private final int timeoutMs;

    public GeminiService(
            @Value("${gemini.api.key}") String apiKey,
            @Value("${gemini.api.url:https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent}") String modelUrl,
            @Value("${gemini.api.timeout-ms:30000}") int timeoutMs
    ) {
        this.apiKey = apiKey;
        this.modelUrl = modelUrl;
        this.timeoutMs = timeoutMs;
        this.restClient = RestClient.builder()
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();
    }

    /**
     * Corrects the given raw Khmer OCR text using Gemini.
     * Returns the corrected text, or the original raw text on any failure.
     */
    public String correctKhmerText(String rawText) {
        if (rawText == null || rawText.isBlank()) {
            return rawText;
        }
        if (apiKey == null || apiKey.isBlank()) {
            log.warn("GEMINI_API_KEY is not set — skipping AI correction, using raw OCR text");
            return rawText;
        }

        String prompt = buildPrompt(rawText);

        Map<String, Object> body = Map.of(
                "contents", List.of(
                        Map.of("parts", List.of(
                                Map.of("text", prompt)
                        ))
                ),
                "generationConfig", Map.of(
                        "temperature", 0.1,
                        "maxOutputTokens", 4096
                ),
                "safetySettings", List.of(
                        Map.of("category", "HARM_DANGEROUS_CONTENT", "threshold", "BLOCK_NONE"),
                        Map.of("category", "HARM_HARASSMENT", "threshold", "BLOCK_NONE"),
                        Map.of("category", "HARM_HATE_SPEECH", "threshold", "BLOCK_NONE"),
                        Map.of("category", "HARM_SEXUALLY_EXPLICIT", "threshold", "BLOCK_NONE")
                )
        );

        String url = modelUrl + "?key=" + apiKey;

        try {
            String response = restClient.post()
                    .uri(url)
                    .body(body)
                    .retrieve()
                    .body(String.class);

            String corrected = extractText(response);
            if (corrected != null && !corrected.isBlank()) {
                log.info("Gemini AI correction applied (rawLen={}, correctedLen={})",
                        rawText.length(), corrected.length());
                return corrected.trim();
            }
            log.warn("Gemini returned empty content — using raw OCR text");
            return rawText;
        } catch (RestClientResponseException e) {
            log.error("Gemini API HTTP error status={} body={}", e.getRawStatusCode(), e.getResponseBodyAsString());
            return rawText;
        } catch (Exception e) {
            log.error("Gemini AI correction failed: {} — using raw OCR text", e.getMessage());
            return rawText;
        }
    }

    private String buildPrompt(String rawText) {
        return "Correct the following Khmer OCR text. " +
                "OCR errors include missing vowels, broken consonant clusters, wrong stacking, and missing spaces. " +
                "Fix them so the text reads naturally. " +
                "Do not translate. Do not explain. Do not quote the original. " +
                "Output ONLY the corrected Khmer text, nothing else.\n\n" +
                "Text to correct:\n" + rawText;
    }

    private String extractText(String response) {
        if (response == null || response.isBlank()) {
            return null;
        }
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> root = (Map<String, Object>) new com.fasterxml.jackson.databind.ObjectMapper()
                    .readValue(response, Map.class);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> candidates = (List<Map<String, Object>>) root.get("candidates");
            if (candidates == null || candidates.isEmpty()) {
                return null;
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> content = candidates.get(0);
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("content");
            if (parts == null || parts.isEmpty()) {
                return null;
            }
            StringBuilder sb = new StringBuilder();
            for (Map<String, Object> part : parts) {
                Object text = part.get("text");
                if (text != null) {
                    sb.append(text.toString());
                }
            }
            String result = sb.toString().trim();
            // Strip markdown code fences if present
            result = result.replaceAll("^```[a-zA-Z]*\\s*", "").replaceAll("\\s*```$", "").trim();
            // Remove empty lines left over
            return result.isBlank() ? null : result;
        } catch (Exception e) {
            log.warn("Failed to parse Gemini response: {}", e.getMessage());
            return null;
        }
    }

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }
}