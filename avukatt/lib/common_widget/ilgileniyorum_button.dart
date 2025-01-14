import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String ilanTopic;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.ilanTopic,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(),
      child: const Text('İlgileniyorum'),
    );
  }
}
