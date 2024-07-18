import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// Contest Type
const int _past = 0;
const int _live = 1;
const int _upcoming = 2;

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ContestCubit>(
            create: (_) => ContestCubit(QuizRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) => UpdateScoreAndCoinsCubit(
              ProfileManagementRepository(),
            ),
          ),
        ],
        child: const ContestScreen(),
      ),
    );
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ContestCubit>()
        .getContest(languageId: UiUtils.getCurrentQuestionLanguageId(context));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                context.tr('contestLbl')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              leading: const CustomBackButton(),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.08),
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      Tab(text: context.tr('pastLbl')),
                      Tab(text: context.tr('liveLbl')),
                      Tab(text: context.tr('upcomingLbl')),
                    ],
                  ),
                ),
              ),
            ),
            body: BlocConsumer<ContestCubit, ContestState>(
              bloc: context.read<ContestCubit>(),
              listener: (context, state) {
                if (state is ContestFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is ContestProgress || state is ContestInitial) {
                  return const Center(
                    child: CircularProgressContainer(),
                  );
                }
                if (state is ContestFailure) {
                  return ErrorContainer(
                    errorMessage:
                        convertErrorCodeToLanguageKey(state.errorMessage),
                    onTapRetry: () {
                      context.read<ContestCubit>().getContest(
                            languageId:
                                UiUtils.getCurrentQuestionLanguageId(context),
                          );
                    },
                    showErrorImage: true,
                  );
                }
                final contestList = (state as ContestSuccess).contestList;
                return TabBarView(
                  children: [
                    past(contestList.past),
                    live(contestList.live),
                    future(contestList.upcoming),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _past,
            ),
          );
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _live,
            ),
          );
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _upcoming,
            ),
          );
  }

  ErrorContainer contestErrorContainer(Contest data) {
    return ErrorContainer(
      showBackButton: false,
      errorMessage: convertErrorCodeToLanguageKey(data.errorMessage),
      onTapRetry: () => context.read<ContestCubit>().getContest(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          ),
      showErrorImage: true,
    );
  }
}

class _ContestCard extends StatefulWidget {
  const _ContestCard({required this.contestDetails, required this.contestType});

  final ContestDetails contestDetails;
  final int contestType;

  @override
  State<_ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<_ContestCard> {
  void _handleOnTap() {
    if (widget.contestType == _past) {
      Navigator.of(context).pushNamed(
        Routes.contestLeaderboard,
        arguments: {'contestId': widget.contestDetails.id},
      );
    }
    if (widget.contestType == _live) {
      if (int.parse(context.read<UserDetailsCubit>().getCoins()!) >=
          int.parse(widget.contestDetails.entry!)) {
        context.read<UpdateScoreAndCoinsCubit>().updateCoins(
              coins: int.parse(widget.contestDetails.entry!),
              addCoin: false,
              title: context.tr(playedContestKey) ?? '-',
            );

        context.read<UserDetailsCubit>().updateCoins(
              addCoin: false,
              coins: int.parse(widget.contestDetails.entry!),
            );
        Navigator.of(context).pushReplacementNamed(
          Routes.quiz,
          arguments: {
            'numberOfPlayer': 1,
            'quizType': QuizTypes.contest,
            'contestId': widget.contestDetails.id,
            'quizName': 'Contest',
          },
        );
      } else {
        UiUtils.showSnackBar(context.tr('noCoinsMsg')!, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final boldTextStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onTertiary,
      fontWeight: FontWeight.bold,
    );
    final normalTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeights.regular,
      color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
    );
    final size = MediaQuery.of(context).size;

    final verticalDivider = SizedBox(
      width: 1,
      height: 30,
      child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
    );

    return Container(
      margin: const EdgeInsets.all(15),
      width: size.width * .9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          UiUtils.buildBoxShadow(
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: _handleOnTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: widget.contestDetails.image!,
                placeholder: (_, i) => const Center(
                  child: CircularProgressContainer(),
                ),
                imageBuilder: (_, img) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                    height: 171,
                    width: size.width,
                  );
                },
                errorWidget: (_, i, e) => Center(
                  child: Icon(
                    Icons.error,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.contestDetails.name!,
                    style: boldTextStyle,
                  ),
                  if (widget.contestDetails.description!.length > 50)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.contestDetails.showDescription =
                                !widget.contestDetails.showDescription!;
                          });
                        },
                        child: Icon(
                          widget.contestDetails.showDescription!
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).colorScheme.onTertiary,
                          size: 30,
                        ),
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
              SizedBox(
                width: !widget.contestDetails.showDescription!
                    ? size.width * .75
                    : size.width,
                child: Text(
                  widget.contestDetails.description!,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.3),
                  ),
                  maxLines: !widget.contestDetails.showDescription! ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Divider(
                color: Theme.of(context).scaffoldBackgroundColor,
                height: 0,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('entryFeesLbl')!,
                        style: normalTextStyle,
                      ),
                      Text(
                        '${widget.contestDetails.entry!} ${context.tr('coinsLbl')!}',
                        style: boldTextStyle,
                      ),
                    ],
                  ),

                  ///
                  verticalDivider,
                  if (widget.contestType == _upcoming)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('startsOnLbl')!,
                          style: normalTextStyle,
                        ),
                        Text(
                          widget.contestDetails.startDate!,
                          style: boldTextStyle,
                        ),
                      ],
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('playersLbl')!,
                          style: normalTextStyle,
                        ),
                        Text(
                          widget.contestDetails.participants!,
                          style: boldTextStyle,
                        ),
                      ],
                    ),

                  ///
                  verticalDivider,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('endsOnLbl')!,
                        style: normalTextStyle,
                      ),
                      Text(
                        widget.contestDetails.endDate!,
                        style: boldTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
