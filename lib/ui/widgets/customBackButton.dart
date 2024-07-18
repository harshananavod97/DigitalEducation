import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    super.key,
    this.removeSnackBars,
    this.iconColor,
    this.onTap,
  });

  final bool? removeSnackBars;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null
          ? () {
              Navigator.pop(context);
              if (removeSnackBars != null && removeSnackBars!) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              }
            }
          : () {
              onTap?.call();
            },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
        ),
        child: Icon(
          Icons.arrow_back_rounded,
          size: 22.5,
          color: iconColor ?? Theme.of(context).colorScheme.onTertiary,
        ),
      ),
    );
  }
}

class QBackButton extends StatelessWidget {
  const QBackButton({
    super.key,
    this.onTap,
    this.removeSnackBars = true,
    this.color,
  });

  final bool removeSnackBars;
  final void Function()? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap ??
          () {
            Navigator.pop(context);
            if (removeSnackBars) {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
            }
          },
      iconSize: 24,
      padding: const EdgeInsets.all(8),
      color: color ?? Theme.of(context).colorScheme.onTertiary,
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}
