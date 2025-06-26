import 'package:flutter/material.dart';

class GenderRadioTile extends StatelessWidget {
  const GenderRadioTile({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String value;
  final String? groupValue;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }
}
