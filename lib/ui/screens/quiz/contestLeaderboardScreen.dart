import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/cubits/getContestLeaderboardCubit.dart';
import 'package:flutterquiz/features/quiz/models/contestLeaderboard.dart';
import 'package:flutterquiz/features/quiz/quizRemoteDataSource.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ContestLeaderBoardScreen extends StatefulWidget {
  const ContestLeaderBoardScreen({super.key, this.contestId});

  final String? contestId;

  @override
  State<ContestLeaderBoardScreen> createState() => _ContestLeaderBoardScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<GetContestLeaderboardCubit>(
        create: (_) => GetContestLeaderboardCubit(QuizRepository()),
        child: ContestLeaderBoardScreen(
          contestId: arguments!['contestId'] as String?,
        ),
      ),
    );
  }
}

class _ContestLeaderBoardScreen extends State<ContestLeaderBoardScreen> {
  @override
  void initState() {
    super.initState();
    getContestLeaderBoard();
  }

  void getContestLeaderBoard() {
    context.read<GetContestLeaderboardCubit>().getContestLeaderboard(
          contestId: widget.contestId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        elevation: 0,
        title: Text(
          context.tr('contestLeaderBoardLbl')!,
        ),
      ),
      body: BlocBuilder<GetContestLeaderboardCubit, GetContestLeaderboardState>(
        bloc: context.read<GetContestLeaderboardCubit>(),
        builder: (context, state) {
          if (state is GetContestLeaderboardInitial ||
              state is GetContestLeaderboardProgress) {
            return const Center(child: CircularProgressContainer());
          }

          if (state is GetContestLeaderboardFailure) {
            return ErrorContainer(
              errorMessage: state.errorMessage,
              onTapRetry: getContestLeaderBoard,
              showErrorImage: true,
            );
          }

          final leaderboardList =
              (state as GetContestLeaderboardSuccess).getContestLeaderboardList;

          return Column(
            children: [
              topThreeRanks(leaderboardList),
              leaderBoard(leaderboardList),
              if (QuizRemoteDataSource.score != '0' &&
                  int.parse(QuizRemoteDataSource.rank) > 3) ...[
                myRank(
                  QuizRemoteDataSource.rank,
                  QuizRemoteDataSource.profile,
                  QuizRemoteDataSource.score,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget leaderBoard(List<ContestLeaderboard> list) {
    if (list.length <= 3) return const SizedBox();

    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onTertiary,
      fontSize: 16,
    );
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        height: height * .45,
        padding: EdgeInsets.only(top: 5, left: width * .02, right: width * .02),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: list.length,
          separatorBuilder: (_, i) => i > 2
              ? Divider(
                  color: Colors.grey,
                  indent: width * 0.03,
                  endIndent: width * 0.03,
                )
              : const SizedBox(),
          itemBuilder: (context, index) {
            return index > 2
                ? Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(list[index].userRank!, style: textStyle),
                      ),
                      Expanded(
                        flex: 9,
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(right: 20),
                          title: Text(
                            list[index].name ?? '...',
                            overflow: TextOverflow.ellipsis,
                            style: textStyle,
                          ),
                          leading: Container(
                            width: width * .12,
                            height: height * .3,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: QImage.circular(
                              imageUrl: list[index].profile ?? '',
                              width: double.maxFinite,
                              height: double.maxFinite,
                            ),
                          ),
                          trailing: SizedBox(
                            width: width * .12,
                            child: Center(
                              child: Text(
                                UiUtils.formatNumber(
                                  int.parse(list[index].score ?? '0'),
                                ),
                                maxLines: 1,
                                softWrap: false,
                                style: textStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox();
          },
        ),
      ),
    );
  }

  Widget topThreeRanks(List<ContestLeaderboard> list) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: width,
      height: height * 0.29,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final onTertiary = Theme.of(context).colorScheme.onTertiary;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /// Rank Two
              if (list.length > 1)
                Column(
                  children: [
                    SizedBox(height: height * .07),
                    SizedBox(
                      height: width * .224,
                      width: width * .21,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: width * .21,
                              width: width * .21,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: onTertiary.withOpacity(.3),
                                ),
                              ),
                              child: QImage.circular(
                                imageUrl: list[1].profile!,
                                width: double.maxFinite,
                                height: double.maxFinite,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: rankCircle('2'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: width * .2,
                      child: Center(
                        child: Text(
                          list[1].name ?? '...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeights.regular,
                            color: onTertiary.withOpacity(.8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .15,
                      child: Center(
                        child: Text(
                          list[1].score ?? '...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.bold,
                            color: onTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(height: height * .1, width: width * .2),

              /// Rank One
              if (list.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: width * .30,
                      width: width * .28,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: width * .28,
                              width: width * .28,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: QImage.circular(
                                imageUrl: list[0].profile!,
                                width: double.maxFinite,
                                height: double.maxFinite,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: rankCircle('1', size: 32),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * .2,
                      child: Center(
                        child: Text(
                          list[0].name ?? '...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.regular,
                            color: onTertiary.withOpacity(.8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .15,
                      child: Center(
                        child: Text(
                          list[0].score ?? '...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeights.bold,
                            color: onTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(height: height * .1, width: width * .2),

              /// Rank Three
              if (list.length > 2)
                Column(
                  children: [
                    SizedBox(height: height * .07),
                    SizedBox(
                      height: width * .224,
                      width: width * .21,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: width * .21,
                              width: width * .21,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: onTertiary.withOpacity(.3),
                                ),
                              ),
                              child: QImage.circular(
                                imageUrl: list[2].profile!,
                                width: double.maxFinite,
                                height: double.maxFinite,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: rankCircle('3'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: width * .2,
                      child: Center(
                        child: Text(
                          list[2].name ?? '...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeights.regular,
                            color: onTertiary.withOpacity(.8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: width * .15,
                      child: Center(
                        child: Text(
                          list[2].score ?? '...',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeights.bold,
                            color: onTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(height: height * .1, width: width * .2),
            ],
          );
        },
      ),
    );
  }

  Widget rankCircle(String text, {double size = 25}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: colorScheme.surface,
        child: Text(text),
      ),
    );
  }

  Widget myRank(String rank, String profile, String score) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = TextStyle(color: colorScheme.onTertiary, fontSize: 16);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(color: colorScheme.surface),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
        title: Row(
          children: [
            Center(child: Text(rank, style: textStyle)),
            Container(
              margin: const EdgeInsets.only(left: 10),
              height: size.height * .06,
              width: size.width * .13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.surface,
                ),
              ),
              child: QImage.circular(
                imageUrl: profile,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.tr(myRankKey)!,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ],
        ),
        trailing: Text(
          score,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: textStyle,
        ),
      ),
    );
  }
}
