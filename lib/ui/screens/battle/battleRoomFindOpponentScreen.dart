import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/finding_opponent_animation.dart';
import 'package:flutterquiz/ui/screens/battle/widgets/userFoundMapContainer.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/ui/widgets/exitGameDialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BattleRoomFindOpponentScreen extends StatefulWidget {
  const BattleRoomFindOpponentScreen({required this.categoryId, super.key});

  final String categoryId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BattleRoomFindOpponentScreen(
        categoryId: routeSettings.arguments! as String,
      ),
    );
  }

  @override
  State<BattleRoomFindOpponentScreen> createState() =>
      _BattleRoomFindOpponentScreenState();
}

class _BattleRoomFindOpponentScreenState
    extends State<BattleRoomFindOpponentScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late ScrollController scrollController = ScrollController();
  late AnimationController letterAnimationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late AnimationController quizCountDownAnimationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  late Animation<int> quizCountDownAnimation =
      IntTween(begin: 3, end: 0).animate(quizCountDownAnimationController);
  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..forward();
  late Animation<double> mapAnimation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animationController,
      curve: const Interval(0, 0.4, curve: Curves.easeInOut),
    ),
  );
  late Animation<double> playerDetailsAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeInOut),
    ),
  );
  late Animation<double> findingOpponentStatusAnimation =
      Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.7, 1, curve: Curves.easeInOut),
    ),
  );

  //to store images of map so we can simulate the mapSlideAnimation
  late List<String> images = [];

  //
  late bool waitForOpponent = true;

  //waiting time to find opponent to join
  late int waitingTime =
      context.read<SystemConfigCubit>().randomBattleOpponentSearchDuration;
  Timer? waitForOpponentTimer;

  bool playWithBot = false;

  @override
  void initState() {
    super.initState();
    addImages();
    WakelockPlus.enable();
    Future.delayed(const Duration(milliseconds: 1000), () {
      //search for battle room after initial animation completed
      searchBattleRoom();
      startScrollImageAnimation();
      letterAnimationController.repeat();
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    //delete battle room if user press home button or move from battleOpponentFind screen
    if (state == AppLifecycleState.paused) {
      context.read<BattleRoomCubit>().deleteBattleRoom(isGroupBattle: false);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    letterAnimationController.dispose();
    quizCountDownAnimationController.dispose();
    animationController.dispose();
    waitForOpponentTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);

    //we need to set the current route to home.
    //so room will be delete only if user has left this screen and
    //room created afterwards
    if (Routes.currentRoute == Routes.battleRoomFindOpponent) {
      Routes.currentRoute = Routes.home;
      WakelockPlus.disable();
    }
    super.dispose();
  }

  void searchBattleRoom() {
    final userProfile = context.read<UserDetailsCubit>().getUserProfile();
    context.read<BattleRoomCubit>().searchRoom(
          categoryId: widget.categoryId,
          name: userProfile.name!,
          profileUrl: userProfile.profileUrl!,
          uid: userProfile.userId!,
          questionLanguageId: UiUtils.getCurrentQuestionLanguageId(context),
          entryFee: context.read<SystemConfigCubit>().randomBattleEntryCoins,
        );
  }

  void addImages() {
    for (var i = 0; i < 20; i++) {
      images.add(Assets.mapFinding);
    }
  }

  //this will be call only when user has created room successfully
  void setWaitForOpponentTimer() {
    // print("WaitingTimer:- $waitingTime");
    // print("WaitingTimer:- ${scrollController.position}");
    waitForOpponentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (waitingTime == 0) {
        //delete room so other user can not join
        context.read<BattleRoomCubit>().deleteBattleRoom(isGroupBattle: false);
        //stop other activities
        letterAnimationController.stop();
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
        setState(() {
          waitForOpponent = false;
        });

        timer.cancel();
      } else {
        waitingTime--;
      }
    });
  }

  Future<void> startScrollImageAnimation() async {
    //if scroll controller is attached to any scrollable widgets
    if (scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;

      if (maxScroll == 0) {
        await startScrollImageAnimation();
      }

      await scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 32),
        curve: Curves.linear,
      );
    }
  }

  void retryToSearchBattleRoom() {
    scrollController.dispose();
    setState(() {
      scrollController = ScrollController();
      waitingTime =
          context.read<SystemConfigCubit>().randomBattleOpponentSearchDuration;
      waitForOpponent = true;
    });
    letterAnimationController.repeat();
    Future.delayed(
      const Duration(milliseconds: 100),
      startScrollImageAnimation,
    );
    setWaitForOpponentTimer();
    searchBattleRoom();
  }

  //
  Widget _buildUserDetails(String name, String profileUrl) {
    final size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            //
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              height: size.height * (0.15),
            ),
            QImage.circular(
              height: size.height * (0.14),
              imageUrl: profileUrl,
              width: size.width * (0.3),
            ),
          ],
        ),
        const SizedBox(
          height: 2.5,
        ),
        Container(
          alignment: Alignment.center,
          width: size.width * (0.3),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserDetails() {
    return Container(
      margin: EdgeInsetsDirectional.only(
        end: MediaQuery.of(context).size.width * (0.45),
      ),
      child: _buildUserDetails(
        context.read<UserDetailsCubit>().getUserProfile().name!,
        context.read<UserDetailsCubit>().getUserProfile().profileUrl!,
      ),
    );
  }

  //
  Widget _buildOpponentUserDetails() {
    return Container(
      margin: EdgeInsetsDirectional.only(
        start: MediaQuery.of(context).size.width * (0.45),
      ),
      child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
        bloc: context.read<BattleRoomCubit>(),
        builder: (context, state) {
          if (state is BattleRoomFailure) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  height: MediaQuery.of(context).size.height * (0.15),
                  child: Center(
                    child: Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
                const SizedBox(height: 2.5),
                Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * (0.3),
                  child: Text(
                    '....',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is BattleRoomUserFound) {
            final opponentUserDetails =
                context.read<BattleRoomCubit>().getOpponentUserDetails(
                      context.read<UserDetailsCubit>().userId(),
                    );
            return _buildUserDetails(
              opponentUserDetails.name,
              opponentUserDetails.profileUrl,
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FindingOpponentAnimation(
                animationController: letterAnimationController,
              ),
              const SizedBox(height: 2.5),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * (0.3),
                child: Text(
                  '....',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  //to show user status of process (opponent found or finding opponent etc)
  Widget _buildFindingOpponentStatus() {
    return waitForOpponent
        ? FadeTransition(
            opacity: findingOpponentStatusAnimation,
            child: SlideTransition(
              position: findingOpponentStatusAnimation.drive(
                Tween<Offset>(
                  begin: const Offset(0.075, 0),
                  end: Offset.zero,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * (0.05),
                  ),
                  child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
                    bloc: context.read<BattleRoomCubit>(),
                    builder: (context, state) {
                      if (state is BattleRoomFailure) {
                        return Container();
                      }
                      if (state is! BattleRoomUserFound) {
                        return Text(
                          context.tr('findingOpponentLbl')!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return Text(
                        context.tr('foundOpponentLbl')!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  //to display map animation
  Widget _buildFindingMap() {
    return Align(
      key: const Key('userFinding'),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: IgnorePointer(
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * (0.6),
              child: Row(
                children: images
                    .map(
                      (e) => Image.asset(
                        e,
                        fit: BoxFit.cover,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //build details when opponent found
  Widget _buildUserFoundDetails() {
    return Align(
      key: const Key('userFound'),
      alignment: Alignment.topCenter,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * (0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * (0.05)),
            Text(
              context.tr('getReadyLbl')!,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 25,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * (0.025)),
            AnimatedBuilder(
              animation: quizCountDownAnimationController,
              builder: (context, child) {
                return Text(
                  quizCountDownAnimation.value == 0
                      ? context.tr('bestOfLuckLbl')!
                      : '${quizCountDownAnimation.value}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * (0.0275)),
            const UserFoundMapContainer(),
          ],
        ),
      ),
    );
  }

  //show details when opponent not found
  Widget _buildOpponentNotFoundDetails() {
    return Align(
      alignment: Alignment.topCenter,
      key: const Key('userNotFound'),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * (0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * (0.05)),
            if (playWithBot) ...[
              Text(
                context.tr('battlePreparingLbl')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * (0.025)),
            ] else ...[
              Text(
                context.tr('opponentNotFoundLbl')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * (0.025)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomRoundedButton(
                    widthPercentage: 0.375,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: context.tr('playWithBotLbl'),
                    radius: 5,
                    showBorder: false,
                    height: 40,
                    titleColor: Theme.of(context).colorScheme.surface,
                    elevation: 5,
                    onTap: () {
                      /// To avoid button Spamming
                      if (playWithBot) return;

                      setState(() => playWithBot = true);

                      final userProfile =
                          context.read<UserDetailsCubit>().getUserProfile();
                      context.read<BattleRoomCubit>().createRoomWithBot(
                            categoryId: widget.categoryId,
                            charType: context
                                .read<SystemConfigCubit>()
                                .oneVsOneBattleRoomCodeCharType,
                            name: userProfile.name,
                            uid: userProfile.userId,
                            profileUrl: userProfile.profileUrl,
                            botName: context.tr('botNameLbl'),
                            questionLanguageId:
                                UiUtils.getCurrentQuestionLanguageId(context),
                            context: context,
                          );
                    },
                  ),
                  CustomRoundedButton(
                    widthPercentage: 0.375,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: context.tr('retryLbl'),
                    radius: 5,
                    showBorder: false,
                    height: 40,
                    titleColor: Theme.of(context).colorScheme.surface,
                    elevation: 5,
                    onTap: retryToSearchBattleRoom,
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * (0.03)),
            ],
            const UserFoundMapContainer(),
          ],
        ),
      ),
    );
  }

  //to build details for findinng opponent with map
  Widget _buildFindingOpponentMapDetails() {
    return FadeTransition(
      opacity: mapAnimation,
      child: BlocBuilder<BattleRoomCubit, BattleRoomState>(
        bloc: context.read<BattleRoomCubit>(),
        builder: (context, state) {
          var child = _buildFindingMap();
          if (state is BattleRoomFailure) {
            child = ErrorContainer(
              showBackButton: true,
              errorMessage:
                  convertErrorCodeToLanguageKey(state.errorMessageCode),
              errorMessageColor: Theme.of(context).primaryColor,
              onTapRetry: () {
                retryToSearchBattleRoom();
              },
              showErrorImage: true,
            );
          }
          if (state is BattleRoomUserFound) {
            child = _buildUserFoundDetails();
          }
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: waitForOpponent ? child : _buildOpponentNotFoundDetails(),
          );
        },
      ),
    );
  }

  Widget _buildVsImageContainer() {
    return Image.asset(
      Assets.vsIcon,
      fit: BoxFit.cover,
    );
  }

  Widget _buildPlayersDetails() {
    return FadeTransition(
      opacity: playerDetailsAnimation,
      child: SlideTransition(
        position: playerDetailsAnimation.drive(
          Tween<Offset>(begin: const Offset(0.075, 0), end: Offset.zero),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * (0.125),
            ),
            height: MediaQuery.of(context).size.height * (0.2),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildCurrentUserDetails(),
                _buildOpponentUserDetails(),
                _buildVsImageContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          top: MediaQuery.of(context).padding.top,
        ),
        child: CustomBackButton(
          onTap: () {
            //
            final battleRoomCubit = context.read<BattleRoomCubit>();
            //if user has found opponent then do not allow to go back
            if (battleRoomCubit.state is BattleRoomUserFound) {
              return;
            }

            showDialog<void>(
              context: context,
              builder: (_) => ExitGameDialog(
                onTapYes: () {
                  battleRoomCubit.deleteBattleRoom(isGroupBattle: false);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          iconColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final battleRoomCubit = context.read<BattleRoomCubit>();

    return PopScope(
      canPop: battleRoomCubit.state is! BattleRoomUserFound,
      onPopInvoked: (didPop) {
        if (didPop) return;

        showDialog<void>(
          context: context,
          builder: (_) => ExitGameDialog(
            onTapYes: () {
              battleRoomCubit.deleteBattleRoom(isGroupBattle: false);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        );
      },
      child: Scaffold(
        body: BlocListener<BattleRoomCubit, BattleRoomState>(
          bloc: battleRoomCubit,
          listener: (context, state) async {
            //start timer for waiting user only room created successfully
            if (state is BattleRoomCreated) {
              if (waitForOpponentTimer == null) {
                setWaitForOpponentTimer();
              }
            } else if (state is BattleRoomUserFound) {
              //if opponent found
              waitForOpponentTimer?.cancel();
              await Future<void>.delayed(const Duration(milliseconds: 500));
              await quizCountDownAnimationController.forward();

              ///
              await WakelockPlus.disable();
              await Navigator.of(context).pushReplacementNamed(
                Routes.battleRoomQuiz,
                arguments: {
                  'quiz_type': QuizTypes.randomBattle,
                  'play_with_bot': playWithBot,
                },
              );
            } else if (state is BattleRoomFailure) {
              if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                await showAlreadyLoggedInDialog(context);
              }
            }
          },
          child: Stack(
            children: [
              _buildFindingOpponentMapDetails(),
              _buildPlayersDetails(),
              _buildFindingOpponentStatus(),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
