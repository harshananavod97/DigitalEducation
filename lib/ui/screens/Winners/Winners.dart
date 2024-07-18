import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutterquiz/ui/controller/Winners.dart';
import 'package:flutterquiz/ui/model/Winner.dart';
import 'package:flutterquiz/ui/provider/advancedlevel.dart';
import 'package:flutterquiz/ui/screens/Winners/HowToWin.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

class Winners extends StatefulWidget {
  const Winners({super.key});

  @override
  State<Winners> createState() => _WinnersState();
}

class _WinnersState extends State<Winners> {
  bool isplaying = true;
  final controller = ConfettiController();

  @override
  void initState() {
    // TODO: implement initSta
    // conte

    controller.play();
    super.initState();
  }

  Widget rankCircle(String text, {double size = 25}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: colorScheme.background,
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final onTertiary = Theme.of(context).colorScheme.onTertiary;

    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HowTOWin_Screen(),
              ));
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(
                colors: [
                  const Color(0xff007FFF),
                  Theme.of(context).primaryColor.withOpacity(1.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1.0],
              ),
            ),
            height: 40,
            width: double.infinity,
            child: const Center(
                child: Text(
              "How To Win",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            )),
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/bgImage.png'), // Change this to your image path
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<PlayMartProvider>(
                builder: (context, value, child) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: WinnerController().getItems("123"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator()); // Show a loading indicator
                      }

                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Text('Error: ${snapshot.error}');
                      }

                      List<WinnersModel> _list = snapshot.data!.docs
                          .map((doc) => WinnersModel.fromJson(
                              doc.data() as Map<String, dynamic>))
                          .toList();

                      return ListView.builder(
                        itemCount: _list[0].Winner_Names.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _list[0].Month_Name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeights.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ConfettiWidget(
                                  confettiController: controller,
                                  shouldLoop: true,
                                  numberOfParticles: 20,
                                  blastDirection: 0.2,
                                  child: Container(
                                    height: width / 2.4,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xff007FFF),
                                          Theme.of(context)
                                              .primaryColor
                                              .withOpacity(1.0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: [0.1, 1.0],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: SizedBox(
                                              height: width * .224,
                                              width: width * .21,
                                              child: Stack(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Container(
                                                      height: width * .21,
                                                      width: width * .21,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              3),
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 2),
                                                      ),
                                                      child: QImage.circular(
                                                        imageUrl: _list[0]
                                                            .Winners_Profile_Image[
                                                                index]
                                                            .toString(),
                                                        width: double.maxFinite,
                                                        height:
                                                            double.maxFinite,
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    child: rankCircle(
                                                        (index + 1).toString()),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Flexible(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _list[0]
                                                      .Winner_Names[index]
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 25,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),

                                                UiUtils.getCurrentQuestionLanguageId(
                                                            context) ==
                                                        "57"
                                                    ? Text(
                                                        _list[0]
                                                            .Winner_Description_Sinhala[
                                                                index]
                                                            .toString()
                                                            .replaceAll(
                                                                r'\n', '\n'),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 10,
                                                        ),
                                                        maxLines:
                                                            10, // Set the maximum number of lines to show
                                                        overflow: TextOverflow
                                                            .ellipsis, // Handle overflow with ellipsis
                                                        textAlign:
                                                            TextAlign.justify,
                                                      )
                                                    : UiUtils.getCurrentQuestionLanguageId(
                                                                context) ==
                                                            "14"
                                                        ? Text(
                                                            _list[0]
                                                                .Winner_Description_English[
                                                                    index]
                                                                .toString()
                                                                .replaceAll(
                                                                    r'\n',
                                                                    '\n'),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 10,
                                                            ),
                                                            maxLines:
                                                                10, // Set the maximum number of lines to show
                                                            overflow: TextOverflow
                                                                .ellipsis, // Handle overflow with ellipsis
                                                            textAlign: TextAlign
                                                                .justify,
                                                          )
                                                        : Text(
                                                            _list[0]
                                                                .Winner_Description_Tamil[
                                                                    index]
                                                                .toString()
                                                                .replaceAll(
                                                                    r'\n',
                                                                    '\n'),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 10,
                                                            ),
                                                            maxLines:
                                                                10, // Set the maximum number of lines to show
                                                            overflow: TextOverflow
                                                                .ellipsis, // Handle overflow with ellipsis
                                                            textAlign: TextAlign
                                                                .justify,
                                                          )

                                                // Padding(
                                                //   padding:
                                                //       const EdgeInsets.all(8.0),
                                                //   child: Text(
                                                //     _list[0]
                                                //         .Winner_Description_Sinhala[
                                                //             index]
                                                //         .toString(),
                                                //     style: TextStyle(
                                                //       color: Colors.white,
                                                //       fontWeight:
                                                //           FontWeight.w700,
                                                //       fontSize: 10,
                                                //     ),
                                                //     maxLines:
                                                //         10, // Set the maximum number of lines to show
                                                //     overflow: TextOverflow
                                                //         .ellipsis, // Handle overflow with ellipsis
                                                //     textAlign:
                                                //         TextAlign.justify,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
