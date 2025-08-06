// import 'package:flutter/material.dart';
// import '../../models/location_model.dart';
// import '../../services/navigation_service.dart';

// class NavigationWidget extends StatefulWidget {
//   final LocationModel? origin;
//   final LocationModel? destination;
//   final VoidCallback? onNavigationReady;
//   final Function(String)? onNavigationUpdate;

//   const NavigationWidget({
//     super.key,
//     this.origin,
//     this.destination,
//     this.onNavigationReady,
//     this.onNavigationUpdate,
//   });

//   @override
//   State<NavigationWidget> createState() => _NavigationWidgetState();
// }

// class _NavigationWidgetState extends State<NavigationWidget> {
//   final NavigationService _navigationService = NavigationService();
//   bool _isNavigationReady = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeNavigation();
//   }

//   @override
//   void dispose() {
//     _navigationService.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeNavigation() async {
//     await _navigationService.initialize();
//     setState(() {
//       _isNavigationReady = true;
//     });

//     if (widget.onNavigationReady != null) {
//       widget.onNavigationReady!();
//     }
//   }

//   Future<void> startNavigation() async {
//     if (widget.origin != null && widget.destination != null) {
//       final success = await _navigationService.startNavigation(
//         origin: widget.origin!,
//         destination: widget.destination!,
//       );

//       if (success && widget.onNavigationUpdate != null) {
//         widget.onNavigationUpdate!('Navigation started');
//       }
//     }
//   }

//   Future<void> stopNavigation() async {
//     await _navigationService.stopNavigation();
//     if (widget.onNavigationUpdate != null) {
//       widget.onNavigationUpdate!('Navigation stopped');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         if (!_isNavigationReady)
//           const Center(child: CircularProgressIndicator())
//         else
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   Text(
//                     'Navigation Ready',
//                     style: Theme.of(context).textTheme.titleLarge,
//                   ),
//                   const SizedBox(height: 16),
//                   if (widget.origin != null && widget.destination != null)
//                     Column(
//                       children: [
//                         Text('From: ${widget.origin!.name ?? 'Current Location'}'),
//                         Text('To: ${widget.destination!.name ?? 'Destination'}'),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: startNavigation,
//                           child: const Text('Start Navigation'),
//                         ),
//                       ],
//                     )
//                   else
//                     const Text('Please set origin and destination'),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: stopNavigation,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                     ),
//                     child: const Text('Stop Navigation'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
