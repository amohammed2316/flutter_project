import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:share_plus/share_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDF Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FormToPDF(),
    );
  }
}

class FormToPDF extends StatefulWidget {
  @override
  _FormToPDFState createState() => _FormToPDFState();
}

class _FormToPDFState extends State<FormToPDF> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<Uint8List> generatePDFBytes() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Form Details", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text("Name: ${_nameController.text}", style: pw.TextStyle(fontSize: 18)),
            pw.Text("Email: ${_emailController.text}", style: pw.TextStyle(fontSize: 18)),
            pw.Text("Phone: ${_phoneController.text}", style: pw.TextStyle(fontSize: 18)),
            pw.Text("Message: ${_messageController.text}", style: pw.TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> downloadPDF() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pdfBytes = await generatePDFBytes();

        if (kIsWeb) {
          final blob = html.Blob([pdfBytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)..setAttribute('download', 'form_details.pdf');
          anchor.click();
          html.Url.revokeObjectUrl(url);
        } else {
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/form_details.pdf';
          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("PDF downloaded to: $filePath")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download failed: $e")));
      }
    }
  }

  Future<void> sharePDF() async {
    if (_formKey.currentState!.validate()) {
      try {
        final pdfBytes = await generatePDFBytes();
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/form_details.pdf';
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        await Share.shareXFiles([XFile(filePath)], text: 'Here is the generated PDF.');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sharing failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Fill the Form")),
      body: Center(
        child: Card(
          elevation: 8,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                  ),
                  SizedBox(height: 12),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.contains('@') ? null : "Please enter a valid email",
                  ),
                  SizedBox(height: 12),

                  // Message Field
                  TextFormField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: "Message",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? "Please enter a message" : null,
                  ),
                  SizedBox(height: 20),

                  Divider(),

                  // Download and Share Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: downloadPDF,
                        icon: Icon(Icons.download),
                        label: Text("Download"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: sharePDF,
                        icon: Icon(Icons.share),
                        label: Text("Share"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

