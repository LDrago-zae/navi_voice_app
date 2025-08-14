import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:mapbox_search/models/predictions.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final Function(MapBoxPlace) onSelect;
  final List<MapBoxPlace>? searchResults;
  final TextEditingController controller;

  const SearchWidget({
    required this.onSearch,
    required this.onSelect,
    required this.searchResults,
    required this.controller,
    super.key,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Search destination',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.searchResults != null && widget.searchResults!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.searchResults!.length,
                  itemBuilder: (context, index) {
                    final place = widget.searchResults![index];
                    return ListTile(
                      title: Text(place.placeName!),
                      subtitle: Text(place.address ?? ''),
                      onTap: () => widget.onSelect(place),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
