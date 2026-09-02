import 'package:flutter/material.dart';

class AuthLink extends StatelessWidget {
  final String text;
  final String linkLabel;
  final VoidCallback onPressed;

  const AuthLink({
    super.key,
    required this.text,
    required this.linkLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Text(text),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            linkLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 47, 9, 54),
            ),
          ),
        ),
      ],
    );
  }
}
