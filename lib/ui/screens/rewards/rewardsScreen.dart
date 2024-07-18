import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/badges/badge.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/screens/rewards/scratchRewardScreen.dart';
import 'package:flutterquiz/ui/screens/rewards/widgets/unlockedRewardContent.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
        child: const RewardsScreen(),
        create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
      ),
    );
  }

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  Widget _buildRewardContainer(Badges reward) {
    return GestureDetector(
      onTap: () {
        if (reward.status == '1') {
          Navigator.of(context).push(
            PageRouteBuilder<dynamic>(
              transitionDuration: const Duration(milliseconds: 400),
              opaque: false,
              pageBuilder: (context, firstAnimation, secondAnimation) {
                return FadeTransition(
                  opacity: firstAnimation,
                  child: BlocProvider<UpdateScoreAndCoinsCubit>(
                    create: (context) =>
                        UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
                    child: ScratchRewardScreen(reward: reward),
                  ),
                );
              },
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: reward.status == '2'
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: reward.status == '2'
            ? UnlockedRewardContent(reward: reward, increaseFont: false)
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(Assets.scratchCardCover, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildRewards() {
    return CustomScrollView(
      slivers: [
        BlocBuilder<BadgesCubit, BadgesState>(
          bloc: context.read<BadgesCubit>(),
          builder: (context, state) {
            if (state is BadgesFetchFailure) {
              return SliverToBoxAdapter(
                child: Center(
                  child: ErrorContainer(
                    errorMessage:
                        convertErrorCodeToLanguageKey(state.errorMessage),
                    onTapRetry: () {
                      context.read<BadgesCubit>().getBadges(
                            refreshBadges: true,
                            languageId:
                                UiUtils.getCurrentQuestionLanguageId(context),
                          );
                    },
                    showErrorImage: true,
                  ),
                ),
              );
            }

            if (state is BadgesFetchSuccess) {
              final rewards = context.read<BadgesCubit>().getRewards();

              /// If there are no rewards
              if (rewards.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(context.tr(noRewardsKey)!),
                  ),
                );
              }

              //create grid count
              return SliverGrid.count(
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                crossAxisCount: 2,
                children: [
                  ...rewards.map(
                    (reward) => Hero(
                      tag: reward.type,
                      child: _buildRewardContainer(reward),
                    ),
                  ),
                ],
              );
            }

            return const SliverToBoxAdapter(
              child: Center(
                child: CircularProgressContainer(),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        centerTitle: true,
        shadowColor: colorScheme.surface.withOpacity(0.4),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        leading: QBackButton(
          removeSnackBars: false,
          color: colorScheme.surface,
        ),
        title: Text(
          context.tr(rewardsLbl)!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: BlocBuilder<BadgesCubit, BadgesState>(
              bloc: context.read<BadgesCubit>(),
              builder: (context, state) {
                return RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                      textStyle: TextStyle(
                        fontWeight: FontWeights.bold,
                        color: colorScheme.surface,
                        fontSize: 32,
                      ),
                    ),
                    children: [
                      TextSpan(
                        text:
                            '${context.read<BadgesCubit>().getRewardedCoins()} ${context.tr(coinsLbl)!}',
                      ),
                      TextSpan(
                        text: '\n${context.tr(totalRewardsEarnedKey)!}',
                        style: GoogleFonts.nunito(
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * UiUtils.vtMarginPct,
          horizontal: size.width * UiUtils.hzMarginPct,
        ),
        child: _buildRewards(),
      ),
    );
  }
}
