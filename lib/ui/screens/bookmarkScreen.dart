import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/bookmark/bookmarkRepository.dart';
import 'package:flutterquiz/features/bookmark/cubits/audioQuestionBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/guessTheWordBookmarkCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/updateBookmarkCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen>
    with SingleTickerProviderStateMixin {
  late final String _userId;
  late final String _userFirebaseId;

  late TabController tabController;
  late List<(String, Widget)> tabs = <(String, Widget)>[
    (quizZone, _buildQuizZoneQuestions()),
    // (guessTheWord, _buildGuessTheWordQuestions()),
    // (audioQuestionsKey, _buildAudioQuestions()),
  ];

  @override
  void initState() {
    super.initState();
    _userId = context.read<UserDetailsCubit>().userId();
    _userFirebaseId = context.read<UserDetailsCubit>().getUserFirebaseId();

    // Remove disabled quizzes
    final sysConfig = context.read<SystemConfigCubit>();
    if (!sysConfig.isQuizZoneEnabled) {
      tabs.removeWhere((t) => t.$1 == quizZone);
    }
    if (!sysConfig.isGuessTheWordEnabled) {
      tabs.removeWhere((t) => t.$1 == guessTheWord);
    }
    if (!sysConfig.isAudioQuizEnabled) {
      tabs.removeWhere((t) => t.$1 == audioQuestionsKey);
    }

    tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  void openBottomSheet({
    required String question,
    required String? imageUrl,
    required String correctAnswer,
    required String yourAnswer,
    bool isLatex = false,
  }) {
    showModalBottomSheet<void>(
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          height: MediaQuery.sizeOf(context).height * .7,
          margin: MediaQuery.of(context).viewInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 15),

              /// Title
              Text(
                context.tr(tabs[tabController.index].$1)!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              const Divider(),

              if (isLatex) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: TeXView(
                      child: TeXViewColumn(
                        children: [
                          TeXViewDocument(
                            question,
                            style: TeXViewStyle(
                              fontStyle: TeXViewFontStyle(
                                sizeUnit: TeXViewSizeUnit.pixels,
                                fontSize: 18,
                                fontWeight: TeXViewFontWeight.bold,
                              ),
                              margin: const TeXViewMargin.only(
                                bottom: 30,
                                sizeUnit: TeXViewSizeUnit.pixels,
                              ),
                            ),
                          ),
                          if (imageUrl != null && imageUrl != '') ...[
                            TeXViewContainer(
                              child: TeXViewImage.network(imageUrl),
                              style: const TeXViewStyle(
                                margin: TeXViewMargin.only(
                                  bottom: 15,
                                  sizeUnit: TeXViewSizeUnit.pixels,
                                ),
                                borderRadius: TeXViewBorderRadius.all(
                                  10,
                                  sizeUnit: TeXViewSizeUnit.pixels,
                                ),
                              ),
                            ),
                          ],
                          TeXViewDocument(
                            context.tr('yourAnsLbl')!,
                            style: const TeXViewStyle(
                              margin: TeXViewMargin.only(
                                bottom: 30,
                                sizeUnit: TeXViewSizeUnit.pixels,
                              ),
                            ),
                          ),

                          ///
                          TeXViewContainer(
                            child: TeXViewDocument(yourAnswer),
                            style: TeXViewStyle(
                              borderRadius: const TeXViewBorderRadius.all(8),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                              padding: const TeXViewPadding.only(
                                top: 16,
                                bottom: 16,
                                left: 14,
                                right: 14,
                              ),
                              margin: const TeXViewMargin.only(bottom: 20),
                            ),
                          ),
                        ],
                      ),
                      style: TeXViewStyle(
                        margin: const TeXViewMargin.all(
                          20,
                          sizeUnit: TeXViewSizeUnit.pixels,
                        ),
                        contentColor: Theme.of(context).colorScheme.onTertiary,
                        fontStyle: TeXViewFontStyle(
                          sizeUnit: TeXViewSizeUnit.pixels,
                          fontSize: 16,
                          fontWeight: TeXViewFontWeight.normal,
                        ),
                      ),
                      renderingEngine: const TeXViewRenderingEngine.katex(),
                    ),
                  ),
                ),
              ] else ...[
                Flexible(
                  fit: FlexFit.tight,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width *
                          UiUtils.hzMarginPct,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),

                        Text(
                          question,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeights.regular,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),

                        /// Image
                        if (imageUrl != null && imageUrl != '') ...[
                          const SizedBox(height: 30),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: MediaQuery.of(context).size.width * .9,
                              height: MediaQuery.of(context).size.width * .5,
                              alignment: Alignment.center,
                              child: CachedNetworkImage(
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressContainer(),
                                ),
                                imageUrl: imageUrl,
                                imageBuilder: (context, imageProvider) {
                                  return InteractiveViewer(
                                    boundaryMargin: const EdgeInsets.all(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (_, i, e) {
                                  return Center(
                                    child: Icon(
                                      Icons.error,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 15),
                        Text(
                          context.tr('yourAnsLbl')!,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeights.regular,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // height: 48,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          width: double.maxFinite,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            yourAnswer,
                            style: TextStyle(
                              fontWeight: FontWeights.regular,
                              fontSize: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiary
                                  .withOpacity(.3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizZoneQuestions() {
    final bookmarkCubit = context.read<BookmarkCubit>();
    return BlocBuilder<BookmarkCubit, BookmarkState>(
      builder: (context, state) {
        if (state is BookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .65,
                  child: ListView.separated(
                    itemBuilder: (_, index) {
                      final question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarked question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (_) =>
                            UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) => BlocConsumer<
                              UpdateBookmarkCubit, UpdateBookmarkState>(
                            bloc: context.read<UpdateBookmarkCubit>(),
                            listener: (_, state) {
                              if (state is UpdateBookmarkSuccess) {
                                bookmarkCubit.removeBookmarkQuestion(
                                  question.id,
                                  _userId,
                                );
                              }
                              if (state is UpdateBookmarkFailure) {
                                UiUtils.showSnackBar(
                                  context.tr(
                                    convertErrorCodeToLanguageKey(
                                      errorCodeUpdateBookmarkFailure,
                                    ),
                                  )!,
                                  context,
                                );
                              }
                            },
                            builder: (context, state) {
                              final ya = context
                                  .read<BookmarkCubit>()
                                  .getSubmittedAnswerForQuestion(question.id);
                              final yourAnswer = context.tr(ya) ?? ya;

                              return BookmarkCard(
                                queId: question.id!,
                                index: '${index + 1}',
                                title: question.question!,
                                desc: yourAnswer,
                                type: '1',
                                // type QuizZone
                                isLatex: true,
                                onTap: () {
                                  openBottomSheet(
                                    question: question.question!,
                                    yourAnswer: yourAnswer,
                                    imageUrl: question.imageUrl,
                                    isLatex: true,
                                    correctAnswer: question
                                        .answerOptions![
                                            question.answerOptions!.indexWhere(
                                      (e) =>
                                          e.id ==
                                          AnswerEncryption.decryptCorrectAnswer(
                                            rawKey: _userFirebaseId,
                                            correctAnswer:
                                                question.correctAnswer!,
                                          ),
                                    )]
                                        .title!,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: UiUtils.listTileGap),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: BlocBuilder<BookmarkCubit, BookmarkState>(
                    builder: (context, state) {
                      if (state is BookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: context.tr('playBookmarkBtn'),
                          radius: 8,
                          showBorder: false,
                          fontWeight: FontWeights.semiBold,
                          height: 58,
                          titleColor: Theme.of(context).colorScheme.surface,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.quizZone,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is BookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessageCode),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context.read<BookmarkCubit>().getBookmark(_userId);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAudioQuestions() {
    final bookmarkCubit = context.read<AudioQuestionBookmarkCubit>();
    return BlocBuilder<AudioQuestionBookmarkCubit, AudioQuestionBookMarkState>(
      bloc: bookmarkCubit,
      builder: (context, state) {
        if (state is AudioQuestionBookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .65,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final question = state.questions[index];

                      //providing updateBookmarkCubit to every bookmarekd question
                      return BlocProvider<UpdateBookmarkCubit>(
                        create: (_) =>
                            UpdateBookmarkCubit(BookmarkRepository()),
                        //using builder so we can access the recently provided cubit
                        child: Builder(
                          builder: (context) => BlocConsumer<
                              UpdateBookmarkCubit, UpdateBookmarkState>(
                            bloc: context.read<UpdateBookmarkCubit>(),
                            listener: (context, state) {
                              if (state is UpdateBookmarkSuccess) {
                                bookmarkCubit.removeBookmarkQuestion(
                                  question.id,
                                  _userId,
                                );
                              }
                              if (state is UpdateBookmarkFailure) {
                                UiUtils.showSnackBar(
                                  context.tr(
                                    convertErrorCodeToLanguageKey(
                                      errorCodeUpdateBookmarkFailure,
                                    ),
                                  )!,
                                  context,
                                );
                              }
                            },
                            builder: (context, state) {
                              final ya = bookmarkCubit
                                  .getSubmittedAnswerForQuestion(question.id);
                              final yourAnswer = context.tr(ya) ?? ya;

                              return BookmarkCard(
                                queId: question.id!,
                                index: '${index + 1}',
                                title: question.question!,
                                desc: yourAnswer,
                                type: '4',
                                onTap: state is UpdateBookmarkInProgress
                                    ? () {}
                                    : () {
                                        openBottomSheet(
                                          question: question.question!,
                                          yourAnswer: yourAnswer,
                                          correctAnswer: question
                                              .answerOptions![question
                                                  .answerOptions!
                                                  .indexWhere(
                                            (o) =>
                                                o.id ==
                                                AnswerEncryption
                                                    .decryptCorrectAnswer(
                                                  rawKey: context
                                                      .read<UserDetailsCubit>()
                                                      .getUserFirebaseId(),
                                                  correctAnswer:
                                                      question.correctAnswer!,
                                                ),
                                          )]
                                              .title!,
                                          imageUrl: '',
                                        );
                                      }, // type Audio Quiz
                              );
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: state.questions.length,
                    separatorBuilder: (_, i) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: BlocBuilder<AudioQuestionBookmarkCubit,
                      AudioQuestionBookMarkState>(
                    builder: (context, state) {
                      if (state is AudioQuestionBookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: context.tr('playBookmarkBtn'),
                          radius: 8,
                          showBorder: false,
                          fontWeight: FontWeight.w500,
                          height: 58,
                          titleColor: Theme.of(context).colorScheme.surface,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.audioQuestions,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is AudioQuestionBookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessageCode),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () {
              context.read<AudioQuestionBookmarkCubit>().getBookmark(_userId);
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Center noBookmarksFound() => Center(
        child: Text(
          context.tr('noBookmarkQueLbl')!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontSize: 20,
          ),
        ),
      );

  Widget _buildGuessTheWordQuestions() {
    final bookmarkCubit = context.read<GuessTheWordBookmarkCubit>();
    return BlocBuilder<GuessTheWordBookmarkCubit, GuessTheWordBookmarkState>(
      bloc: context.read<GuessTheWordBookmarkCubit>(),
      builder: (context, state) {
        if (state is GuessTheWordBookmarkFetchSuccess) {
          if (state.questions.isEmpty) {
            return noBookmarksFound();
          }

          return Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .65,
                child: ListView.separated(
                  separatorBuilder: (_, i) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.015,
                  ),
                  itemBuilder: (context, index) {
                    final question = state.questions[index];

                    //providing updateBookmarkCubit to every bookmarked question
                    return BlocProvider<UpdateBookmarkCubit>(
                      create: (context) =>
                          UpdateBookmarkCubit(BookmarkRepository()),
                      //using builder so we can access the recently provided cubit
                      child: Builder(
                        builder: (context) => BlocConsumer<UpdateBookmarkCubit,
                            UpdateBookmarkState>(
                          bloc: context.read<UpdateBookmarkCubit>(),
                          listener: (context, state) {
                            if (state is UpdateBookmarkSuccess) {
                              bookmarkCubit.removeBookmarkQuestion(
                                question.id,
                                _userId,
                              );
                            }
                            if (state is UpdateBookmarkFailure) {
                              UiUtils.showSnackBar(
                                context.tr(
                                  convertErrorCodeToLanguageKey(
                                    errorCodeUpdateBookmarkFailure,
                                  ),
                                )!,
                                context,
                              );
                            }
                          },
                          builder: (context, state) {
                            final ya = context
                                .read<GuessTheWordBookmarkCubit>()
                                .getSubmittedAnswerForQuestion(question.id);
                            final yourAnswer = context.tr(ya) ?? ya;
                            return BookmarkCard(
                              queId: question.id,
                              index: '${index + 1}',
                              title: question.question,
                              desc: yourAnswer,
                              type: '3',
                              onTap: () {
                                openBottomSheet(
                                  yourAnswer: yourAnswer,
                                  question: question.question,
                                  correctAnswer: question.answer,
                                  imageUrl: question.image,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                  itemCount: state.questions.length,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: BlocBuilder<GuessTheWordBookmarkCubit,
                      GuessTheWordBookmarkState>(
                    builder: (context, state) {
                      if (state is GuessTheWordBookmarkFetchSuccess &&
                          state.questions.isNotEmpty) {
                        return CustomRoundedButton(
                          widthPercentage: 1,
                          backgroundColor: Theme.of(context).primaryColor,
                          buttonTitle: context.tr('playBookmarkBtn'),
                          radius: 8,
                          showBorder: false,
                          fontWeight: FontWeight.w500,
                          height: 58,
                          titleColor: Theme.of(context).colorScheme.surface,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              Routes.bookmarkQuiz,
                              arguments: QuizTypes.guessTheWord,
                            );
                          },
                          elevation: 6.5,
                          textSize: 18,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
            ],
          );
        }
        if (state is GuessTheWordBookmarkFetchFailure) {
          return ErrorContainer(
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessageCode),
            showErrorImage: true,
            errorMessageColor: Theme.of(context).primaryColor,
            onTapRetry: () =>
                context.read<GuessTheWordBookmarkCubit>().getBookmark(_userId),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(
          context.tr(bookmarkLbl)!,
        ),
        bottom: TabBar(
          isScrollable: true,
          controller: tabController,
          tabs: tabs
              .map(
                (tab) => Tab(
                  text: context.tr(tab.$1),
                ),
              )
              .toList(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
          horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: TabBarView(
          controller: tabController,
          children: tabs.map((tab) => tab.$2).toList(),
        ),
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  const BookmarkCard({
    required this.index,
    required this.title,
    required this.desc,
    required this.queId,
    required this.type,
    required this.onTap,
    super.key,
    this.isLatex = false,
  });

  final String index;
  final String title;
  final String desc;
  final String queId;
  final String type;
  final bool isLatex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.height * .116,
        width: size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0xffFFD7E5),
                  ),
                  width: constraints.maxWidth * .13,
                  height: constraints.maxWidth * .13,
                  child: Center(
                    child: Text(
                      index,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeights.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                SizedBox(
                  width: constraints.maxWidth * .722,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      if (isLatex) ...[
                        Expanded(
                          child: TeXView(
                            child: TeXViewGroup(
                              children: [
                                TeXViewGroupItem(
                                  id: '-',
                                  child: TeXViewDocument(
                                    title,
                                    style: TeXViewStyle(
                                      contentColor: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                      fontStyle: TeXViewFontStyle(
                                        sizeUnit: TeXViewSizeUnit.pixels,
                                        fontSize: 16,
                                        fontWeight: TeXViewFontWeight.w500,
                                      ),
                                      margin: const TeXViewMargin.only(
                                        bottom: 10,
                                        sizeUnit: TeXViewSizeUnit.pixels,
                                      ),
                                    ),
                                  ),
                                ),
                                TeXViewGroupItem(
                                  id: '--',
                                  child: TeXViewDocument(
                                    desc,
                                    style: TeXViewStyle(
                                      contentColor: Theme.of(context)
                                          .colorScheme
                                          .onTertiary,
                                      fontStyle: TeXViewFontStyle(
                                        sizeUnit: TeXViewSizeUnit.pixels,
                                        fontSize: 16,
                                        fontWeight: TeXViewFontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              onTap: (_) => onTap(),
                            ),
                            renderingEngine:
                                const TeXViewRenderingEngine.katex(),
                          ),
                        ),
                      ] else ...[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeights.bold,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          desc,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeights.regular,
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiary
                                .withOpacity(0.3),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                /// Close
                GestureDetector(
                  onTap: () {
                    context.read<UpdateBookmarkCubit>().updateBookmark(
                          queId,
                          '0',
                          type,
                        );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
