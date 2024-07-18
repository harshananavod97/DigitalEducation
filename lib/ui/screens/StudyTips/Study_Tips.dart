import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/ui/controller/StudyTips.dart';

import 'package:flutterquiz/ui/provider/advancedlevel.dart';
import 'package:flutterquiz/ui/screens/StudyTips/Study_Tips_View.dart';

import 'package:flutterquiz/ui/screens/home/MainHome.dart';

import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/StudyTipsModel.dart';

class StudyTips extends StatefulWidget {
  const StudyTips({super.key});

  @override
  State<StudyTips> createState() => _StudyTipsState();
}

class _StudyTipsState extends State<StudyTips> {
  double get scrWidth => MediaQuery.of(context).size.width;

  double get scrHeight => MediaQuery.of(context).size.height;
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  double get _statusBarPadding => MediaQuery.of(context).padding.top;

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
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/bgImage.png'), // Change this to your image path
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Study Tips',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeights.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Consumer<PlayMartProvider>(
                    builder: (context, value, child) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: StudyTipsController().getItems("123"),
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

                          List<StudyTipsModel> _list = snapshot.data!.docs
                              .map((doc) => StudyTipsModel.fromJson(
                                  doc.data() as Map<String, dynamic>))
                              .toList();

                          return ListView.builder(
                            itemCount:
                                UiUtils.getCurrentQuestionLanguageId(context) ==
                                        "57"
                                    ? _list[0].Sinhala_Title.length
                                    : UiUtils.getCurrentQuestionLanguageId(
                                                context) ==
                                            "14"
                                        ? _list[0].English_Title.length
                                        : _list[0].Tamil_Title.length,
                            itemBuilder: (context, index) {
                              return UiUtils.getCurrentQuestionLanguageId(
                                          context) ==
                                      "57"
                                  ? MainStreamContainer(
                                      hzMargin: hzMargin,
                                      scrHeight: scrHeight,
                                      name: _list[0]
                                          .Sinhala_Title[index]
                                          .toString(),
                                      onpress: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  studyTipsview(
                                                      Image: _list[0]
                                                          .Simage[index]
                                                          .toString(),
                                                      Description: _list[0]
                                                          .Sinhala_Tips[index]
                                                          .toString(),
                                                      headTitle: _list[0]
                                                          .Sinhala_Title[index]
                                                          .toString()),
                                            ));
                                      },
                                    )
                                  : UiUtils.getCurrentQuestionLanguageId(
                                              context) ==
                                          "14"
                                      ? MainStreamContainer(
                                          hzMargin: hzMargin,
                                          scrHeight: scrHeight,
                                          name: _list[0]
                                              .English_Title[index]
                                              .toString(),
                                          onpress: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      studyTipsview(
                                                          Image: _list[0]
                                                              .Eimage[index]
                                                              .toString(),
                                                          Description:
                                                              _list[0]
                                                                  .English_Tips[
                                                                      index]
                                                                  .toString(),
                                                          headTitle: _list[0]
                                                              .Sinhala_Title[
                                                                  index]
                                                              .toString()),
                                                ));
                                          },
                                        )
                                      : MainStreamContainer(
                                          hzMargin: hzMargin,
                                          scrHeight: scrHeight,
                                          name: _list[0]
                                              .Tamil_Title[index]
                                              .toString(),
                                          onpress: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      studyTipsview(
                                                          Image: _list[0]
                                                              .Timage[index]
                                                              .toString(),
                                                          Description: _list[0]
                                                              .Tamil_Tips[index]
                                                              .toString(),
                                                          headTitle: _list[0]
                                                              .Tamil_Title[
                                                                  index]
                                                              .toString()),
                                                ));
                                          },
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
          ),
        ],
      ),
    );
  }
}
