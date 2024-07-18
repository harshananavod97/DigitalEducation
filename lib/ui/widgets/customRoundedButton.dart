import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRoundedButton extends StatelessWidget {
  const CustomRoundedButton({
    required this.widthPercentage,
    required this.backgroundColor,
    required this.buttonTitle,
    required this.radius,
    required this.showBorder,
    required this.height,
    super.key,
    this.borderColor,
    this.elevation,
    this.onTap,
    this.shadowColor,
    this.titleColor,
    this.fontWeight,
    this.textSize,
  });

  final String? buttonTitle;
  final double height;
  final double widthPercentage;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double radius;
  final Color? shadowColor;
  final bool showBorder;
  final Color? borderColor;
  final Color? titleColor;
  final double? textSize;
  final FontWeight? fontWeight;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    return Material(
      shadowColor: shadowColor ?? Colors.black54,
      elevation: elevation ?? 0.0,
      color: backgroundColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          //
          alignment: Alignment.center,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: showBorder
                ? Border.all(
                    color: borderColor ??
                        Theme.of(context).scaffoldBackgroundColor,
                  )
                : null,
          ),
          width: MediaQuery.of(context).size.width * widthPercentage,
          child: Text(
            '$buttonTitle',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontSize: textSize ?? 16.0,
                color: titleColor ?? Theme.of(context).scaffoldBackgroundColor,
                fontWeight: fontWeight ?? FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QTextButton extends StatelessWidget {
  const QTextButton(
    this.text, {
    required this.borderColor,
    required this.fontWeight,
    required this.height,
    required this.showBorder,
    required this.textSize,
    required this.width,
    super.key,
    this.radius = 0.0,
    this.textColor,
    this.backgroundColor,
    this.onTap,
  });

  final double height;
  final double width;

  final Color? textColor;
  final FontWeight fontWeight;
  final String text;
  final double textSize;

  final double radius;
  final bool showBorder;
  final Color borderColor;
  final Color? backgroundColor;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
      ),
    );
  }
}
