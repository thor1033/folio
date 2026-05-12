import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:folio/core/theme/app_colors.dart';

enum DocumentType { pdf, docx, pptx, xlsx, other }

extension DocumentTypeX on DocumentType {
  String get label => switch (this) {
        DocumentType.pdf => 'PDF',
        DocumentType.docx => 'DOCX',
        DocumentType.pptx => 'PPTX',
        DocumentType.xlsx => 'XLSX',
        DocumentType.other => 'FILE',
      };

  Color get color => switch (this) {
        DocumentType.pdf => AppColors.pdfColor,
        DocumentType.docx => AppColors.docxColor,
        DocumentType.pptx => AppColors.pptxColor,
        DocumentType.xlsx => AppColors.xlsxColor,
        DocumentType.other => AppColors.darkTextTertiary,
      };

  IconData get icon => switch (this) {
        DocumentType.pdf => Icons.picture_as_pdf_outlined,
        DocumentType.docx => Icons.article_outlined,
        DocumentType.pptx => Icons.slideshow_outlined,
        DocumentType.xlsx => Icons.table_chart_outlined,
        DocumentType.other => Icons.insert_drive_file_outlined,
      };

  static DocumentType fromExtension(String ext) => switch (ext.toLowerCase()) {
        'pdf' => DocumentType.pdf,
        'doc' || 'docx' => DocumentType.docx,
        'ppt' || 'pptx' => DocumentType.pptx,
        'xls' || 'xlsx' => DocumentType.xlsx,
        _ => DocumentType.other,
      };
}

class Document extends Equatable {
  const Document({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.lastOpened,
    this.fileSize,
    this.totalPages,
  });

  final String id;
  final String name;
  final String path;
  final DocumentType type;
  final DateTime lastOpened;
  final int? fileSize;
  final int? totalPages;

  String get displaySize {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  Document copyWith({
    String? id,
    String? name,
    String? path,
    DocumentType? type,
    DateTime? lastOpened,
    int? fileSize,
    int? totalPages,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      type: type ?? this.type,
      lastOpened: lastOpened ?? this.lastOpened,
      fileSize: fileSize ?? this.fileSize,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'path': path,
        'type': type.name,
        'lastOpened': lastOpened.toIso8601String(),
        'fileSize': fileSize,
        'totalPages': totalPages,
      };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        id: json['id'] as String,
        name: json['name'] as String,
        path: json['path'] as String,
        type: DocumentType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => DocumentType.other,
        ),
        lastOpened: DateTime.parse(json['lastOpened'] as String),
        fileSize: json['fileSize'] as int?,
        totalPages: json['totalPages'] as int?,
      );

  @override
  List<Object?> get props =>
      [id, name, path, type, lastOpened, fileSize, totalPages];
}
