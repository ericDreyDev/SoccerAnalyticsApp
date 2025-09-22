import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/pages/home_page.dart';
import 'package:socceranalyticsapp/pages/login_page.dart';
import 'package:socceranalyticsapp/pages/choose_league_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // Simular um pequeno delay para mostrar splash
    await Future.delayed(const Duration(seconds: 2));

    final savedRememberMe = await _storage.read(key: 'remember_me');
    final savedEmail = await _storage.read(key: 'saved_email');
    final savedPassword = await _storage.read(key: 'saved_password');
    final savedLeague = await _storage.read(key: 'selected_league');

    // Verificar se deve fazer auto-login
    if (savedRememberMe == 'true' &&
        savedEmail != null &&
        savedPassword != null &&
        savedEmail.isNotEmpty &&
        savedPassword.isNotEmpty) {
      // Usuário deve ser logado automaticamente
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            selectedLeague: savedLeague != null
                ? LeagueModel.fromJson(jsonDecode(savedLeague))
                : LeagueModel(id: '4328', name: 'English Premier League'),
          ),
        ),
      );
    } else {
      // Mostrar tela de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Image.asset("assets/soccer_analytcs.png"),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
