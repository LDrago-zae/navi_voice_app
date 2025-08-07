import 'dart:async';

import 'package:flutter/material.dart';
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search for a destination...',
              border: InputBorder.none,
              icon: Icon(Icons.search, color: Colors.deepPurpleAccent),
            ),
          ),
        ),
        if (widget.searchResults != null && widget.searchResults!.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
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
      ],
    );
  }
}
