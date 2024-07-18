import 'package:flutter/cupertino.dart';
import 'package:flutterquiz/app/app_localization.dart';

extension LocalizedLabelsExt on BuildContext {
  String? tr(String key) {
    return AppLocalization.of(this)?.getTranslatedValues(key);
  }
}

extension BuildContextExt on BuildContext {
  Size get mdSize => MediaQuery.sizeOf(this);

  void shouldPop<T extends Object?>([T? result]) {
    if (Navigator.canPop(this)) {
      Navigator.pop(this, result);
    }
  }

  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  double get shortestSide => mdSize.shortestSide;

  bool get isXSmall => shortestSide < 600;

  bool get isSmall => shortestSide < 905;

  bool get isMedium => shortestSide < 1240;

  bool get isLarge => shortestSide < 1440;
}
