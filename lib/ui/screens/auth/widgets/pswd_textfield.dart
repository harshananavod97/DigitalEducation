import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';

class PswdTextField extends StatefulWidget {
  const PswdTextField({
    required this.controller,
    super.key,
    this.validator,
    this.hintText,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hintText;

  @override
  State<PswdTextField> createState() => _PswdTextFieldState();
}

class _PswdTextFieldState extends State<PswdTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onTertiary;

    return TextFormField(
      controller: widget.controller,
      cursorColor: textColor,
      style: TextStyle(
        color: textColor.withOpacity(0.8),
        fontSize: 16,
        fontWeight: FontWeights.regular,
      ),
      obscureText: _obscureText,
      obscuringCharacter: '*',
      validator: (val) {
        if (val!.isEmpty) {
          return context.tr('passwordRequired');
        } else if (val.length < 6) {
          return context.tr('pwdLengthMsg');
        }

        return widget.validator?.call(val);
      },
      decoration: InputDecoration(
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(15),
        hintText: widget.hintText ?? "${context.tr('pwdLbl')!}*",
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.4),
          fontWeight: FontWeights.regular,
          fontSize: 16,
        ),
        prefixIcon: const Icon(CupertinoIcons.lock),
        prefixIconColor: textColor.withOpacity(0.4),
        suffixIconColor: textColor.withOpacity(0.4),
        suffixIcon: GestureDetector(
          child: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onTap: () => setState(() => _obscureText = !_obscureText),
        ),
      ),
    );
  }
}
