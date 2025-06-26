import 'package:flutter/material.dart';
import 'package:awaj/features/auth/presentation/widgets/gender_radio_tile.dart';

import '/core/constants/app_colors.dart';
import '/core/constants/constants.dart';

class GenderPicker extends StatelessWidget {
  const GenderPicker({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  final String? selectedGender;
  final Function(String) onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GenderRadioTile(
          title: 'Male',
          value: 'male',
          groupValue: selectedGender,
          onChanged: onGenderChanged,
        ),
        GenderRadioTile(
          title: 'Female',
          value: 'female',
          groupValue: selectedGender,
          onChanged: onGenderChanged,
        ),
        GenderRadioTile(
          title: 'Other',
          value: 'other',
          groupValue: selectedGender,
          onChanged: onGenderChanged,
        ),
      ],
    );
  }
}
