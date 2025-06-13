import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trajetto/pages/cadastro_page.dart';
import 'package:trajetto/pages/dashboard_page.dart'; // ajuste se necessário

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    final nome = _usuarioController.text.trim();
    final senha = _senhaController.text.trim();

    try {
      // 1. Buscar o e-mail com base no nome
      final response = await Supabase.instance.client
          .from('usuarios')
          .select('email')
          .eq('nome', nome)
          .maybeSingle();

      if (response == null || response['email'] == null) {
        throw 'Usuário não encontrado';
      }

      final email = response['email'];

      // 2. Logar com o e-mail encontrado
      final loginResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: senha,
      );

      if (loginResponse.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciais inválidas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Imagem de fundo com logo
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: Image.asset(
                      'assets/fundo_login.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 120),
                        Image.asset(
                          'assets/logo_branca.png',
                          width: 250,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Formulário de login
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(64),
                    topRight: Radius.circular(64),
                    bottomLeft: Radius.circular(64),
                    bottomRight: Radius.circular(64),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _usuarioController,
                      decoration: InputDecoration(
                        hintText: 'Nome',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _senhaController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF037AEF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Entrar', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CadastroPage()),
                          );
                        },
                        child: const Text(
                          'Ainda não é cadastrado? Fazer Cadastro',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
