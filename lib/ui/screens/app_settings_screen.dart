import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/features/systemConfig/cubits/appSettingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// AppSettingsScreen shows app setting details like about us,
/// privacy policy, terms and conditions, etc.
///
/// It takes a required [title] parameter indicating which setting to load.
/// Uses AppSettingsCubit and SystemConfigRepository to fetch setting data.
/// _settingType determines type string to pass to cubit based on [title].
/// fetchAppSetting calls cubit method to fetch data.
///
/// _onTapUrl handles launching external urls.

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({required this.title, super.key});

  final String title;

  static Route<AppSettingsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<AppSettingsCubit>(
        create: (_) => AppSettingsCubit(SystemConfigRepository()),
        child: AppSettingsScreen(title: routeSettings.arguments! as String),
      ),
    );
  }

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late final _settingType = switch (widget.title) {
    aboutUs => 'about_us',
    privacyPolicy => 'privacy_policy',
    termsAndConditions => 'terms_conditions',
    contactUs => 'contact_us',
    howToPlayLbl => 'instructions',
    _ => '',
  };
  late final _screenTitle = context.tr(widget.title)!;

  @override
  void initState() {
    super.initState();
    fetchAppSetting();
  }

  void fetchAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(_settingType);
    });
  }

  FutureOr<bool> _onTapUrl(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      await launchUrl(Uri.parse(url));
    } else {
      log('Error Launching URL : $url', name: 'Launch URL');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(title: Text(_screenTitle)),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: context.read<AppSettingsCubit>(),
        builder: (context, state) {
          if (state is AppSettingsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: convertErrorCodeToLanguageKey(state.errorCode),
                onTapRetry: fetchAppSetting,
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              ),
            );
          }

          if (state is AppSettingsFetchSuccess) {
            final size = MediaQuery.of(context).size;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: size.height * UiUtils.vtMarginPct,
                horizontal: size.width * UiUtils.hzMarginPct + 10,
              ),
              child: HtmlWidget(
                state.settingsData,
                onErrorBuilder: (_, e, err) => Text('$e error: $err'),
                onLoadingBuilder: (_, e, l) => const Center(
                  child: CircularProgressIndicator(),
                ),
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                onTapUrl: _onTapUrl,
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
