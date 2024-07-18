import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewScreen extends StatefulWidget {
  final String url;
  PdfViewScreen({super.key, required this.url});

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.url,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to load document: ${details.error}';
              });
            },
          ),
          if (_isLoading)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    UiUtils.getCurrentQuestionLanguageId(context) == "57"
                        ? "මදක් රැදි සිටින්න ඔබේ ඉල්ලීම  සැකසෙමින් පවති...."
                        : UiUtils.getCurrentQuestionLanguageId(context) == "14"
                            ? "Please wait a moment, your request is being processed...."
                            : "சற்றே காத்திருக்கவும், உங்கள் கோரிக்கை செயலாக்கப்பட்டுக் கொண்டிருக்கிறது.....",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          if (!_isLoading && _errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  UiUtils.getCurrentQuestionLanguageId(context) == "57"
                      ? "දුවේ පුතේ ඔයාලා ගාව නොට් ,ප්‍රශ්න  ප්‍රත්‍ර තියේනවාම් පහත Email ලිපිනයට එවන්න ... තොරතුරු  වල විස්තරද ඇතුලත්ව\n\n\nසාමාන්‍ය  පෙළ නම්\n\n ol@digitaleducation.tech\n\n\nඋසස් පෙළ  නම්\n\nal@digitaleducation.tech \n\n\nමතක ඇතුව ඔයාගේ නම පාසලද අපිට එවන්න "
                      : UiUtils.getCurrentQuestionLanguageId(context) == "14"
                          ? "Dear  students,\n\nIf you have any papers or note send to us with information.\n\n For O\L \n\n ol@digitaleducation.tech\\n\nFor A\L  \n\n  al@digitaleducation.tech\n\nPlease send with your name and school information also"
                          : "Dear  students,\n\nIf you have any papers or note send to us with information.\n\n For O\L \n\n ol@digitaleducation.tech\\n\nFor A\L  \n\n  al@digitaleducation.tech\n\nPlease send with your name and school information also",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 20,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
