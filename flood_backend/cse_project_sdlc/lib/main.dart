// import 'package:flutter/material.dart';
// import 'searchNGO.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const SearchNGOPage(),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'searchNGO.dart';
import 'help_request.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const SearchNGOPage(),
        '/help': (context) => const HelpRequestPage(),
      },
      initialRoute: '/',
    );
  }
}
