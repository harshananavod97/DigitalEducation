import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/exam/cubits/completedExamsCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examsCubit.dart';
import 'package:flutterquiz/features/exam/examRepository.dart';
import 'package:flutterquiz/features/exam/models/exam.dart';
import 'package:flutterquiz/features/exam/models/examResult.dart';
import 'package:flutterquiz/ui/screens/exam/exam_result_screen.dart';
import 'package:flutterquiz/ui/screens/exam/widgets/examKeyBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/datetime_utils.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ExamsCubit>(create: (_) => ExamsCubit(ExamRepository())),
          BlocProvider<CompletedExamsCubit>(
            create: (_) => CompletedExamsCubit(ExamRepository()),
          ),
        ],
        child: const ExamsScreen(),
      ),
    );
  }
}

class _ExamsScreenState extends State<ExamsScreen> {
  int currentSelectedQuestionIndex = 0;

  late final _completedExamScrollController = ScrollController()
    ..addListener(hasMoreResultScrollListener);

  ///
  late final String languageId;

  void hasMoreResultScrollListener() {
    if (_completedExamScrollController.position.maxScrollExtent ==
        _completedExamScrollController.offset) {
      log('At the end of the list');

      ///
      if (context.read<CompletedExamsCubit>().hasMoreResult()) {
        context
            .read<CompletedExamsCubit>()
            .getMoreResult(languageId: languageId);
      } else {
        log('No more result');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    languageId = UiUtils.getCurrentQuestionLanguageId(context);

    getExams();
    getCompletedExams();
  }

  @override
  void dispose() {
    _completedExamScrollController
      ..removeListener(hasMoreResultScrollListener)
      ..dispose();
    super.dispose();
  }

  void getExams() {
    Future.delayed(Duration.zero, () {
      context.read<ExamsCubit>().getExams(languageId: languageId);
    });
  }

  void getCompletedExams() {
    Future.delayed(Duration.zero, () {
      context
          .read<CompletedExamsCubit>()
          .getCompletedExams(languageId: languageId);
    });
  }

  void showExamKeyBottomSheet(BuildContext context, Exam exam) {
    showModalBottomSheet<void>(
      isDismissible: false,
      isScrollControlled: true,
      elevation: 5,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) => ExamKeyBottomSheetContainer(
        navigateToExamScreen: navigateToExamScreen,
        exam: exam,
      ),
    );
  }

  Future<void> navigateToExamScreen() async {
    Navigator.of(context).pop();

    await Navigator.of(context).pushNamed(Routes.exam).then((value) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          //fetch exams again with fresh status
          context.read<ExamsCubit>().getExams(languageId: languageId);
          //fetch completed exam again with fresh status
          context
              .read<CompletedExamsCubit>()
              .getCompletedExams(languageId: languageId);
        }
      });
    });
  }

  Widget _buildExamResults() {
    return BlocConsumer<CompletedExamsCubit, CompletedExamsState>(
      listener: (context, state) {
        if (state is CompletedExamsFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      bloc: context.read<CompletedExamsCubit>(),
      builder: (context, state) {
        if (state is CompletedExamsFetchInProgress ||
            state is CompletedExamsInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is CompletedExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageColor: Theme.of(context).primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: getCompletedExams,
              showErrorImage: true,
              showRTryButton:
                  state.errorMessage != errorCodeHaveNotCompletedExam,
            ),
          );
        }
        return ListView.builder(
          controller: _completedExamScrollController,
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.width * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount:
              (state as CompletedExamsFetchSuccess).completedExams.length,
          itemBuilder: (context, index) {
            return _buildResultContainer(
              examResult: state.completedExams[index],
              hasMoreResultFetchError: state.hasMoreFetchError,
              index: index,
              totalExamResults: state.completedExams.length,
              hasMore: state.hasMore,
            );
          },
        );
      },
    );
  }

  Widget _buildTodayExams() {
    return BlocConsumer<ExamsCubit, ExamsState>(
      listener: (_, state) {
        if (state is ExamsFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      bloc: context.read<ExamsCubit>(),
      builder: (context, state) {
        if (state is ExamsFetchInProgress || state is ExamsInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is ExamsFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessageColor: Theme.of(context).primaryColor,
              errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
              onTapRetry: getExams,
              showErrorImage: true,
              showRTryButton: state.errorMessage != errorCodeNoExamForToday,
            ),
          );
        }

        final exams = (state as ExamsFetchSuccess).exams;

        if (exams.isEmpty) {
          return Center(
            child: Text(
              context.tr('allExamsCompleteLbl')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiary,
                fontSize: 20,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
            horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
          ),
          itemCount: exams.length,
          itemBuilder: (_, i) => _buildTodayExamContainer(exams[i]),
          separatorBuilder: (_, i) => const SizedBox(height: 10),
        );
      },
    );
  }

  Widget _buildTodayExamContainer(Exam exam) {
    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(exam.date),
    );
    return GestureDetector(
      onTap: () => showExamKeyBottomSheet(context, exam),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Exam title
                  Text(
                    exam.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  /// Date & Duration
                  Text(
                    "$formattedDate  |  ${exam.duration} ${context.tr("minLbl")!}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            /// Marks
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.transparent,
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.3),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Text(
                '${exam.totalMarks} ${context.tr(markKey)!}',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContainer({
    required ExamResult examResult,
    required int index,
    required int totalExamResults,
    required bool hasMoreResultFetchError,
    required bool hasMore,
  }) {
    if (index == totalExamResults - 1) {
      //check if hasMore
      if (hasMore) {
        if (hasMoreResultFetchError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: IconButton(
                onPressed: () {
                  context.read<CompletedExamsCubit>().getMoreResult(
                        languageId: languageId,
                      );
                },
                icon: Icon(
                  Icons.error,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: CircularProgressContainer(),
            ),
          );
        }
      }
    }

    final formattedDate = DateTimeUtils.dateFormat.format(
      DateTime.parse(examResult.date),
    );
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<ExamResultScreen>(
            builder: (_) => ExamResultScreen(examResult: examResult),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        height: size.height * .1,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: size.width * (0.5),
                  child: Text(
                    examResult.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onTertiary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  width: size.width * (0.5),
                  child: Text(
                    formattedDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onTertiary.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${examResult.obtainedMarks()}/${examResult.totalMarks} ${context.tr(markKey)!} ',
                  style: TextStyle(
                    color: colorScheme.onTertiary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: QAppBar(
          title: Text(context.tr('exam')!),
          bottom: TabBar(
            tabAlignment: TabAlignment.fill,
            tabs: [
              Tab(text: context.tr(dailyLbl)),
              Tab(text: context.tr(completedLbl)),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildTodayExams(),
                _buildExamResults(),
              ],
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: BannerAdContainer(),
            ),
          ],
        ),
      ),
    );
  }
}
