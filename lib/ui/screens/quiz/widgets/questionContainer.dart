import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class QuestionContainer extends StatelessWidget {
  const QuestionContainer({
    required this.isMathQuestion,
    super.key,
    this.question,
    this.questionColor,
    this.questionNumber,
  });
  final Question? question;
  final Color? questionColor;
  final int? questionNumber;
  final bool isMathQuestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(
                  horizontal:
                      MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
                ),
                child: isMathQuestion
                    ? TeXView(
                        child: TeXViewDocument(
                          question!.question!,
                        ),
                        style: TeXViewStyle(
                          contentColor:
                              questionColor ?? Theme.of(context).primaryColor,
                          backgroundColor: Colors.transparent,
                          sizeUnit: TeXViewSizeUnit.pixels,
                          textAlign: TeXViewTextAlign.center,
                          fontStyle: TeXViewFontStyle(fontSize: 23),
                        ),
                        renderingEngine: const TeXViewRenderingEngine.katex(),
                      )
                    : Text(
                        questionNumber == null
                            ? '${question!.question}'
                            : '$questionNumber. ${question!.question}',
                        style: TextStyle(
                          fontSize: 20,
                          color:
                              questionColor ?? Theme.of(context).primaryColor,
                        ),
                      ),
              ),
            ),

            /// Show Marks if given
            if (question!.marks!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  '[${question!.marks}]',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: questionColor ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 15),
        if (question!.imageUrl != null && question!.imageUrl!.isNotEmpty) ...[
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            height: MediaQuery.of(context).size.height * (0.225),
            child: InteractiveViewer(
              boundaryMargin: const EdgeInsets.all(20),
              child: CachedNetworkImage(
                errorWidget: (context, image, _) => Center(
                  child: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                imageBuilder: (context, imageProvider) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                },
                imageUrl: question!.imageUrl!,
                placeholder: (context, url) => const Center(
                  child: CircularProgressContainer(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
        ],
      ],
    );
  }
}
