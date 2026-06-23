import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../constants/app_colors.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function() pdfBuilder;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.pdfBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppColors.dark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),
      body: PdfPreview(
        build: (format) => pdfBuilder(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
      ),
    );
  }
}
