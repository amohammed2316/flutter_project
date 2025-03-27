import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/pdf_helper.dart';
import '../utils/email_validator.dart';
import '../widgets/custom_text_field.dart';

class FormScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const FormScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<void> _downloadPDF() async {
    if (_formKey.currentState!.validate()) {
      await generateAndDownloadPDF(
        context,
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _messageController.text,
      );
    }
  }

  Future<void> _sharePDF() async {
    if (_formKey.currentState!.validate()) {
      if (kIsWeb) {
        // Web: Get the bytes and share via Web API (if applicable)
        Uint8List pdfBytes = await generatePDFBytes(
          _nameController.text,
          _emailController.text,
          _phoneController.text,
          _messageController.text,
        );

        final XFile file = XFile.fromData(
          pdfBytes,
          mimeType: 'application/pdf',
          name: 'form_details.pdf',
        );

        await Share.shareXFiles([file], text: 'Here is the generated PDF.');
      } else {
        // Mobile/Desktop: Save to file and share
        String? filePath = await generatePDF(
          _nameController.text,
          _emailController.text,
          _phoneController.text,
          _messageController.text,
        );
        if (filePath != null) {
          await Share.shareXFiles([XFile(filePath)], text: 'Here is the generated PDF.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fill the Form")),
      body: Center(
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(controller: _nameController, label: "Name", validator: (value) => value!.isEmpty ? "Please enter your name" : null),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _emailController,
                    label: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => isValidEmail(value!) ? null : "Please enter a valid email",
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _phoneController,
                    label: "Phone",
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? "Please enter your phone number" : null,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _messageController,
                    label: "Message",
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? "Please enter a message" : null,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _downloadPDF,
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                      ),
                      ElevatedButton.icon(
                        onPressed: _sharePDF,
                        icon: const Icon(Icons.share),
                        label: const Text("Share"),
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

