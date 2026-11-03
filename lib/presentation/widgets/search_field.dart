import 'package:flutter/material.dart';

import '../../core/constants.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    FocusScope.of(context).unfocus();
    widget.onSearch(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
    @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        textCapitalization: TextCapitalization.words,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward),
            tooltip: AppStrings.searchTooltip,
            onPressed: _submit,
          ),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
