class FolderModel {
  final String id;
  final String? userId;
  final String folderName;
  final int docCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FolderModel({
    required this.id,
    this.userId,
    required this.folderName,
    required this.docCount,
    this.createdAt,
    this.updatedAt,
  });

  FolderModel copyWith({
    String? folderName,
    int? docCount,
  }) {
    return FolderModel(
      id: id,
      userId: userId,
      folderName: folderName ?? this.folderName,
      docCount: docCount ?? this.docCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: (json['id'] ?? '').toString(),
      userId: json['userId']?.toString(),
      folderName: (json['folderName'] ?? 'Untitled').toString(),
      docCount: (json['docCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}

