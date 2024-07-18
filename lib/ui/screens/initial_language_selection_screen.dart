import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class InitialLanguageSelectionScreen extends StatefulWidget {
  const InitialLanguageSelectionScreen({super.key});

  @override
  State<InitialLanguageSelectionScreen> createState() =>
      _InitialLanguageSelectionScreenState();

  static Route<dynamic> route() => CupertinoPageRoute(
        builder: (_) => const InitialLanguageSelectionScreen(),
      );
}

class _InitialLanguageSelectionScreenState
    extends State<InitialLanguageSelectionScreen> {
  late final _supportedLanguages =
      context.read<SystemConfigCubit>().getSupportedLanguages();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        automaticallyImplyLeading: false,
        title: Text(context.tr('selectLanguage')!),
        usePrimaryColor: true,
      ),
      body: BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
        builder: (context, state) {
          var currLang = state.language;

          final size = MediaQuery.of(context).size;
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * UiUtils.vtMarginPct,
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: ListView.separated(
              itemBuilder: (context, i) {
                final language = _supportedLanguages[i];

                final locale =
                    UiUtils.getLocaleFromLanguageCode(language.languageCode);

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(.7),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: RadioListTile(
                    toggleable: true,
                    activeColor: currLang == locale
                        ? Theme.of(context).primaryColor
                        : Colors.white,
                    title: Text(
                      language.language,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onTertiary,
                      ),
                    ),
                    value: locale,
                    groupValue: currLang,
                    onChanged: (value) {
                      currLang = value!;

                      if (state.language != locale) {
                        context
                            .read<AppLocalizationCubit>()
                            .changeLanguage(language.languageCode);
                      }
                    },
                  ),
                );
              },
              separatorBuilder: (_, i) =>
                  const SizedBox(height: UiUtils.listTileGap),
              itemCount: _supportedLanguages.length,
            ),
          );
        },
      ),
      floatingActionButton: _confirmAndContinueButton,
    );
  }

  FloatingActionButton get _confirmAndContinueButton => FloatingActionButton(
        onPressed: () => Navigator.of(context).pushReplacementNamed(
          Routes.introSlider,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.surface,
        child: const Icon(Icons.check),
      );
}
