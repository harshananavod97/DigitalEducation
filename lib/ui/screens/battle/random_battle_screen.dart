import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/top_curve_clipper.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/watchRewardAdDialog.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class RandomBattleScreen extends StatefulWidget {
  const RandomBattleScreen({super.key});

  static Route<RandomBattleScreen> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
        child: const RandomBattleScreen(),
      ),
    );
  }

  @override
  State<RandomBattleScreen> createState() => _RandomBattleScreenState();
}

class _RandomBattleScreenState extends State<RandomBattleScreen> {
  String selectedCategory = selectCategoryKey;
  String selectedCategoryId = '0';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<RewardedAdCubit>().createRewardedAd(context);
      if (context.read<SystemConfigCubit>().isCategoryEnabledForRandomBattle) {
        _getCategories();
      }
    });
  }

  void _getCategories() {
    context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
          languageId: UiUtils.getCurrentQuestionLanguageId(context),
          type: UiUtils.getCategoryTypeNumberFromQuizType(
            QuizTypes.oneVsOneBattle,
          ),
          subType: UiUtils.subTypeFromQuizType(QuizTypes.oneVsOneBattle),
        );
  }

  void _addCoinsAfterRewardAd() {
    final rewardAdsCoins = context.read<SystemConfigCubit>().rewardAdsCoins;

    context
        .read<UserDetailsCubit>()
        .updateCoins(addCoin: true, coins: rewardAdsCoins);

    context.read<UpdateScoreAndCoinsCubit>().updateCoins(
          coins: rewardAdsCoins,
          addCoin: true,
          title: watchedRewardAdKey,
        );
  }

  Widget _buildDropDown({
    required List<Map<String, String?>> values,
    required String keyValue,
  }) {
    selectedCategory = values.map((e) => e['name']).toList().first!;
    selectedCategoryId = values.map((e) => e['id']).toList().first!;

    return StatefulBuilder(
      builder: (context, setState) {
        final colorScheme = Theme.of(context).colorScheme;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DropdownButton<String>(
            key: Key(keyValue),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: colorScheme.surface,
            style: TextStyle(
              color: colorScheme.onTertiary,
              fontSize: 16,
              fontWeight: FontWeights.regular,
            ),
            isExpanded: true,
            alignment: Alignment.center,
            icon: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.onTertiary.withOpacity(0.4),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onTertiary,
              ),
            ),
            value: selectedCategory,
            hint: Text(
              context.tr(selectCategoryKey)!,
              style: TextStyle(
                color: colorScheme.onTertiary.withOpacity(0.4),
                fontSize: 16,
                fontWeight: FontWeights.regular,
              ),
            ),
            onChanged: (value) {
              setState(() {
                selectedCategory = value!;

                // set id for selected category
                for (final v in values) {
                  if (v['name'] == selectedCategory) {
                    selectedCategoryId = v['id']!;
                  }
                }
              });
            },
            items: values.map((e) => e['name']).toList().map((name) {
              return DropdownMenuItem(
                value: name,
                child: name == selectCategoryKey
                    ? Text(
                        context.tr(selectCategoryKey)!,
                      )
                    : Text(name!),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget selectCategoryDropDown() {
    return context.read<SystemConfigCubit>().isCategoryEnabledForRandomBattle
        ? BlocConsumer<QuizCategoryCubit, QuizCategoryState>(
            listener: (context, state) {
              if (state is QuizCategorySuccess) {
                setState(() {
                  selectedCategory = state.categories.first.categoryName!;
                  selectedCategoryId = state.categories.first.id!;
                });
              }

              if (state is QuizCategoryFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                  return;
                }
                showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          //context.read<QuizCategoryCubit>().getQuizCategory(UiUtils.getCurrentQuestionLanguageId(context), "");
                        },
                        child: Text(
                          context.tr(retryLbl)!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                    content: Text(
                      context.tr(
                        convertErrorCodeToLanguageKey(
                          state.errorMessage,
                        ),
                      )!,
                    ),
                  ),
                ).then((value) {
                  if (value != null && value) {
                    _getCategories();
                  }
                });
              }
            },
            builder: (context, state) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: state is QuizCategorySuccess
                    ? _buildDropDown(
                        values: state.categories
                            .where((c) => !c.isPremium)
                            .map((e) => {'name': e.categoryName, 'id': e.id})
                            .toList(),
                        keyValue: 'selectCategorySuccess',
                      )
                    : Opacity(
                        opacity: 0.65,
                        child: _buildDropDown(
                          values: [
                            {'name': selectCategoryKey, 'id': '0'},
                          ],
                          keyValue: 'selectCategory',
                        ),
                      ),
              );
            },
          )
        : const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocListener<UpdateScoreAndCoinsCubit, UpdateScoreAndCoinsState>(
      listener: (context, state) {
        if (state is UpdateScoreAndCoinsFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                /// Title & Back Btn
                Container(
                  width: size.width,
                  height: size.height * .45,
                  color: Theme.of(context).primaryColor,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      /// BG
                      SvgPicture.asset(
                        Assets.battleDesignImg,
                        fit: BoxFit.cover,
                        width: size.width,
                        height: size.height,
                      ),

                      /// VS
                      Padding(
                        padding: const EdgeInsets.only(top: 75, left: 3),
                        child: SvgPicture.asset(
                          Assets.vsImg,
                          width: 247.177,
                          height: 126.416,
                        ),
                      ),

                      /// Title & Back Button
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.07,
                          left: 25,
                        ),
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: Navigator.of(context).pop,
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  size: 24.5,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                context.tr('randomLbl')!,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Theme.of(context).colorScheme.surface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  child: ClipPath(
                    clipper: TopCurveClipper(),
                    child: Container(
                      width: size.width,
                      height: size.height * .63,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * UiUtils.hzMarginPct,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: size.height * .07),

                          /// Select Category
                          if (context
                              .read<SystemConfigCubit>()
                              .isCategoryEnabledForRandomBattle)
                            Text(
                              context.tr(selectCategoryKey)!,
                              style: TextStyle(
                                fontWeight: FontWeights.regular,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                            ),

                          /// dropDown
                          if (context
                              .read<SystemConfigCubit>()
                              .isCategoryEnabledForRandomBattle)
                            SizedBox(height: size.height * .01),
                          if (context
                              .read<SystemConfigCubit>()
                              .isCategoryEnabledForRandomBattle)
                            selectCategoryDropDown(),

                          /// Entry fees & Current user coins
                          SizedBox(height: size.height * .02),
                          _buildEntryFeesAndCoinsCard(context, size),

                          /// Let's Play
                          SizedBox(height: size.height * .04),
                          letsPlayButton(size, context),

                          if (context
                              .read<SystemConfigCubit>()
                              .isOneVsOneBattleEnabled) ...[
                            /// OR
                            SizedBox(height: size.height * .02),
                            _buildOrDivider(context, size),

                            /// Let's Play
                            SizedBox(height: size.height * .02),
                            playWithFrndsButton(size, context),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CustomRoundedButton playWithFrndsButton(Size size, BuildContext context) {
    return CustomRoundedButton(
      widthPercentage: size.width,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle: context.tr('playWithFrdLbl'),
      radius: 8,
      showBorder: false,
      height: size.height * .07,
      fontWeight: FontWeights.semiBold,
      textSize: 18,
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute<CreateOrJoinRoomScreen>(
            builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
              create: (_) =>
                  UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              child: CreateOrJoinRoomScreen(
                quizType: QuizTypes.oneVsOneBattle,
                title: context.tr('playWithFrdLbl')!,
              ),
            ),
          ),
        );
      },
    );
  }

  CustomRoundedButton letsPlayButton(Size size, BuildContext context) {
    return CustomRoundedButton(
      widthPercentage: size.width,
      backgroundColor: Theme.of(context).primaryColor,
      buttonTitle: context.tr('letsPlay'),
      radius: 8,
      showBorder: false,
      height: size.height * .07,
      fontWeight: FontWeights.semiBold,
      textSize: 18,
      onTap: () {
        final userProfile = context.read<UserDetailsCubit>().getUserProfile();

        if (int.parse(userProfile.coins!) <
            context.read<SystemConfigCubit>().randomBattleEntryCoins) {
          //if ad not loaded than show not enough coins
          if (context.read<RewardedAdCubit>().state is! RewardedAdLoaded) {
            UiUtils.errorMessageDialog(
              context,
              context.tr(
                convertErrorCodeToLanguageKey(errorCodeNotEnoughCoins),
              ),
            );
            return;
          }

          showDialog<void>(
            context: context,
            builder: (_) => WatchRewardAdDialog(
              onTapYesButton: () {
                //showAd
                context.read<RewardedAdCubit>().showAd(
                      context: context,
                      onAdDismissedCallback: _addCoinsAfterRewardAd,
                    );
              },
            ),
          );
          return;
        }
        if (selectedCategory == selectCategoryKey &&
            context
                .read<SystemConfigCubit>()
                .isCategoryEnabledForRandomBattle) {
          UiUtils.errorMessageDialog(
            context,
            context.tr(pleaseSelectCategoryKey),
          );
          return;
        }

        Navigator.of(context).pushReplacementNamed(
          Routes.battleRoomFindOpponent,
          arguments: selectedCategoryId,
        );
      },
    );
  }

  Container _buildEntryFeesAndCoinsCard(BuildContext context, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      width: size.width,
      height: size.height * .14,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "${context.tr("entryFeesLbl")!}\n",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(.4),
                  ),
                ),
                TextSpan(
                  text:
                      '${context.read<SystemConfigCubit>().randomBattleEntryCoins} ${context.tr(coinsLbl)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeights.bold,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            indent: size.width * .07,
            endIndent: size.width * .07,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${context.tr(currentCoinsKey)!}\n',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.regular,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(.4),
                  ),
                ),
                WidgetSpan(
                  child: BlocBuilder<UserDetailsCubit, UserDetailsState>(
                    bloc: context.read<UserDetailsCubit>(),
                    builder: (context, state) {
                      return state is UserDetailsFetchSuccess
                          ? Text(
                              '${context.read<UserDetailsCubit>().getCoins()!} ${context.tr(coinsLbl)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeights.bold,
                                color: Theme.of(context).colorScheme.onTertiary,
                              ),
                            )
                          : const SizedBox();
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

  Row _buildOrDivider(BuildContext context, Size size) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
            thickness: .5,
            indent: size.width * .1,
            endIndent: size.width * .05,
          ),
        ),
        Text(
          context.tr(orLbl)!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeights.regular,
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(.6),
            thickness: .5,
            indent: size.width * .05,
            endIndent: size.width * .1,
          ),
        ),
      ],
    );
  }
}
