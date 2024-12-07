import 'dart:async';

import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String) onSearch;
  final Function onExternalSearch;

  const SearchAppBar(
      {super.key, required this.onSearch, required this.onExternalSearch});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight - 10),
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 14,
                    left: 0,
                    top: 4,
                    bottom: 4,
                  ),
                  child: SearchBar(
                    onSearch: onSearch,
                    onExternalSearch: onExternalSearch,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function onExternalSearch;

  const SearchBar(
      {super.key, required this.onSearch, required this.onExternalSearch});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(text);
    });
  }

  void _onSubmitted(String text) {
    _debounce?.cancel();
    widget.onSearch(text);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _onTextChanged(_controller.text);
    });
    widget.onExternalSearch((searchText) {
      _controller.text = searchText;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        textAlign: TextAlign.left,
        textAlignVertical: TextAlignVertical.center,
        controller: _controller,
        onSubmitted: _onSubmitted,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search here ...',
          hintStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(Icons.search, size: 16),
          isDense: true,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () {
                    _controller.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6),
        ),
        maxLines: 1,
      ),
    );
  }
}
