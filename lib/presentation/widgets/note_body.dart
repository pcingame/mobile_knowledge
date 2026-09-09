import 'package:flutter/material.dart';

/// Renders note content that may contain fenced ```code``` blocks,
/// showing code in a monospace box and everything else as normal text.
class NoteBody extends StatelessWidget {
  const NoteBody({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    final segments = _splitCodeBlocks(content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final segment in segments) _buildSegment(context, segment),
      ],
    );
  }

  Widget _buildSegment(BuildContext context, _Segment segment) {
    final theme = Theme.of(context);
    if (segment.isCode) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SelectableText(
          segment.text,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
        ),
      );
    }

    final baseStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  List<_Segment> _splitCodeBlocks(String raw) {
    final segments = <_Segment>[];
    final lines = raw.split('\n');
    final buffer = StringBuffer();
    var inCode = false;

    void flush(bool asCode) {
      final text = buffer.toString().trim();
      if (text.isNotEmpty) {
        segments.add(_Segment(text, asCode));
      }
      buffer.clear();
    }

    for (final line in lines) {
      if (line.trimLeft().startsWith('```')) {
        flush(inCode);
        inCode = !inCode;
        continue;
      }
      buffer.writeln(line);
    }
    flush(inCode);
    return segments;
  }
}

class _Segment {
  const _Segment(this.text, this.isCode);
  final String text;
  final bool isCode;
}
