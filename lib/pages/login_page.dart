import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socceranalyticsapp/pages/choose_league_page.dart';
import 'forgot_password_page.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Azul escuro (campo de futebol à noite)
              Color(0xFF059669), // Verde (grama do campo)
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Logo com animação e sombra
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/soccer_analytcs.png",
                    fit: BoxFit.contain,
                  ),
                ),
                
                // Título e subtítulo compactos
                Column(
                  children: [
                    const Text(
                      'Bem-vindo!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 6),
                    
                    const Text(
                      'Analise o futebol como um profissional',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                
                // Card do formulário mais compacto
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Campo de Email
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _emailController,
                          maxLength: 50,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF6C757D),
                            ),
                            hintText: "Digite seu email",
                            hintStyle: const TextStyle(
                              color: Color(0xFF6C757D),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Campo de Senha
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFFE9ECEF),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: showPassword,
                          maxLength: 20,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF6C757D),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF6C757D),
                              ),
                            ),
                            hintText: "Digite sua senha",
                            hintStyle: const TextStyle(
                              color: Color(0xFF6C757D),
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      // Checkbox "Lembrar-me"
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF059669),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Lembrar-me",
                            style: TextStyle(
                              color: Color(0xFF6C757D),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      // Botão de Login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _handleLogin();
                            // Navegação para home page
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.sports_soccer,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "ENTRAR NO CAMPO",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Link "Esqueci minha senha"
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Esqueci minha senha",
                          style: TextStyle(
                            color: Color(0xFF6C757D),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Rodapé com ícones de futebol
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: Colors.white.withOpacity(0.6),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Powered by Analytics",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.timeline,
                      color: Colors.white.withOpacity(0.6),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } 
}
