// import 'package:flutter/material.dart';


// class SearchWidget extends StatefulWidget {
//   final Function(String) onSearch;
//   final Function(MapboxPlace) onSelect;
//   final List<MapboxPlace>? searchResults;
//   final TextEditingController controller;

//   const SearchWidget({
//     Key? key,
//     required this.onSearch,
//     required this.onSelect,
//     this.searchResults,
//     required this.controller,
//   }) : super(key: key);

//   @override
//   State<SearchWidget> createState() => _SearchWidgetState();
// }

// class _SearchWidgetState extends State<SearchWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: TextField(
//             controller: widget.controller,
//             onChanged: widget.onSearch,
//             decoration: const InputDecoration(
//               hintText: 'Search places...',
//               border: InputBorder.none,
//               icon: Icon(Icons.search),
//             ),
//           ),
//         ),
//         if (widget.searchResults != null && widget.searchResults!.isNotEmpty)
//           Container(
//             margin: const EdgeInsets.only(top: 8),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ListView.builder(
//               shrinkWrap: true,
//               itemCount: widget.searchResults!.length,
//               itemBuilder: (context, index) {
//                 final place = widget.searchResults![index];
//                 return ListTile(
//                   title: Text(place.placeName ?? 'Unknown place'),
//                   subtitle: Text(place.properties?.address ?? ''),
//                   onTap: () => widget.onSelect(place),
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }