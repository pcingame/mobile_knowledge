import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

/// Renders note content that may contain fenced ```lang\ncode\n``` blocks,
/// showing code in a labeled monospace box and everything else as normal
/// text with light **bold** support.
class NoteBody extends StatelessWidget {
  const NoteBody({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final segments = _parse(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final segment in segments) _buildSegment(context, segment),
      ],
    );
  }

  Widget _buildSegment(BuildContext context, _Segment segment) {
    final theme = Theme.of(context);
    if (segment.language != null) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (segment.language!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                ),
                child: Text(
                  segment.language!.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(letterSpacing: 0.6),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SelectableText(
                segment.text,
                style: const TextStyle(
                  fontFamily: AppTheme.monoFontFamily,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final baseStyle = theme.textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SelectableText.rich(
        TextSpan(children: _parseBold(segment.text, baseStyle)),
      ),
    );
  }

  /// Turns `**bold**` markers into bold TextSpans; everything else stays
  /// as-is (no full markdown parser needed for this app's simple content).
  List<TextSpan> _parseBold(String text, TextStyle? baseStyle) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var lastEnd = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle?.copyWith(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: baseStyle));
    }
    return spans;
  }

  List<_Segment> _parse(String raw) {
    final segments = <_Segment>[];
    final lines = raw.split('\n');
    final buffer = StringBuffer();
    String? codeLanguage;
    var inCode = false;

    void flush() {
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        segments.add(_Segment(text, inCode ? codeLanguage : null));
      }
      buffer.clear();
    }

    for (final line in lines) {
      final fence = line.trimLeft();
      if (fence.startsWith('```')) {
        flush();
        if (!inCode) {
          codeLanguage = fence.substring(3).trim();
        }
        inCode = !inCode;
        continue;
      }
      buffer.writeln(line);
    }
    flush();
    return segments;
  }
}

class _Segment {
  const _Segment(this.text, this.language);
  final String text;
  /// Null for prose; the fence's language tag (possibly empty) for code.
  final String? language;
}
