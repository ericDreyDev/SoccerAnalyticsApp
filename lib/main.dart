import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socceranalyticsapp/providers/favorites_provider.dart';
import 'package:socceranalyticsapp/pages/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider()..loadFavorites(),
      child: MaterialApp(
        title: 'Soccer Analytics',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
