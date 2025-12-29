import 'package:flutter/material.dart';

/// Widget to highlight search query within text
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? defaultStyle;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.defaultStyle,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: defaultStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int currentIndex = 0;

    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(lowerQuery, currentIndex);

      if (matchIndex == -1) {
        // No more matches, add remaining text
        spans.add(
          TextSpan(
            text: text.substring(currentIndex),
            style: defaultStyle,
          ),
        );
        break;
      }

      // Add text before match
      if (matchIndex > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, matchIndex),
            style: defaultStyle,
          ),
        );
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + query.length),
          style:
              highlightStyle ??
              TextStyle(
                backgroundColor: Colors.yellow.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      );

      currentIndex = matchIndex + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
