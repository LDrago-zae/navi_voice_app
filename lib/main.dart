import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:navi_voice_app/views/login_screen.dart';
// import 'package:mapbox_kit_navigation/mapbox_kit_navigation.dart' as mapbox_kit_navigation;

Future<void> main() async {
  await setup();
  runApp(const MyApp());
}

Future<void> setup() async {
  await dotenv.load(fileName: '.env');
  MapboxOptions.setAccessToken(dotenv.env['MAP_BOX_ACCESS_TOKEN']!);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaviVoice',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Future<void> main() async {
//   await setup();
//   runApp(const MyApp());
// }
//
// Future<void> setup() async {
//   await dotenv.load(fileName: '.env');
//   mapbox_kit_navigation.initializeMapboxNavigationKit(accessToken: 'pk.eyJ1IjoiemFlZW02MCIsImEiOiJjbWQ4ZHpqdHQwcmMwMmxxdW9xNnlpZnVwIn0.CF28oX36ouZahEdyVEhWDg');
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'NaviVoice',
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: Scaffold(
//         appBar: AppBar(title: const Text('My Navigation App')),
//         body: mapbox_kit_navigation.NavigationMap(
//           mapboxAccessToken: 'pk.eyJ1IjoiemFlZW02MCIsImEiOiJjbWQ4ZHpqdHQwcmMwMmxxdW9xNnlpZnVwIn0.CF28oX36ouZahEdyVEhWDg',
//           showSearchBar: true,
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
