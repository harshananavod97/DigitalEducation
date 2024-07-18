import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/inAppPurchase/in_app_product.dart';
import 'package:flutterquiz/features/profileManagement/cubits/deleteAccountCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/screens/menu/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/login_dialog.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({required this.isGuest, super.key});

  final bool isGuest;

  @override
  State<MenuScreen> createState() => _MenuScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<DeleteAccountCubit>(
            create: (_) => DeleteAccountCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UploadProfileCubit>(
            create: (_) => UploadProfileCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: MenuScreen(isGuest: routeSettings.arguments! as bool),
      ),
    );
  }
}

class _MenuScreenState extends State<MenuScreen> {
  // TODO(J): don't show interstitial ads when going to each screen in menu.

  final menu = [
    // (name: 'wallet', image: Assets.walletMenuIcon),
    (name: 'coinHistory', image: Assets.coinHistoryMenuIcon),
    (name: 'notificationLbl', image: Assets.notificationMenuIcon),
    (name: 'bookmarkLbl', image: Assets.bookmarkMenuIcon),
    (name: 'inviteFriendsLbl', image: Assets.inviteFriendsMenuIcon),
    // (name: 'badges', image: Assets.settingsIcon),
    // (name: 'coinStore', image: Assets.coinMenuIcon),
    (name: 'theme', image: Assets.themeMenuIcon),
    (name: 'rewardsLbl', image: Assets.rewardMenuIcon),
    (name: 'statisticsLabel', image: Assets.statisticsMenuIcon),
    (name: 'language', image: Assets.languageMenuIcon),
    (name: 'aboutQuizApp', image: Assets.aboutUsMenuIcon),
    (name: 'howToPlayLbl', image: Assets.howToPlayMenuIcon),
    (name: 'shareAppLbl', image: Assets.shareMenuIcon),
    (name: 'rateUsLbl', image: Assets.rateMenuIcon),
    (name: 'logoutLbl', image: Assets.logoutMenuIcon),

    (name: 'badges', image: Assets.settingsIcon),
    (name: 'deleteAccountLbl', image: Assets.deleteAccountMenuIcon),
  ];

  List<InAppProduct> iapProducts = [];

  @override
  void initState() {
    super.initState();
    final sysConfig = context.read<SystemConfigCubit>();

    // if (!sysConfig.isCoinStoreEnabled) {
    //   menu.removeWhere((e) => e.name == 'coinStore');
    // }

    // if (!sysConfig.isPaymentRequestEnabled) {
    //   menu.removeWhere((e) => e.name == 'wallet');
    // }
    if (!sysConfig.isLanguageModeEnabled) {
      menu.removeWhere((e) => e.name == 'language');
    }

    if (!(sysConfig.isQuizZoneEnabled ||
        sysConfig.isGuessTheWordEnabled ||
        sysConfig.isAudioQuizEnabled)) {
      menu.removeWhere((e) => e.name == 'bookmarkLbl');
    }

    if (widget.isGuest) {
      menu
        ..removeWhere((e) => e.name == 'logoutLbl')
        ..removeWhere((e) => e.name == 'deleteAccountLbl');
    }

    // scheduleMicrotask(
    //   () async => iapProducts = await InAppPurchaseRepo.fetchInAppProducts(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final hzMargin = MediaQuery.of(context).size.width * UiUtils.hzMarginPct;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 30,
                    left: hzMargin,
                    right: hzMargin,
                  ),
                  height: MediaQuery.of(context).size.height * 0.24,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: LayoutBuilder(
                    builder: (_, constraint) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: Navigator.of(context).pop,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              context.tr('profileLbl')!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: _buildGridviewList(),
                ),
              ],
            ),
          ),
          BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
            listener: (context, state) {
              if (state is DeleteAccountSuccess) {
                //Update state for globally cubits
                context.read<BadgesCubit>().updateState(BadgesInitial());
                context.read<BookmarkCubit>().updateState(BookmarkInitial());

                //set local auth details to empty
                AuthRepository().setLocalAuthDetails(
                  authStatus: false,
                  authType: '',
                  jwtToken: '',
                  firebaseId: '',
                  isNewUser: false,
                );
                //
                UiUtils.showSnackBar(
                  context.tr(accountDeletedSuccessfullyKey)!,
                  context,
                );
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(Routes.login);
              } else if (state is DeleteAccountFailure) {
                UiUtils.showSnackBar(
                  context.tr(
                    convertErrorCodeToLanguageKey(state.errorMessage),
                  )!,
                  context,
                );
              }
            },
            bloc: context.read<DeleteAccountCubit>(),
            builder: (context, state) {
              if (state is DeleteAccountInProgress) {
                return Container(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withOpacity(0.275),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: AlertDialog(
                      shadowColor: Colors.transparent,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressContainer(size: 45),
                          const SizedBox(width: 15),
                          Text(
                            context.tr(deletingAccountKey)!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  void _handleProfileEdit() {
    if (widget.isGuest) {
      showLoginDialog(
        context,
        onTapYes: () => context
          ..shouldPop()
          ..shouldPop()
          ..pushNamed(Routes.login),
      );
    } else {
      Navigator.of(context).pushNamed(Routes.selectProfile, arguments: false);
    }
  }

  Widget _buildProfileCard(
    String profileUrl,
    String profileName,
    String profileDesc,
  ) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(6),
              width: size.width * .18,
              height: size.width * .18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size.width * .9),
                child: QImage(imageUrl: profileUrl),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.029),
          SizedBox(
            width: size.width * 0.63,
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Profile Name
                    SizedBox(
                      width: size.width * 0.5,
                      child: Text(
                        profileName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    /// Profile Description
                    SizedBox(
                      width: size.width * 0.5,
                      child: Text(
                        profileDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.4),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// Edit Profile Button
                InkWell(
                  onTap: _handleProfileEdit,
                  child: Container(
                    height: size.width * .10,
                    width: size.width * .10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridviewList() {
    final hzMargin = MediaQuery.of(context).size.width * UiUtils.hzMarginPct;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hzMargin),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isGuest)
                  _buildProfileCard(
                    Assets.profile('2.png'),
                    context.tr('helloGuest')!,
                    context.tr('provideGuestDetails')!,
                  )
                else
                  BlocBuilder<UserDetailsCubit, UserDetailsState>(
                    bloc: context.read<UserDetailsCubit>(),
                    builder: (context, state) {
                      if (state is UserDetailsFetchSuccess) {
                        final desc =
                            context.read<AuthCubit>().getAuthProvider() ==
                                    AuthProviders.mobile
                                ? state.userProfile.mobileNumber!
                                : state.userProfile.email!;
                        return _buildProfileCard(
                          state.userProfile.profileUrl!,
                          state.userProfile.name!,
                          desc,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                const SizedBox(height: 20),

                ///
                GridView.count(
                  padding: EdgeInsets.zero,
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    3,
                    (i) {
                      final name = context.tr(menu[i].name)!;

                      return GestureDetector(
                        onTap: () => setState(
                          () => _onPressed(menu[i].name, context),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: SvgPicture.asset(
                                  menu[i].image,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: 85,
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontWeight: FontWeights.regular,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  padding: EdgeInsets.zero,
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    menu.length - 3,
                    (index) {
                      /// skip first three
                      index += 3;

                      return Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () => setState(
                              () => _onPressed(menu[index].name, context),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    menu[index].image,
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).primaryColor,
                                      BlendMode.srcIn,
                                    ),
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      context.tr(menu[index].name) == 'Badges'
                                          ? 'Settings'
                                          : context.tr(menu[index].name)!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                        fontWeight: FontWeights.regular,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onPressed(String index, BuildContext context) {
    /// Menus that guest can click/use without being logged in.
    switch (index) {
      case 'theme':
        showThemeSelectorSheet(context);
        return;
      case 'language':
        showLanguageSelectorSheet(context);
        return;
      case 'aboutQuizApp':
        Navigator.of(context).pushNamed(Routes.aboutApp);
        return;
      case 'howToPlayLbl':
        Navigator.of(context)
            .pushNamed(Routes.appSettings, arguments: howToPlayLbl);
        return;
      case 'shareAppLbl':
        {
          try {
            UiUtils.share(
              '${context.read<SystemConfigCubit>().appUrl}\n${context.read<SystemConfigCubit>().shareAppText}',
              context: context,
            );
          } catch (e) {
            UiUtils.showSnackBar(e.toString(), context);
          }
        }
        return;
      case 'rateUsLbl':
        launchUrl(Uri.parse(context.read<SystemConfigCubit>().appUrl));
        return;
      case 'coinStore':
        Navigator.of(context).pushNamed(
          Routes.coinStore,
          arguments: {
            'isGuest': widget.isGuest,
            'iapProducts': iapProducts,
          },
        );
        return;
    }

    /// Menus that users can't use without signing in, (ex. in guest mode).
    if (widget.isGuest) {
      showLoginDialog(
        context,
        onTapYes: () => context
          ..shouldPop()
          ..shouldPop()
          ..pushNamed(Routes.login),
      );
      return;
    }

    /// Menus for logged in users only.
    switch (index) {
      case 'notificationLbl':
        Navigator.of(context).pushNamed(Routes.notification);
        return;
      case 'coinHistory':
        Navigator.of(context).pushNamed(Routes.coinHistory);
        return;
      case 'wallet':
        Navigator.of(context).pushNamed(Routes.wallet);
        return;
      case 'bookmarkLbl':
        Navigator.of(context).pushNamed(Routes.bookmark);
        return;
      case 'inviteFriendsLbl':
        Navigator.of(context).pushNamed(Routes.referAndEarn);
        return;
      case 'badges':
        Navigator.of(context).pushNamed(Routes.settings);
        return;
      case 'rewardsLbl':
        Navigator.of(context).pushNamed(Routes.rewards);
        return;
      case 'statisticsLabel':
        Navigator.of(context).pushNamed(Routes.statistics);
        return;
      case 'logoutLbl':
        showLogoutDialog(context);
        return;

      case 'deleteAccountLbl':
        showDeleteAccountDialog(context);
        return;
    }
  }
}
