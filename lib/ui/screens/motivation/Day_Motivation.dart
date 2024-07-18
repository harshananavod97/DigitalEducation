import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';

import 'package:flutterquiz/ui/controller/StudyTips.dart';
import 'package:flutterquiz/ui/controller/OL%20Controllers/OL_Cathollic.dart';
import 'package:flutterquiz/ui/model/Al_Model.dart';
import 'package:flutterquiz/ui/model/Motivation_Model.dart';
import 'package:flutterquiz/ui/provider/advancedlevel.dart';
import 'package:flutterquiz/ui/screens/home/Advanced_Level_Screens/Subjects/Accounting/Accounting_Note_AL.dart';
import 'package:flutterquiz/ui/widgets/PdfViewPage.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controller/Day_mot.dart';

class DayMotivation extends StatefulWidget {
  const DayMotivation({super.key});

  @override
  State<DayMotivation> createState() => _DayMotivationState();
}

class _DayMotivationState extends State<DayMotivation> {
  Future<void> showrewardadd(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int clickCount = (prefs.getInt('clickCount') ?? 0) + 1;

    if (clickCount >= 10) {
      await context.read<RewardedAdCubit>().showDailyAd(context: context);
      clickCount = 0; // Reset the counter after showing the ad
    }

    await prefs.setInt('clickCount', clickCount);
  }

  @override
  void initState() {
    showrewardadd(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Week Motivation',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeights.bold,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: Consumer<PlayMartProvider>(
                    builder: (context, value, child) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: DayMotivationController().getItems("123"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            ); // Show a loading indicator
                          }

                          if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return Text('Error: ${snapshot.error}');
                          }

                          List<MotivationModel> _list = snapshot.data!.docs
                              .map((doc) => MotivationModel.fromJson(
                                  doc.data() as Map<String, dynamic>))
                              .toList();

                          return ListView.builder(
                            itemCount:
                                UiUtils.getCurrentQuestionLanguageId(context) ==
                                        "57"
                                    ? _list[0].Sinhala_Motivation.length
                                    : UiUtils.getCurrentQuestionLanguageId(
                                                context) ==
                                            "14"
                                        ? _list[0].English_Motivation.length
                                        : _list[0].Tamil_Motivation.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: UiUtils.getCurrentQuestionLanguageId(
                                              context) ==
                                          "57"
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            index == 0
                                                ? Center(
                                                    child: Image.network(
                                                      _list[0]
                                                          .Simage, // Replace with your image URL
                                                      height:
                                                          180.0, // Adjust the height as needed
                                                      width:
                                                          180.0, // Adjust the width as needed
                                                      fit: BoxFit.contain,
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Container();
                                                      },
                                                    ),
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              _list[0]
                                                  .Sinhala_Motivation[0]
                                                  .toString()
                                                  .replaceAll(r'\n', '\n'),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.62),
                                            ),
                                          ],
                                        )
                                      : UiUtils.getCurrentQuestionLanguageId(
                                                  context) ==
                                              "14"
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                index == 0
                                                    ? Center(
                                                        child: Image.network(
                                                          _list[0]
                                                              .Eimage, // Replace with your image URL
                                                          height:
                                                              180.0, // Adjust the height as needed
                                                          width:
                                                              180.0, // Adjust the width as needed
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return Container();
                                                          },
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  _list[0]
                                                      .English_Motivation[0]
                                                      .toString()
                                                      .replaceAll(r'\n', '\n'),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.62),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                index == 0
                                                    ? Center(
                                                        child: Image.network(
                                                          _list[0]
                                                              .Timage, // Replace with your image URL
                                                          height:
                                                              180.0, // Adjust the height as needed
                                                          width:
                                                              180.0, // Adjust the width as needed
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return Container();
                                                          },
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  _list[0]
                                                      .Tamil_Motivation[0]
                                                      .toString()
                                                      .replaceAll(r'\n', '\n'),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      height: 1.62),
                                                ),
                                              ],
                                            ));
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
          ),
        ],
      ),
    );
  }
}
