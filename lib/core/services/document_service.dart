import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:folio/core/models/document.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DocumentService {
  DocumentService(this._prefs);

  final SharedPreferences _prefs;
  static const _recentKey = 'recent_documents';
  static const _maxRecent = 50;

  static const _supportedExtensions = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'];

  Future<Document?> pickDocument() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _supportedExtensions,
      withData: false,
      withReadStream: false,
    );

    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.path == null) return null;

    final ext = file.extension ?? '';
    final fileInfo = File(file.path!);
    final size = fileInfo.existsSync() ? fileInfo.lengthSync() : null;

    final doc = Document(
      id: const Uuid().v4(),
      name: file.name,
      path: file.path!,
      type: DocumentTypeX.fromExtension(ext),
      lastOpened: DateTime.now(),
      fileSize: size,
    );

    await saveRecent(doc);
    return doc;
  }

  Future<void> saveRecent(Document doc) async {
    final current = loadRecent();
    final updated = [
      doc,
      ...current.where((d) => d.path != doc.path),
    ].take(_maxRecent).toList();

    final encoded = jsonEncode(updated.map((d) => d.toJson()).toList());
    await _prefs.setString(_recentKey, encoded);
  }

  Future<void> removeRecent(String documentId) async {
    final current = loadRecent();
    final updated = current.where((d) => d.id != documentId).toList();
    final encoded = jsonEncode(updated.map((d) => d.toJson()).toList());
    await _prefs.setString(_recentKey, encoded);
  }

  Future<void> clearRecent() async {
    await _prefs.remove(_recentKey);
  }

  List<Document> loadRecent() {
    final raw = _prefs.getString(_recentKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
