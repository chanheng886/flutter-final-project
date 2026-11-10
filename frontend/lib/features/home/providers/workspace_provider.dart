import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/home/models/document_model.dart';
import 'package:frontend/features/home/models/folder_model.dart';
import 'package:frontend/features/home/models/ocr_result_model.dart';

class WorkspaceProvider extends ChangeNotifier {
  final ApiClient _api;

  WorkspaceProvider(this._api);

  List<FolderModel> folders = [];
  List<DocumentModel> recentDocuments = [];
  List<FolderModel> trashedFolders = [];
  List<DocumentModel> trashedDocuments = [];
  bool loading = false;
  String? error;

  List<Map<String, dynamic>> _extractPageContent(dynamic res) {
    if (res is Map && res['content'] is List) {
      return (res['content'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<void> loadDashboard() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final folderRes = await _api.get('/folder?size=100&sort=createdAt,desc');
      folders = _extractPageContent(folderRes)
          .map(FolderModel.fromJson)
          .toList();
    } on ApiException catch (e) {
      error = e.message;
    } catch (e) {
      error = e.toString();
    }

    try {
      final docRes = await _api.get('/documents?size=50&sort=createdAt,desc');
      recentDocuments = _extractPageContent(docRes)
          .map(DocumentModel.fromJson)
          .toList();
    } catch (_) {
      // Ignore if /documents endpoint is not yet reloaded on backend
    }

    loading = false;
    notifyListeners();
  }

  Future<FolderModel?> createFolder(String folderName) async {
    error = null;
    try {
      final res = await _api.post('/folder', {'folderName': folderName.trim()});
      final created = FolderModel.fromJson(
        Map<String, dynamic>.from(res as Map),
      );
      folders = [created, ...folders];
      notifyListeners();
      return created;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> renameFolder(String folderId, String folderName) async {
    error = null;
    try {
      final res = await _api.patch('/folder/$folderId', {
        'folderName': folderName.trim(),
      });
      final updated = FolderModel.fromJson(
        Map<String, dynamic>.from(res as Map),
      );
      folders = [
        for (final f in folders)
          if (f.id == folderId) updated else f,
      ];
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> moveFolderToTrash(String folderId) async {
    error = null;
    try {
      await _api.delete('/folder/$folderId/trash');
      folders = folders.where((f) => f.id != folderId).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _updateLocalFolderCount(String folderId, int newCount) {
    bool changed = false;
    folders = [
      for (final f in folders)
        if (f.id == folderId)
          () {
            if (f.docCount != newCount) changed = true;
            return f.copyWith(docCount: newCount);
          }()
        else
          f,
    ];
    if (changed) notifyListeners();
  }

  Future<List<DocumentModel>> fetchRecentDocuments({int size = 50}) async {
    try {
      final docRes =
          await _api.get('/documents?size=$size&sort=createdAt,desc');
      recentDocuments = _extractPageContent(docRes)
          .map(DocumentModel.fromJson)
          .toList();
      notifyListeners();
      return recentDocuments;
    } catch (_) {
      return recentDocuments;
    }
  }

  Future<List<DocumentModel>> fetchDocumentsInFolder(String folderId) async {
    final res = await _api.get(
      '/documents/folders/$folderId?size=100&sort=createdAt,desc',
    );
    final docs = _extractPageContent(res).map(DocumentModel.fromJson).toList();
    _updateLocalFolderCount(folderId, docs.length);
    return docs;
  }

  Future<DocumentModel?> uploadDocument({
    required String folderId,
    required String filePath,
    required String docName,
    String language = 'km',
  }) async {
    final res = await _api.postMultipart(
      '/documents/folders/$folderId',
      filePath: filePath,
      fields: {'docName': docName.trim(), 'language': language},
    );
    final doc = DocumentModel.fromJson(Map<String, dynamic>.from(res as Map));
    folders = [
      for (final f in folders)
        if (f.id == folderId) f.copyWith(docCount: f.docCount + 1) else f,
    ];
    recentDocuments = [doc, ...recentDocuments];
    notifyListeners();
    await loadDashboard();
    return doc;
  }

  Future<DocumentModel?> renameDocument(String docId, String docName) async {
    final res = await _api.patch('/documents/$docId', {
      'docName': docName.trim(),
    });
    final doc = DocumentModel.fromJson(Map<String, dynamic>.from(res as Map));
    await loadDashboard();
    return doc;
  }

  Future<void> moveDocumentToTrash(String docId) async {
    await _api.post('/documents/$docId/trash', {});
    await loadDashboard();
  }

  Future<OcrResultModel> scanDocument(String docId) async {
    final res = await _api.post('/ocr_result/$docId/scan', {});
    final result = OcrResultModel.fromJson(
      Map<String, dynamic>.from(res as Map),
    );
    await loadDashboard();
    return result;
  }

  Future<OcrResultModel?> getOcrResult(String docId) async {
    try {
      final res = await _api.get('/ocr_result/$docId');
      return OcrResultModel.fromJson(Map<String, dynamic>.from(res as Map));
    } on ApiException {
      return null;
    }
  }

  Future<List<int>> exportDocxBytes(String docId) {
    return _api.getBytes('/ocr_result/$docId/export/docx');
  }

  Future<List<int>> exportPdfBytes(String docId) {
    return _api.getBytes('/ocr_result/$docId/export/pdf');
  }

  Future<List<FolderModel>> fetchTrashedFolders() async {
    try {
      final res = await _api.get('/folder/trash?size=100&sort=createdAt,desc');
      trashedFolders =
          _extractPageContent(res).map(FolderModel.fromJson).toList();
      notifyListeners();
      return trashedFolders;
    } catch (_) {
      return trashedFolders;
    }
  }

  Future<List<DocumentModel>> fetchTrashedDocuments() async {
    try {
      final res =
          await _api.get('/documents/trash?size=100&sort=createdAt,desc');
      trashedDocuments =
          _extractPageContent(res).map(DocumentModel.fromJson).toList();
      notifyListeners();
      return trashedDocuments;
    } catch (_) {
      return trashedDocuments;
    }
  }

  Future<bool> restoreFolder(String folderId) async {
    error = null;
    try {
      await _api.post('/folder/$folderId/restore', {});
      trashedFolders.removeWhere((f) => f.id == folderId);
      notifyListeners();
      await loadDashboard();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFolderForever(String folderId) async {
    error = null;
    try {
      await _api.post('/folder/$folderId', {});
      trashedFolders.removeWhere((f) => f.id == folderId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreDocument(String docId) async {
    error = null;
    try {
      await _api.post('/documents/$docId/restore', {});
      trashedDocuments.removeWhere((d) => d.id == docId);
      notifyListeners();
      await loadDashboard();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocumentForever(String docId) async {
    error = null;
    try {
      await _api.delete('/documents/$docId');
      trashedDocuments.removeWhere((d) => d.id == docId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
