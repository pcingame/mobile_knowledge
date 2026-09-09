import 'package:flutter/material.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/flashcard.dart';

class FlashcardTab extends StatefulWidget {
  const FlashcardTab({super.key, required this.flashcards, required this.language});

  final List<Flashcard> flashcards;
  final AppLanguage language;

  @override
  State<FlashcardTab> createState() => _FlashcardTabState();
}

class _FlashcardTabState extends State<FlashcardTab> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _showAnswer = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return const Center(child: Text('Chưa có flashcard nào.'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${_index + 1} / ${widget.flashcards.length}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.flashcards.length,
            onPageChanged: (i) => setState(() {
              _index = i;
              _showAnswer = false;
            }),
            itemBuilder: (context, i) {
              final card = widget.flashcards[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _showAnswer = !_showAnswer),
                  child: _FlashcardFace(
                    text: (_showAnswer ? card.answer : card.question).of(widget.language),
                    isAnswer: _showAnswer,
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Chạm vào thẻ để lật ${_showAnswer ? "câu hỏi" : "đáp án"} · vuốt để chuyển thẻ',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({required this.text, required this.isAnswer});

  final String text;
  final bool isAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: isAnswer ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox.expand(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAnswer ? 'ĐÁP ÁN' : 'CÂU HỎI',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
