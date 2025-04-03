import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;

// Generates a PDF and returns bytes (for Web)
Future<Uint8List> generatePDFBytes(String name, String email, String phone, String message) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text("Form Details", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Text("Name: $name", style: pw.TextStyle(fontSize: 18)),
          pw.Text("Email: $email", style: pw.TextStyle(fontSize: 18)),
          pw.Text("Phone: $phone", style: pw.TextStyle(fontSize: 18)),
          pw.Text("Message: $message", style: pw.TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );

  return pdf.save();
}

// Generates a PDF and saves it to a file (for Mobile/Desktop)
Future<String?> generatePDF(String name, String email, String phone, String message) async {
  final pdfBytes = await generatePDFBytes(name, email, phone, message);

  if (kIsWeb) return null; // No file system on Web

  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/form_details.pdf';
  final file = File(filePath);
  await file.writeAsBytes(pdfBytes);

  return filePath;
}

// Generates a PDF and triggers a download (for Web & Mobile)
Future<void> generateAndDownloadPDF(BuildContext context, String name, String email, String phone, String message) async {
  final pdfBytes = await generatePDFBytes(name, email, phone, message);

  if (kIsWeb) {
    final base64 = base64Encode(pdfBytes);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement..href='data:application/pdf;base64,$base64' ..download = 'form_details.pdf';
     web.document.body!.appendChild(anchor);
      anchor.click();
      web.document.body!.removeChild(anchor);
  } else {
    String? filePath = await generatePDF(name, email, phone, message);
    if (filePath != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF saved at: $filePath")));
    }
  }
}
