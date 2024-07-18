import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/quiz/models/comprehension.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class FunAndLearnScreen extends StatefulWidget {
  const FunAndLearnScreen({
    required this.quizType,
    required this.comprehension,
    super.key,
  });

  final QuizTypes quizType;
  final Comprehension comprehension;

  @override
  State<FunAndLearnScreen> createState() => _FunAndLearnScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => FunAndLearnScreen(
        quizType: arguments!['quizType'] as QuizTypes,
        comprehension: arguments['comprehension'] as Comprehension,
      ),
    );
  }
}

class _FunAndLearnScreen extends State<FunAndLearnScreen>
    with TickerProviderStateMixin {
  final double topPartHeightPercentage = 0.275;
  final double userDetailsHeightPercentage = 0.115;

  void navigateToQuestionScreen() {
    Navigator.of(context).pushReplacementNamed(
      Routes.quiz,
      arguments: {
        'numberOfPlayer': 1,
        'quizType': QuizTypes.funAndLearn,
        'comprehension': widget.comprehension,
        'quizName': "Fun 'N'Learn",
      },
    );
  }

  Widget _buildStartButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 30,
        left: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        right: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      child: CustomRoundedButton(
        widthPercentage: MediaQuery.of(context).size.width,
        backgroundColor: Theme.of(context).primaryColor,
        buttonTitle: context.tr(letsStart),
        radius: 8,
        onTap: navigateToQuestionScreen,
        titleColor: Theme.of(context).colorScheme.surface,
        showBorder: false,
        height: 58,
        elevation: 5,
        textSize: 18,
        fontWeight: FontWeights.semiBold,
      ),
    );
  }

  Widget _buildParagraph() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      height: MediaQuery.of(context).size.height * .75,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: HtmlWidget(
          widget.comprehension.detail,
          onErrorBuilder: (_, e, err) => Text('$e error: $err'),
          onLoadingBuilder: (_, e, l) => const Center(
            child: CircularProgressIndicator(),
          ),
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontWeight: FontWeights.regular,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        roundedAppBar: false,
        title: Text(widget.comprehension.title),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildParagraph(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStartButton(),
          ),
        ],
      ),
    );
  }
}
