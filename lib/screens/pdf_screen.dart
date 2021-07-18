import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:tenancy/constant.dart';

class PdfReadScreen extends StatefulWidget {
  final String url;

  const PdfReadScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<PdfReadScreen> createState() => _PdfReadScreenState();
}

class _PdfReadScreenState extends State<PdfReadScreen> {
  bool _isLoading = false;
  PDFDocument? document;

  loadDocument() async {
    document = await PDFDocument.fromURL(widget.url);

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: app_color,
                  backgroundColor: Colors.white,
                ),
              )
            : PDFViewer(
                document: document!,
                zoomSteps: 1,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: app_color,
        onPressed: () => Navigator.pop(context),
        child: const Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
    );
  }
}
