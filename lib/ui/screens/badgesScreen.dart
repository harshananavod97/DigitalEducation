import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/statistic/cubits/statisticsCubit.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/badgesIconContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  static Route<BadgesScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(builder: (_) => const BadgesScreen());
  }

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () {
        context.read<BadgesCubit>().getBadges(
              refreshBadges: true,
              languageId: UiUtils.getCurrentQuestionLanguageId(context),
            );
      },
    );

    Future.delayed(Duration.zero, () {
      UiUtils.updateBadgesLocally(context);
      context.read<StatisticCubit>().getStatistic();
    });

    Future.delayed(Duration.zero, () {
      context.read<InterstitialAdCubit>().showAd(context);
    });
  }

  void showBadgeDetails(BuildContext context, Badges badge) {
    showModalBottomSheet<void>(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 5,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      context: context,
      builder: (context) {
        final regularTextStyle = TextStyle(
          fontWeight: FontWeights.regular,
          color: Theme.of(context).colorScheme.onTertiary,
          fontSize: 16,
        );

        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: const BoxDecoration(
            borderRadius: UiUtils.bottomSheetTopRadius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .25,
                width: MediaQuery.of(context).size.width * .3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return BadgesIconContainer(
                      badge: badge,
                      constraints: constraints,
                      addTopPadding: true,
                    );
                  },
                ),
              ),
              Transform.translate(
                offset: Offset(0, MediaQuery.of(context).size.height * (-0.05)),
                child: Column(
                  children: [
                    Text(
                      badge.badgeLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: badge.status == '0'
                            ? kBadgeLockedColor
                            : Theme.of(context).colorScheme.onTertiary,
                        fontWeight: FontWeights.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 2.5),
                    Text(
                      badge.badgeNote,
                      textAlign: TextAlign.center,
                      style: regularTextStyle,
                    ),
                    const SizedBox(height: 2.5),
                    //
                    if (badge.type == 'big_thing' && badge.status == '0')
                      BlocBuilder<StatisticCubit, StatisticState>(
                        bloc: context.read<StatisticCubit>(),
                        builder: (context, state) {
                          if (state is StatisticInitial ||
                              state is StatisticFetchInProgress) {
                            return Center(
                              child: SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            );
                          }
                          if (state is StatisticFetchFailure) {
                            return const SizedBox();
                          }
                          if (state is StatisticFetchSuccess) {
                            final statisticDetails = state.statisticModel;
                            final answerToGo = int.parse(badge.badgeCounter) -
                                int.parse(
                                  statisticDetails.correctAnswers,
                                );

                            return Column(
                              children: [
                                Text(
                                  '${context.tr(needMoreKey)} $answerToGo ${context.tr(correctAnswerToUnlockKey)}',
                                  textAlign: TextAlign.center,
                                  style: regularTextStyle,
                                ),
                                const SizedBox(height: 5),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      )
                    else
                      const SizedBox(),

                    Text(
                      '${context.tr(getKey)} ${badge.badgeReward} ${context.tr(coinsUnlockingByBadgeKey)}',
                      textAlign: TextAlign.center,
                      style: regularTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Badges> _organizedBadges(List<Badges> badges) {
    final lockedBadges =
        badges.where((b) => b.status == '0').toList(growable: false);
    final unlockedBadges = badges
        .where((b) => b.status == '1' || b.status == '2')
        .toList(growable: false);

    return [...unlockedBadges, ...lockedBadges];
  }

  Widget _buildBadges() {
    final badgesCubit = context.read<BadgesCubit>();

    return BlocConsumer<BadgesCubit, BadgesState>(
      listener: (context, state) {
        if (state is BadgesFetchFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      bloc: badgesCubit,
      builder: (context, state) {
        if (state is BadgesFetchInProgress || state is BadgesInitial) {
          return const Center(child: CircularProgressContainer());
        }
        if (state is BadgesFetchFailure) {
          return Center(
            child: ErrorContainer(
              errorMessage: context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!,
              onTapRetry: () => badgesCubit.getBadges(
                refreshBadges: true,
                languageId: UiUtils.getCurrentQuestionLanguageId(context),
              ),
              showErrorImage: true,
            ),
          );
        }
        final badges = _organizedBadges((state as BadgesFetchSuccess).badges);

        return RefreshIndicator(
          color: Theme.of(context).primaryColor,
          displacement: MediaQuery.of(context).size.height *
                  (UiUtils.appBarHeightPercentage + 0.025) +
              20,
          onRefresh: () async => badgesCubit.getBadges(
            refreshBadges: true,
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 20,
            ),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 7.5,
              mainAxisSpacing: 10,
              childAspectRatio: 0.575,
            ),
            itemBuilder: (context, index) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onTap: () => showBadgeDetails(context, badges[index]),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight * (0.65),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: constraints.maxHeight * .4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    badges[index].badgeLabel,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: badges[index].status == '0'
                                          ? kBadgeLockedColor
                                          : Theme.of(context)
                                              .colorScheme
                                              .onTertiary, //
                                      fontSize: 16,
                                      height: 1.175,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BadgesIconContainer(
                          badge: badges[index],
                          constraints: constraints,
                          addTopPadding: true,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(context.tr(badgesKey)!)),
      body: _buildBadges(),
    );
  }
}
