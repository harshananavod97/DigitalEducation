import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/referAndEarnCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/home/Advanced_Level_Screens/AL_Home_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Agriculture/Agriculture_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Art/Art_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Buddhism/Buddhism_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Catholic/Catholic_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Civics/Civic_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Commerce/Commerce_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Dancing%20Baratha/Dancing_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Dancing%20Oriental/Dancing_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Design%20And%20Construction/DesignAndConstruction_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Drama/Drama_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Econmic/Economic_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Electronic%20Electrical/ElectronicAndElectrical_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/English/English_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/EnterPrenerShip/EnterPrenerShip_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Geography/Geography_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Health%20Science/Health_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Ict/ICT_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Islam/Islam_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Maths/Maths_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Media/Media_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Music%20Carnatic/Music_Carthanic_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Music%20Orental/Music_Orental_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/OL%20Design%20And%20Material/DandM_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Science/Sclience_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Sinhala/Sinhala_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/Ordernery_Level_Screens/Subjects/Tamil/Tamil_OL_Screen.dart';
import 'package:flutterquiz/ui/screens/home/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/bannerAdContainer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdeneryLevelHomeScreen extends StatefulWidget {
  const OrdeneryLevelHomeScreen({required this.isGuest, super.key});

  final bool isGuest;

  @override
  State<OrdeneryLevelHomeScreen> createState() =>
      _OrdeneryLevelHomeScreenState();

  static Route<OrdeneryLevelHomeScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child:
            OrdeneryLevelHomeScreen(isGuest: routeSettings.arguments! as bool),
      ),
    );
  }
}

class _OrdeneryLevelHomeScreenState extends State<OrdeneryLevelHomeScreen>
    with WidgetsBindingObserver {
  /// Quiz Zone globals
  int oldCategoriesToShowCount = 0;
  bool isCateListExpanded = false;
  bool canExpandCategoryList = false;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<String> battleName = ['groupPlay', 'battleQuiz'];

  List<String> battleImg = [Assets.groupBattleIcon, Assets.oneVsOneIcon];

  List<String> examSelf = ['exam', 'selfChallenge'];

  List<String> examSelfDesc = ['desExam', 'challengeYourselfLbl'];

  List<String> examSelfImg = [Assets.examQuizIcon, Assets.selfChallengeIcon];

  List<String> battleDesc = ['desGroupPlay', 'desBattleQuiz'];

  List<String> playDifferentZone = [
    'dailyQuiz',
    'funAndLearn',
    'guessTheWord',
    'audioQuestions',
    'mathMania',
    'truefalse',
  ];

  List<String> playDifferentImg = [
    Assets.dailyQuizIcon,
    Assets.funNLearnIcon,
    Assets.guessTheWordIcon,
    Assets.audioQuizIcon,
    Assets.mathsQuizIcon,
    Assets.trueFalseQuizIcon,
  ];

  List<String> playDifferentZoneDesc = [
    'desDailyQuiz',
    'desFunAndLearn',
    'desGuessTheWord',
    'desAudioQuestions',
    'desMathMania',
    'desTrueFalse',
  ];

  // Screen dimensions
  double get scrWidth => MediaQuery.of(context).size.width;

  double get scrHeight => MediaQuery.of(context).size.height;

  // OrdeneryLevelHomeScreen horizontal margin, change from here
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  double get _statusBarPadding => MediaQuery.of(context).padding.top;

  // TextStyles
  // check build() method
  late var _boldTextStyle = TextStyle(
    fontWeight: FontWeights.bold,
    fontSize: 18,
    color: Theme.of(context).colorScheme.onTertiary,
  );

  ///
  late String _currLangId;
  late final SystemConfigCubit _sysConfigCubit;
  final _quizZoneId =
      UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.quizZone);

  Future<void> showrewardadd(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int clickCount = (prefs.getInt('clickCount') ?? 0) + 1;

    if (clickCount >= 10) {
      await context.read<RewardedAdCubit>().showDailyAd(context: context);
      clickCount = 0; // Reset the counter after showing the ad
    }

    await prefs.setInt('clickCount', clickCount);
  }

  @override
  void initState() {
    showrewardadd(context);
    super.initState();
    showAppUnderMaintenanceDialog();
    setQuizMenu();
    _initLocalNotification();
    checkForUpdates();
    setupInteractedMessage();

    /// Create Ads
    Future.delayed(Duration.zero, () async {
      await context.read<RewardedAdCubit>().createDailyRewardAd(context);
      context.read<InterstitialAdCubit>().createInterstitialAd(context);
    });

    WidgetsBinding.instance.addObserver(this);

    ///
    _currLangId = UiUtils.getCurrentQuestionLanguageId(context);
    _sysConfigCubit = context.read<SystemConfigCubit>();
    final quizCubit = context.read<QuizCategoryCubit>();
    final quizZoneCubit = context.read<QuizoneCategoryCubit>();

    if (widget.isGuest) {
      quizCubit.getQuizCategory(languageId: _currLangId, type: _quizZoneId);
      quizZoneCubit.getQuizCategory(languageId: _currLangId);
    } else {
      fetchUserDetails();

      quizCubit.getQuizCategoryWithUserId(
        languageId: _currLangId,
        type: _quizZoneId,
      );
      quizZoneCubit.getQuizCategoryWithUserId(languageId: _currLangId);
      context.read<ContestCubit>().getContest(languageId: _currLangId);
    }
  }

  void showAppUnderMaintenanceDialog() {
    Future.delayed(Duration.zero, () {
      if (_sysConfigCubit.isAppUnderMaintenance) {
        showDialog<void>(
          context: context,
          builder: (_) => const AppUnderMaintenanceDialog(),
        );
      }
    });
  }

  Future<void> _initLocalNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payLoad) {
        log('For ios version <= 9 notification will be shown here');
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapLocalNotification,
    );

    /// Request Permissions for IOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  void setQuizMenu() {
    Future.delayed(Duration.zero, () {
      if (!_sysConfigCubit.isDailyQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'dailyQuiz');
        playDifferentImg.removeWhere((e) => e == Assets.dailyQuizIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desDailyQuiz');
      }

      if (!_sysConfigCubit.isTrueFalseQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'truefalse');
        playDifferentImg.removeWhere((e) => e == Assets.trueFalseQuizIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desTrueFalse');
      }

      if (!_sysConfigCubit.isFunNLearnEnabled) {
        playDifferentZone.removeWhere((e) => e == 'funAndLearn');
        playDifferentImg.removeWhere((e) => e == Assets.funNLearnIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desFunAndLearn');
      }

      if (!_sysConfigCubit.isGuessTheWordEnabled) {
        playDifferentZone.removeWhere((e) => e == 'guessTheWord');
        playDifferentImg.removeWhere((e) => e == Assets.guessTheWordIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desGuessTheWord');
      }

      if (!_sysConfigCubit.isAudioQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'audioQuestions');
        playDifferentImg.removeWhere((e) => e == Assets.guessTheWordIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desAudioQuestions');
      }

      if (!_sysConfigCubit.isMathQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'mathMania');
        playDifferentImg.removeWhere((e) => e == Assets.mathsQuizIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desMathMania');
      }

      if (!_sysConfigCubit.isExamQuizEnabled) {
        examSelf.removeWhere((e) => e == 'exam');
        examSelfDesc.removeWhere((e) => e == 'desExam');
        examSelfImg.removeWhere((e) => e == Assets.examQuizIcon);
      }

      if (!_sysConfigCubit.isSelfChallengeQuizEnabled) {
        examSelf.removeWhere((e) => e == 'selfChallenge');
        examSelfDesc.removeWhere((e) => e == 'challengeYourselfLbl');
        examSelfImg.removeWhere((e) => e == Assets.selfChallengeIcon);
      }

      if (!_sysConfigCubit.isGroupBattleEnabled) {
        battleName.removeWhere((e) => e == 'groupPlay');
        battleImg.removeWhere((e) => e == Assets.groupBattleIcon);
        battleDesc.removeWhere((e) => e == 'desGroupPlay');
      }

      if (!_sysConfigCubit.isOneVsOneBattleEnabled &&
          !_sysConfigCubit.isRandomBattleEnabled) {
        battleName.removeWhere((e) => e == 'battleQuiz');
        battleImg.removeWhere((e) => e == Assets.groupBattleIcon);
        battleDesc.removeWhere((e) => e == 'desBattleQuiz');
      }
      setState(() {});
    });
  }

  late bool showUpdateContainer = false;

  Future<void> checkForUpdates() async {
    await Future<void>.delayed(Duration.zero);
    if (_sysConfigCubit.isForceUpdateEnable) {
      try {
        final forceUpdate =
            await UiUtils.forceUpdate(_sysConfigCubit.appVersion);

        if (forceUpdate) {
          setState(() => showUpdateContainer = true);
        }
      } catch (e) {
        log('Force Update Error', error: e);
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        provisional: true,
      );
    } else {
      final isGranted = (await Permission.notification.status).isGranted;
      if (!isGranted) await Permission.notification.request();
    }
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(UiUtils.onBackgroundMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Notification arrives : ${message.toMap()}');
      final data = message.data;
      log(data.toString(), name: 'notification data msg');
      final title = data['title'].toString();
      final body = data['body'].toString();
      final type = data['type'].toString();
      final image = data['image'].toString();

      //if notification type is badges then update badges in cubit list
      if (type == 'badges') {
        Future.delayed(Duration.zero, () {
          context.read<BadgesCubit>().unlockBadge(data['badge_type'] as String);
        });
      }

      if (type == 'payment_request') {
        Future.delayed(Duration.zero, () {
          context.read<UserDetailsCubit>().updateCoins(
                addCoin: true,
                coins: int.parse(data['coins'] as String),
              );
        });
      }
      log(image, name: 'notification image data');
      //payload is some data you want to pass in local notification
      if (image != 'null' && image.isNotEmpty) {
        log('image ${image.runtimeType}');
        generateImageNotification(title, body, image, type, type);
      } else {
        generateSimpleNotification(title, body, type);
      }
    });
  }

  //quiz_type according to the notification category
  QuizTypes _getQuizTypeFromCategory(String category) {
    return switch (category) {
      'audio-question-category' => QuizTypes.audioQuestions,
      'guess-the-word-category' => QuizTypes.guessTheWord,
      'fun-n-learn-category' => QuizTypes.funAndLearn,
      _ => QuizTypes.quizZone,
    };
  }

  // notification type is category then move to category screen
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (message.data['type'].toString().contains('category')) {
        await Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType':
                _getQuizTypeFromCategory(message.data['type'] as String),
          },
        );
      } else if (message.data['type'] == 'badges') {
        //if user open app by tapping
        UiUtils.updateBadgesLocally(context);
        await Navigator.of(context).pushNamed(Routes.badges);
      } else if (message.data['type'] == 'payment_request') {
        await Navigator.of(context).pushNamed(Routes.wallet);
      }
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> _onTapLocalNotification(NotificationResponse? payload) async {
    final type = payload!.payload ?? '';
    if (type == 'badges') {
      await Navigator.of(context).pushNamed(Routes.badges);
    } else if (type.contains('category')) {
      await Navigator.of(context).pushNamed(
        Routes.category,
        arguments: {
          'quizType': _getQuizTypeFromCategory(type),
        },
      );
    } else if (type == 'payment_request') {
      await Navigator.of(context).pushNamed(Routes.wallet);
    }
  }

  Future<void> generateImageNotification(
    String title,
    String msg,
    String image,
    String payloads,
    String type,
  ) async {
    final largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true,
    );
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      packageName,
      appName,
      icon: '@drawable/ic_notification',
      channelDescription: appName,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      msg,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
    String title,
    String body,
    String payloads,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      packageName, //channel id
      appName, //channel name
      channelDescription: appName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  @override
  void dispose() {
    ProfileManagementLocalDataSource.updateReversedCoins(0);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);
    } else {
      ProfileManagementLocalDataSource.updateReversedCoins(0);
    }
  }

  void _onTapProfile() => Navigator.of(context).pushNamed(
        Routes.menuScreen,
        arguments: widget.isGuest,
      );

  void _onTapLeaderboard() => Navigator.of(context).pushNamed(
        widget.isGuest ? Routes.login : Routes.leaderBoard,
      );

  void _onPressedZone(String index) {
    if (widget.isGuest) {
      _showLoginDialog();
      return;
    }

    switch (index) {
      case 'dailyQuiz':
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.dailyQuiz,
            'numberOfPlayer': 1,
            'quizName': 'Daily Quiz',
          },
        );
        return;
      case 'funAndLearn':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.funAndLearn,
          },
        );
        return;
      case 'guessTheWord':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.guessTheWord,
          },
        );
        return;
      case 'audioQuestions':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.audioQuestions,
          },
        );
        return;
      case 'mathMania':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.mathMania,
          },
        );
        return;
      case 'truefalse':
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.trueAndFalse,
            'numberOfPlayer': 1,
            'quizName': 'True/False Quiz',
          },
        );
        return;
    }
  }

  void _onPressedSelfExam(String index) {
    if (widget.isGuest) {
      _showLoginDialog();
      return;
    }

    if (index == 'exam') {
      context.read<ExamCubit>().updateState(ExamInitial());
      Navigator.of(context).pushNamed(Routes.exams);
    } else if (index == 'selfChallenge') {
      context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
      context.read<SubCategoryCubit>().updateState(SubCategoryInitial());
      Navigator.of(context).pushNamed(Routes.selfChallenge);
    }
  }

  void _onPressedBattle(String index) {
    if (widget.isGuest) {
      _showLoginDialog();
      return;
    }

    context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
    if (index == 'groupPlay') {
      context
          .read<MultiUserBattleRoomCubit>()
          .updateState(MultiUserBattleRoomInitial());

      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (context) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
            child: CreateOrJoinRoomScreen(
              quizType: QuizTypes.groupPlay,
              title: context.tr('groupPlay')!,
            ),
          ),
        ),
      );
    } else if (index == 'battleQuiz') {
      context.read<BattleRoomCubit>().updateState(
            BattleRoomInitial(),
            cancelSubscription: true,
          );

      if (_sysConfigCubit.isRandomBattleEnabled) {
        Navigator.of(context).pushNamed(Routes.randomBattle);
      } else {
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
      }
    }
  }

  Future<void> _showLoginDialog() {
    return showLoginDialog(
      context,
      onTapYes: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(Routes.login);
      },
    );
  }

  late String _userName = context.tr('guest')!;
  late String _userProfileImg = Assets.profile('2.png');

  Widget _buildProfileContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: _onTapProfile,
        child: Container(
          margin: EdgeInsets.only(
            top: _statusBarPadding * .2,
            left: hzMargin,
            right: hzMargin,
          ),
          width: scrWidth,
          child: LayoutBuilder(
            builder: (_, constraint) {
              final size = MediaQuery.of(context).size;

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    width: constraint.maxWidth * 0.15,
                    height: constraint.maxWidth * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.3),
                      ),
                    ),
                    child: QImage.circular(imageUrl: _userProfileImg),
                  ),
                  SizedBox(width: size.width * .03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: constraint.maxWidth * 0.5,
                        child: Text(
                          '${context.tr(helloKey)!} $_userName',
                          maxLines: 1,
                          style: _boldTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        context.tr(letsPlay)!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// LeaderBoard
                  Container(
                    width: size.width * 0.11,
                    height: size.width * 0.11,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: _onTapLeaderboard,
                      icon: widget.isGuest
                          ? const Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                            )
                          : QImage(
                              imageUrl: Assets.leaderboardIcon,
                              color: Colors.white,
                              width: size.width * 0.08,
                              height: size.width * 0.08,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// Settings
                  Container(
                    width: size.width * 0.11,
                    height: size.width * 0.11,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          Routes.menuScreen,
                          arguments: widget.isGuest,
                        );
                      },
                      icon: QImage(
                        imageUrl: Assets.settingsIcon,
                        color: Colors.white,
                        width: size.width * 0.08,
                        height: size.width * 0.08,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hzMargin),
          child: Row(
            children: [
              Text(
                context.tr('quizZone')!,
                style: _boldTextStyle,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.isGuest
                      ? _showLoginDialog()
                      : Navigator.of(context).pushNamed(
                          Routes.category,
                          arguments: {'quizType': QuizTypes.quizZone},
                        );
                },
                child: Text(
                  context.tr(viewAllKey) ?? viewAllKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    margin: EdgeInsets.only(
                      left: hzMargin,
                      right: hzMargin,
                      top: 10,
                      bottom: 26,
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: quizZoneCategories(),
                  ),
                ),

                /// Expand Arrow
                if (canExpandCategoryList) ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    // Position the center bottom arrow, from here
                    bottom: -9,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent),
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isCateListExpanded = !isCateListExpanded;
                        }),
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            !isCateListExpanded
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget quizZoneCategories() {
    return BlocConsumer<QuizoneCategoryCubit, QuizoneCategoryState>(
      bloc: context.read<QuizoneCategoryCubit>(),
      listener: (context, state) {
        if (state is QuizoneCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is QuizoneCategoryFailure) {
          return ErrorContainer(
            showRTryButton: false,
            showBackButton: false,
            showErrorImage: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: () {
              context.read<QuizoneCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                  );
            },
          );
        }

        if (state is QuizoneCategorySuccess) {
          final categories = state.categories;
          final int categoriesToShowCount;

          /// Min/Max Categories to Show.
          const minCount = 7;
          const maxCount = 5;

          /// need to check old cate list with new cate list, when we change languages.
          /// and rebuild the list.
          if (oldCategoriesToShowCount != categories.length) {
            Future.delayed(Duration.zero, () {
              oldCategoriesToShowCount = categories.length;
              canExpandCategoryList = oldCategoriesToShowCount > minCount;
              setState(() {});
            });
          }

          if (!isCateListExpanded) {
            categoriesToShowCount =
                categories.length <= minCount ? categories.length : minCount;
          } else {
            categoriesToShowCount =
                categories.length <= maxCount ? categories.length : maxCount;
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 10),
            shrinkWrap: true,
            itemCount: categoriesToShowCount,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              final category = categories[i];

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                onTap: () {
                  if (widget.isGuest) {
                    _showLoginDialog();
                    return;
                  }

                  if (category.isPremium && !category.hasUnlocked) {
                    showUnlockPremiumCategoryDialog(
                      context,
                      categoryId: category.id!,
                      categoryName: category.categoryName!,
                      requiredCoins: category.requiredCoins,
                      isQuizZone: true,
                    );
                    return;
                  }

                  //noOf means how many subcategory it has
                  //if subcategory is 0 then check for level
                  if (category.noOf == '0') {
                    //means this category does not have level
                    if (category.maxLevel == '0') {
                      //direct move to quiz screen pass level as 0
                      Navigator.of(context).pushNamed(
                        Routes.quiz,
                        arguments: {
                          'numberOfPlayer': 1,
                          'quizType': QuizTypes.quizZone,
                          'categoryId': category.id,
                          'subcategoryId': '',
                          'level': '0',
                          'subcategoryMaxLevel': '0',
                          'unlockedLevel': 0,
                          'contestId': '',
                          'comprehensionId': '',
                          'quizName': 'Quiz Zone',
                          'showRetryButton': category.noOfQues! != '0',
                        },
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        Routes.levels,
                        arguments: {
                          'Category': category,
                        },
                      );
                    }
                  } else {
                    Navigator.of(context).pushNamed(
                      Routes.subcategoryAndLevel,
                      arguments: {
                        'category_id': category.id,
                        'category_name': category.categoryName,
                      },
                    );
                  }
                },
                horizontalTitleGap: 15,
                leading: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: QImage(
                        imageUrl: category.image!,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                /// right_arrow
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PremiumCategoryAccessBadge(
                      hasUnlocked: category.hasUnlocked,
                      isPremium: category.isPremium,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                  ],
                ),
                title: Text(
                  category.categoryName!,
                  style: _boldTextStyle.copyWith(fontSize: 16),
                ),
                subtitle: Text(
                  category.noOf == '0'
                      ? "${context.tr("questionLbl")}: ${category.noOfQues!}"
                      : "${context.tr('subCategoriesLbl')}: ${category.noOf}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.6),
                  ),
                ),
              );
            },
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildBattle() {
    return battleName.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Zone Title: Battle
                Text(
                  context.tr(battleOfTheDayKey) ?? battleOfTheDayKey, //
                  style: _boldTextStyle,
                ),

                /// Categories
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    battleName.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedBattle(battleName[i]),
                      title: context.tr(battleName[i])!,
                      desc: context.tr(battleDesc[i])!,
                      img: battleImg[i],
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildDailyAds() {
    var clicked = false;
    return BlocBuilder<RewardedAdCubit, RewardedAdState>(
      builder: (context, state) {
        if (state is RewardedAdLoaded &&
            context.read<UserDetailsCubit>().isDailyAdAvailable) {
          return GestureDetector(
            onTap: () async {
              if (!clicked) {
                await context
                    .read<RewardedAdCubit>()
                    .showDailyAd(context: context);
                clicked = true;
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: hzMargin,
                right: hzMargin,
                top: scrHeight * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.background,
              ),
              width: scrWidth,
              height: scrWidth * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      Assets.dailyCoins,
                      width: scrWidth * .23,
                      height: scrWidth * .23,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('dailyAdsTitle')!,
                        style: TextStyle(
                          fontWeight: FontWeights.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${context.tr("get")!} "
                        '${_sysConfigCubit.coinsPerDailyAdView} '
                        "${context.tr("dailyAdsDesc")!}",
                        style: TextStyle(
                          fontWeight: FontWeights.regular,
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSubStreamList() {
    List<Widget> pages = [
      Science_Home_OL(isGuest: false),
      Maths_Home_OL(isGuest: false),
      Art_Home_OL(isGuest: false),
      Sinhala_Home_OL(isGuest: false),
      Buddhism_Home_OL(isGuest: false),
      Health_Home_OL(isGuest: false),
      Commerce_Home_OL(isGuest: false),
      English_Home_OL(isGuest: false),
      Dancing_Home_OL(isGuest: false),
      Drama_Home_OL(isGuest: false),
      Tamil_Home_OL(isGuest: false),
      ICT_Home_OL(isGuest: false),
      Dancing_Bartha_Home_OL(isGuest: false),
      Agriculture_Home_OL(isGuest: false),
      Economic_Home_OL(isGuest: false),
      Catholic_Home_OL(
        isGuest: false,
      ),
      Civic_Home_OL(isGuest: false),
      Islam_Home_OL(isGuest: false),
      Geography_Home_OL(isGuest: false),
      Media_Home_OL(isGuest: false),
      Music_Orental_Home_OL(isGuest: false),
      Music_Carnatic_Home_OL(isGuest: false),
      DesignandMaterial_Home_OL(isGuest: false),
      DesignConstruction_Home_OL(
        isGuest: false,
      ),
      EnterPrenerShip_Home_OL(isGuest: false),
      ElectronicAndElectrical_Home_OL(
        isGuest: false,
      )
    ];
    List<String> streamNames = [
      "Science",
      "Maths",
      "Art",
      "Sinhala",
      "Buddhism",
      "Helth Science",
      "Business And Accounting",
      "English",
      "Dancing Orintal",
      "Drama",
      "Tamil",
      "ICT",
      "Dancing Baratha",
      "Agriculture",
      "Economic",
      "Catholic",
      "Civic",
      "Islam",
      "Geography",
      "Media",
      "Music Orental",
      "Music Carnatic",
      "Design & Material",
      "Ol_Design & Construction",
      "Entrepreneurship Studies",
      "Electrical & Electronic"
    ];
    List<String> TamilstreamNames = [
      "விஞ்ஞானம்",
      "கணிதம்",
      "சித்திரம்",
      "சிங்களமொழியும்",
      "பௌத்தம்",
      "சுகாதாரமும் உடற்கல்வியும்",
      "வணிகக் கல்வியும் கணக்கீடும்",
      "English",
      "(சுதேச)நடனம்",
      "அரங்கியலும்நாடகமும்",
      "Tamil",
      "தொழினுட்பவியல் தொடர்பாடல்தகவல்,",
      "பரதநாட்டியம்",
      "விவசாயமும்",
      "பொருளியல்மனைப்",
      "திருமறைகத்தோலிக்கத்",
      "கல்விகுடியியற்",
      "இஸ்லாம்",
      "புவியியல்",
      "தொடர்பாடலும் ஊடகக் கல்வியும்",
      "(கீழைத்தேய)சங்கீதம்",
      "கர்நாடக சங்கீதம்",
      "இயந்திரத்வடிவமைப்பும்",
      "நிருமாணத்வடிவமைப்பும்",
      "கற்கைமுயற்சியாண்மைக்",
      "இலத்திரனியல் மின்வடிவமைப்பும்"
    ];

    List<String> EnglishstreamNames = [
      "Science",
      "Maths",
      "Art",
      "Sinhala",
      "Buddhism",
      "Helth Science",
      "Business And Accounting",
      "English",
      "Dancing Orintal",
      "Drama",
      "Tamil",
      "ICT",
      "Dancing Baratha",
      "Agriculture",
      "Economic",
      "Catholic",
      "Civic",
      "Islam",
      "Geography",
      "Media",
      "Music Orental",
      "Music Carnatic",
      "Design & Material",
      "Ol_Design & Construction",
      "Entrepreneurship Studies",
      "Electrical & Electronic"
    ];

    List<String> filteredStreamNames = List.from(streamNames);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select Your Subject',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeights.bold,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
          WhatsAppJoinGroup(),
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.74, // Adjust the height as needed
            child: ListView.builder(
              itemCount: filteredStreamNames.length,
              itemBuilder: (context, index) {
                return SubStreamContainer(
                  hzMargin: hzMargin,
                  scrHeight: scrHeight,
                  name: UiUtils.getCurrentQuestionLanguageId(context) == "57"
                      ? filteredStreamNames[index]
                      : UiUtils.getCurrentQuestionLanguageId(context) == "14"
                          ? filteredStreamNames[index]
                          : TamilstreamNames[index],
                  onpress: () {
                    showrewardadd(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => pages[index],
                        ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _userRank = '0';
  String _userCoins = '0';
  String _userScore = '0';

  Widget _buildHome() {
    return Stack(
      children: [
        RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: () async {
            fetchUserDetails();

            _currLangId = UiUtils.getCurrentQuestionLanguageId(context);
            final quizCubit = context.read<QuizCategoryCubit>();
            final quizZoneCubit = context.read<QuizoneCategoryCubit>();

            if (widget.isGuest) {
              await quizCubit.getQuizCategory(
                languageId: _currLangId,
                type: _quizZoneId,
              );
              await quizZoneCubit.getQuizCategory(languageId: _currLangId);
            } else {
              await quizCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
                type: _quizZoneId,
              );

              await quizZoneCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
              );
              await context
                  .read<ContestCubit>()
                  .getContest(languageId: _currLangId);
            }
            setState(() {});
          },
          child: ListView(
            children: [
              _buildProfileContainer(),
              BlocBuilder<QuizoneCategoryCubit, QuizoneCategoryState>(
                builder: (context, state) {
                  if (state is QuizoneCategoryFailure &&
                      state.errorMessage == errorCodeDataNotFound) {
                    return const SizedBox.shrink();
                  }

                  if (_sysConfigCubit.isQuizZoneEnabled) {
                    return _buildSubStreamList();
                  }

                  return const SizedBox.shrink();
                },
              ),
              if (_sysConfigCubit.isAdsEnable &&
                  _sysConfigCubit.isDailyAdsEnabled &&
                  !widget.isGuest) ...[
                _buildDailyAds(),
              ],
            ],
          ),
        ),
        if (showUpdateContainer) const UpdateAppContainer(),
        const Align(
          alignment: Alignment.bottomCenter,
          child: BannerAdContainer(),
        ),
      ],
    );
  }

  void fetchUserDetails() {
    context.read<UserDetailsCubit>().fetchUserDetails();
  }

  bool profileComplete = false;

  @override
  Widget build(BuildContext context) {
    /// need to add this here, cause textStyle doesn't update automatically when changing theme.
    _boldTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).colorScheme.onTertiary,
    );

    return Scaffold(
      body: SafeArea(
        child: widget.isGuest
            ? _buildHome()

            /// Build home with User
            : BlocConsumer<UserDetailsCubit, UserDetailsState>(
                bloc: context.read<UserDetailsCubit>(),
                listener: (context, state) {
                  if (state is UserDetailsFetchSuccess) {
                    UiUtils.fetchBookmarkAndBadges(
                      context: context,
                      userId: state.userProfile.userId!,
                    );
                    if (state.userProfile.profileUrl!.isEmpty ||
                        state.userProfile.name!.isEmpty) {
                      if (!profileComplete) {
                        profileComplete = true;

                        Navigator.of(context).pushNamed(
                          Routes.selectProfile,
                          arguments: false,
                        );
                      }
                      return;
                    }
                  } else if (state is UserDetailsFetchFailure) {
                    if (state.errorMessage == errorCodeUnauthorizedAccess) {
                      showAlreadyLoggedInDialog(context);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is UserDetailsFetchInProgress ||
                      state is UserDetailsInitial) {
                    return const Center(child: CircularProgressContainer());
                  }
                  if (state is UserDetailsFetchFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: true,
                        errorMessage:
                            convertErrorCodeToLanguageKey(state.errorMessage),
                        onTapRetry: fetchUserDetails,
                        showErrorImage: true,
                      ),
                    );
                  }

                  final user = (state as UserDetailsFetchSuccess).userProfile;

                  _userName = user.name!;
                  _userProfileImg = user.profileUrl!;
                  _userRank = user.allTimeRank!;
                  _userCoins = user.coins!;
                  _userScore = user.allTimeScore!;

                  return _buildHome();
                },
              ),
      ),
    );
  }
}

class SubStreamContainer extends StatelessWidget {
  const SubStreamContainer({
    super.key,
    required this.hzMargin,
    required this.scrHeight,
    required this.name,
    required this.onpress,
  });

  final double hzMargin;
  final double scrHeight;
  final String name;
  final VoidCallback onpress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onpress,
      child: Padding(
        padding: EdgeInsets.only(
          left: hzMargin,
          right: hzMargin,
          top: scrHeight * 0.03,
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(1.0),
                  Color(0xff007FFF),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 1.0],
              ),
              borderRadius: BorderRadius.circular(10)),
          height: MediaQuery.of(context).size.width / 7,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize:
                                UiUtils.getCurrentQuestionLanguageId(context) ==
                                            "14" ||
                                        UiUtils.getCurrentQuestionLanguageId(
                                                context) ==
                                            "57"
                                    ? 18
                                    : 12,
                            fontWeight: FontWeights.bold,
                            color: Colors.white,
                            overflow: TextOverflow.ellipsis, //
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.touch_app,
                      color: Colors.yellow,
                      size: 20,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
