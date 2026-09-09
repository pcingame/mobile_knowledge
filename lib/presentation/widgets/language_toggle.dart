import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';

/// EN/VI segmented toggle, used in the app bar of screens that show
/// bilingual question-bank content.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, required this.language, required this.onChanged});

  final AppLanguage language;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SegmentedButton<AppLanguage>(
        segments: const [
          ButtonSegment(value: AppLanguage.en, label: Text('EN')),
          ButtonSegment(value: AppLanguage.vi, label: Text('VI')),
        ],
        selected: {language},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
