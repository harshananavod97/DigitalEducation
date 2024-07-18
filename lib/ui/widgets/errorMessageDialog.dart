import 'package:flutter/material.dart';

class ErrorMessageDialog extends StatelessWidget {
  const ErrorMessageDialog({required this.errorMessage, super.key});
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shadowColor: Colors.transparent,
      content: Text(
        errorMessage!,
        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
      ),
    );
  }
}
