import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/validators.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hintText = "${context.tr('emailAddress')!}*";

    return TextFormField(
      cursorColor: colorScheme.onTertiary,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (val) => Validators.validateEmail(
        val!,
        context.tr('emailRequiredMsg'),
        context.tr('enterValidEmailMsg'),
      ),
      style: TextStyle(
        color: colorScheme.onTertiary.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeights.regular,
      ),
      decoration: InputDecoration(
        fillColor: colorScheme.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Icon(Icons.mail_outline_rounded),
        prefixIconColor: colorScheme.onTertiary.withOpacity(0.4),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onTertiary.withOpacity(0.4),
          fontSize: 16,
          fontWeight: FontWeights.regular,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
