import 'package:flutter/material.dart';

class CustomSuggestionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<List<String>> Function(String) getSuggestions;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool autofocus;

  const CustomSuggestionField({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.getSuggestions,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.validator,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: RawAutocomplete<String>(
        focusNode: focusNode,
        textEditingController: controller,
        optionsBuilder: (textEditingValue) async {
          if (textEditingValue.text.trim().isEmpty) {
            return const Iterable<String>.empty();
          }
          return getSuggestions(textEditingValue.text);
        },
        onSelected: (selection) {
          controller.text = selection;
          onFieldSubmitted?.call(selection);
        },
        fieldViewBuilder:
            (
              context,
              fieldTextEditingController,
              fieldFocusNode,
              onFieldSubmittedCallback,
            ) {
              return TextFormField(
                controller: fieldTextEditingController,
                focusNode: fieldFocusNode,
                autofocus: autofocus,
                validator: validator,
                textInputAction: textInputAction,
                onFieldSubmitted: (value) {
                  onFieldSubmittedCallback();
                  onFieldSubmitted?.call(value);
                },
                decoration: InputDecoration(
                  labelText: label,
                  hintText: 'Enter $label',
                ),
              );
            },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 32,
                  maxHeight: 240,
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _HighlightedSuggestion(
                          text: option,
                          query: controller.text,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HighlightedSuggestion extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedSuggestion({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queryTrimmed = query.trim();
    if (queryTrimmed.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = queryTrimmed.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex < 0) {
      return Text(text);
    }

    final matchEnd = matchIndex + queryTrimmed.length;
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        children: [
          TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchEnd),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(matchEnd)),
        ],
      ),
    );
  }
}
