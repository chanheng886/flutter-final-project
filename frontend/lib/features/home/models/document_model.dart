class DocumentModel {
  final String id;
  final String folderId;
  final String docName;
  final String? content;
  final String language;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DocumentModel({
    required this.id,
    required this.folderId,
    required this.docName,
    this.content,
    required this.language,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: (json['id'] ?? '').toString(),
      folderId: (json['folderId'] ?? '').toString(),
      docName: (json['docName'] ?? 'Untitled').toString(),
      content: json['content']?.toString(),
      language: (json['language'] ?? 'km').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

