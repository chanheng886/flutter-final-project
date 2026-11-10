class OcrResultModel {
  final String id;
  final String documentId;
  final String rawText;
  final String? aiCorrectedText;
  final String? boundingBox;
  final double confidenceScore;
  final String? engineUsed;
  final int? ocrLatencyMs;

  const OcrResultModel({
    required this.id,
    required this.documentId,
    required this.rawText,
    this.aiCorrectedText,
    this.boundingBox,
    required this.confidenceScore,
    this.engineUsed,
    this.ocrLatencyMs,
  });

  String get displayText =>
      (aiCorrectedText != null && aiCorrectedText!.trim().isNotEmpty)
          ? aiCorrectedText!
          : rawText;

  factory OcrResultModel.fromJson(Map<String, dynamic> json) {
    return OcrResultModel(
      id: (json['id'] ?? '').toString(),
      documentId: (json['documentId'] ?? '').toString(),
      rawText: (json['rawText'] ?? '').toString(),
      aiCorrectedText: json['aiCorrectedText']?.toString(),
      boundingBox: json['boundingBox']?.toString(),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      engineUsed: json['engineUsed']?.toString(),
      ocrLatencyMs: (json['ocrLatencyMs'] as num?)?.toInt(),
    );
  }
}

