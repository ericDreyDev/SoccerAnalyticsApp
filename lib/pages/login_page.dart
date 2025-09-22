import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socceranalyticsapp/pages/choose_league_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showPassword = true;
  bool rememberMe = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const _storage = FlutterSecureStorage();

  // Chaves para armazenamento
  static const String _keyEmail = 'saved_email';
  static const String _keyPassword = 'saved_password';
  static const String _keyRememberMe = 'remember_me';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Carregar credenciais salvas
  Future<void> _loadSavedCredentials() async {
    final savedRememberMe = await _storage.read(key: _keyRememberMe);

    if (savedRememberMe == 'true') {
      final savedEmail = await _storage.read(key: _keyEmail);
      final savedPassword = await _storage.read(key: _keyPassword);

      setState(() {
        rememberMe = true;
        _emailController.text = savedEmail ?? '';
        _passwordController.text = savedPassword ?? '';
      });
    }
  }

  // Salvar credenciais
  Future<void> _saveCredentials() async {
    if (rememberMe) {
      await _storage.write(key: _keyEmail, value: _emailController.text);
      await _storage.write(key: _keyPassword, value: _passwordController.text);
      await _storage.write(key: _keyRememberMe, value: 'true');
    } else {
      // Limpar dados salvos se desmarcar "Lembrar-me"
      await _storage.delete(key: _keyEmail);
      await _storage.delete(key: _keyPassword);
      await _storage.delete(key: _keyRememberMe);
    }
  }

  // Verificar se usuário já está "logado" (dados salvos)
  Future<bool> _checkAutoLogin() async {
    final savedRememberMe = await _storage.read(key: _keyRememberMe);
    final savedEmail = await _storage.read(key: _keyEmail);
    final savedPassword = await _storage.read(key: _keyPassword);

    return savedRememberMe == 'true' &&
        savedEmail != null &&
        savedPassword != null &&
        savedEmail.isNotEmpty &&
        savedPassword.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // Salvar credenciais se "Lembrar-me" estiver marcado
    await _saveCredentials();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChooseLeaguePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.asset("assets/soccer_analytcs.png"),
            ),
            const SizedBox(height: 20),

            // Email input
            TextField(
              controller: _emailController,
              maxLength: 50,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Type your email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(37),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),

            // Password input
            TextField(
              controller: _passwordController,
              obscureText: showPassword,
              maxLength: 10,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: showPassword
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                ),
                hintText: "Type your password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(37),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 10),

            // Checkbox "Lembrar-me"
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (bool? value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      rememberMe = !rememberMe;
                    });
                  },
                  child: const Text(
                    'Remember me',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Login button
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(37),
                  ),
                ),
                child: const Text("Login", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
