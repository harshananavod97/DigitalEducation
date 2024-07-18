import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/gdpr_helper.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static Route<SettingScreen> route(RouteSettings settings) {
    return CupertinoPageRoute(builder: (_) => const SettingScreen());
  }

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late final Future<bool> _isUnderGdpr;

  @override
  void initState() {
    super.initState();

    _isUnderGdpr = GdprHelper.isUnderGdpr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(context.tr('settingLbl')!),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * UiUtils.vtMarginPct,
          horizontal: MediaQuery.of(context).size.width * UiUtils.hzMarginPct,
        ),
        child: BlocBuilder(
          bloc: context.read<SettingsCubit>(),
          builder: (BuildContext context, state) {
            if (state is SettingsState) {
              final settingsCubit = context.read<SettingsCubit>();
              final settings = settingsCubit.getSettings();

              final size = MediaQuery.of(context).size;
              final colorScheme = Theme.of(context).colorScheme;
              final primaryColor = Theme.of(context).primaryColor;
              final textStyle = TextStyle(
                fontSize: 16,
                fontWeight: FontWeights.regular,
                color: colorScheme.onTertiary,
              );

              return Column(
                children: [
                  /// Sound
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.standard,
                    tileColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(
                      Icons.volume_down,
                      color: primaryColor,
                      size: 24,
                    ),
                    title: Text(
                      context.tr('soundLbl')!,
                      style: textStyle,
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        activeColor: primaryColor,
                        value: settings.sound,
                        onChanged: (v) => setState(() {
                          settingsCubit.sound = v;
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  /// Vibration
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.standard,
                    tileColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(
                      Icons.vibration,
                      color: primaryColor,
                      size: 24,
                    ),
                    title: Text(
                      context.tr('vibrationLbl')!,
                      style: textStyle,
                    ),
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: CupertinoSwitch(
                        activeColor: primaryColor,
                        value: settings.vibration,
                        onChanged: (v) => setState(() {
                          settingsCubit.vibration = v;
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),

                  /// Font Size
                  ListTile(
                    dense: true,
                    onTap: () {
                      showModalBottomSheet<void>(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: UiUtils.bottomSheetTopRadius,
                        ),
                        context: context,
                        builder: (_) {
                          var fontSize = settings.playAreaFontSize;

                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: UiUtils.bottomSheetTopRadius,
                            ),
                            height: size.height * 0.6,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: StatefulBuilder(
                              builder: (_, state) {
                                return Column(
                                  children: [
                                    Align(
                                      child: Text(
                                        context.tr(fontSizeLbl)!,
                                        style: TextStyle(
                                          fontWeight: FontWeights.bold,
                                          fontSize: 18,
                                          color: colorScheme.onTertiary,
                                        ),
                                      ),
                                    ),
                                    // horizontal divider
                                    const Divider(),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            size.width * UiUtils.hzMarginPct,
                                      ),
                                      child: Text(
                                        context.tr('fontSizeDescText')!,
                                        maxLines: 4,
                                        style: textStyle.copyWith(
                                          fontSize: fontSize,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Slider(
                                      value: fontSize,
                                      min: 14,
                                      max: 20,
                                      divisions: 5,
                                      label: fontSize.toString(),
                                      activeColor: primaryColor,
                                      inactiveColor: colorScheme.onTertiary
                                          .withOpacity(.1),
                                      onChanged: (v) => state(() {
                                        fontSize = v;
                                        settingsCubit.changeFontSize(fontSize);
                                      }),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    visualDensity: VisualDensity.standard,
                    tileColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Icon(
                      Icons.abc,
                      color: primaryColor,
                      size: 24,
                    ),
                    title: Text(
                      context.tr(fontSizeLbl)!,
                      style: textStyle,
                    ),
                  ),

                  ///
                  SizedBox(height: size.height * 0.02),
                  FutureBuilder<bool>(
                    future: _isUnderGdpr,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!) {
                        return ListTile(
                          dense: true,
                          visualDensity: VisualDensity.standard,
                          tileColor: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: Icon(
                            Icons.ads_click_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                          onTap: GdprHelper.changePrivacyPreferences,
                          title: Text(
                            context.tr('adsPreference')!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeights.regular,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
