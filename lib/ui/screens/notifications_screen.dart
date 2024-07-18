import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/notification/cubit/notificationCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<NotificationCubit>(
        create: (_) => NotificationCubit(),
        child: const NotificationScreen(),
      ),
    );
  }
}

class _NotificationScreen extends State<NotificationScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
    context.read<NotificationCubit>().fetchNotifications();
    context.read<InterstitialAdCubit>().showAd(context);
  }

  void scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMore) {
        context.read<NotificationCubit>().fetchMoreNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: QAppBar(
        title: Text(
          context.tr('notificationLbl')!,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: size.height * UiUtils.vtMarginPct,
          horizontal: size.width * UiUtils.hzMarginPct,
        ),
        child: Container(
          height: size.height * .84,
          alignment: Alignment.topCenter,
          child: BlocConsumer<NotificationCubit, NotificationState>(
            bloc: context.read<NotificationCubit>(),
            listener: (context, state) {
              if (state is NotificationFailure) {
                if (state.errorMessageCode == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                }
              }
            },
            builder: (context, state) {
              if (state is NotificationProgress ||
                  state is NotificationInitial) {}
              if (state is NotificationFailure) {
                return ErrorContainer(
                  showBackButton: false,
                  errorMessageColor: Theme.of(context).colorScheme.onTertiary,
                  showErrorImage: true,
                  errorMessage:
                      convertErrorCodeToLanguageKey(state.errorMessageCode),
                  onTapRetry:
                      context.read<NotificationCubit>().fetchNotifications,
                );
              }

              if (state is NotificationSuccess) {
                return ListView.separated(
                  controller: controller,
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, i) =>
                      const SizedBox(height: UiUtils.listTileGap),
                  itemBuilder: (_, i) {
                    if (state.hasMore &&
                        i == (state.notifications.length - 1)) {
                      return const Center(child: CircularProgressContainer());
                    }
                    return _NotificationCard(state.notifications[i]);
                  },
                );
              }

              return const Center(child: CircularProgressContainer());
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard(this.notification);

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM 'at' ").add_jm();
    final formattedDate =
        dateFormat.format(DateTime.parse(notification['date_sent'].toString()));

    final title = notification['title'].toString();
    final message = notification['message'].toString();
    final image = notification['image'].toString();
    final type = notification['type'].toString();

    void onTapNotification() {
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: UiUtils.bottomSheetTopRadius,
        ),
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          final size = MediaQuery.sizeOf(context);

          void onTapLetsPlay() {
            context.shouldPop();
            Navigator.of(context).pushNamed(
              Routes.category,
              arguments: {
                'quizType': switch (type) {
                  'guess-the-word-category' => QuizTypes.guessTheWord,
                  'audio-question-category' => QuizTypes.audioQuestions,
                  'fun-n-learn-category' => QuizTypes.funAndLearn,
                  _ => QuizTypes.quizZone,
                },
              },
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: UiUtils.bottomSheetTopRadius,
            ),
            height: size.height * .7,
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: size.shortestSide * UiUtils.hzMarginPct,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// Close Button
                Row(
                  children: [
                    const Spacer(),
                    PopScope(
                      child: InkWell(
                        onTap: context.shouldPop,
                        child: Icon(
                          Icons.close_rounded,
                          size: 24,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ///
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: colorScheme.onTertiary,
                        ),
                      ),

                      ///
                      const SizedBox(height: 10),
                      if (image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            placeholder: (_, s) =>
                                Image.asset(Assets.icLauncher),
                            errorWidget: (_, s, d) =>
                                Image.asset(Assets.icLauncher),
                          ),
                        ),

                      ///
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ],
                  ),
                ),

                ///
                const SizedBox(height: 10),
                if (type.endsWith('category'))
                  CustomRoundedButton(
                    onTap: onTapLetsPlay,
                    widthPercentage: size.shortestSide,
                    backgroundColor: Theme.of(context).primaryColor,
                    buttonTitle: context.tr('letsPlay'),
                    radius: 6,
                    showBorder: false,
                    height: 45,
                  ),
              ],
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: onTapNotification,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            /// Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (_, s) => Image.asset(Assets.icLauncher),
                  errorWidget: (_, s, d) => Image.asset(Assets.icLauncher),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                  ),

                  /// Desc
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// Date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
