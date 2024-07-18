import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/controller/Al_Science_Controller.dart';
import 'package:flutterquiz/ui/controller/OL%20Controllers/OL_BusinessAndAccounting.dart';
import 'package:flutterquiz/ui/model/Al_Model.dart';
import 'package:flutterquiz/ui/provider/advancedlevel.dart';
import 'package:flutterquiz/ui/screens/home/Advanced_Level_Screens/AL_Home_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Advanced_Level_Screens/Subjects/Accounting/Accounting_Home_Screen_AL.dart';
import 'package:flutterquiz/ui/widgets/PdfViewPage.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CommerceNoteOl extends StatefulWidget {
  String title;
  CommerceNoteOl({Key? key, required this.title}) : super(key: key);

  @override
  State<CommerceNoteOl> createState() => _ScienceNoteAlState();
}

class _ScienceNoteAlState extends State<CommerceNoteOl> {
  WebViewController? _controller;
  void webviewMethod(String url) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            _controller!.clearCache();
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeights.bold,
            color: Colors.black.withOpacity(0.7),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PlayMartProvider>(
              builder: (context, value, child) {
                return StreamBuilder<QuerySnapshot>(
                  stream: Ol_BusinessAndAccountingController().getItems("123"),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      ); // Show a loading indicator
                    }

                    if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    }

                    List<AlModel> _list = snapshot.data!.docs
                        .map((doc) => AlModel.fromJson(
                            doc.data() as Map<String, dynamic>))
                        .toList();

                    return ListView.builder(
                      itemCount:
                          UiUtils.getCurrentQuestionLanguageId(context) == "57"
                              ? _list[0].S_Note.length
                              : UiUtils.getCurrentQuestionLanguageId(context) ==
                                      "14"
                                  ? _list[0].E_Note.length
                                  : _list[0].T_Note.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: ItemView(
                            Imagename: 'viewpaper.png',
                            hzMargin: 20,
                            name: UiUtils.getCurrentQuestionLanguageId(
                                        context) ==
                                    "57"
                                ? _list[0].S_Note_Title[index].toString()
                                : UiUtils.getCurrentQuestionLanguageId(
                                            context) ==
                                        "14"
                                    ? _list[0].E_Note_Title[index].toString()
                                    : _list[0].T_Note_Title[index].toString(),
                            onpress: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>PdfViewScreen(url:UiUtils.getCurrentQuestionLanguageId(
                                              context) ==
                                          "57"
                                      ? _list[0].S_Note[index].toString()
                                      : UiUtils.getCurrentQuestionLanguageId(
                                                  context) ==
                                              "14"
                                          ? _list[0].E_Note[index].toString()
                                          : _list[0].T_Note[index].toString())));
                            },
                            scrHeight: 20,
                          ),
                        );
                        // Other widget properties...
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  const ItemView(
      {super.key,
      required this.hzMargin,
      required this.scrHeight,
      required this.name,
      required this.onpress,
      required this.Imagename});

  final double hzMargin;
  final double scrHeight;
  final String name;
  final VoidCallback onpress;
  final String Imagename;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpress,
      child: Padding(
        padding: EdgeInsets.only(
          left: hzMargin,
          right: hzMargin,
          top: scrHeight * 0.03,
        ),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10)),
          height: MediaQuery.of(context).size.width / 4.44,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/" + Imagename,
                        width: MediaQuery.of(context).size.width * 0.08,
                        height: MediaQuery.of(context).size.height * 0.08,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.08,
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeights.regular,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 3,
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
