import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exclusao de dados do usuario',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB34B27),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3E8DD),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        ),
      ),
      home: const AccountDeletionPage(),
    );
  }
}

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage> {
  static const _backgroundAsset = 'assets/images/background8.png';
  static const _iconAsset = 'assets/images/splash_icon.png';

  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _service = UserService();

  bool isAuthenticating = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          isAuthenticating = true;
        });

        final result = await _service.getDeleteAccountInfo(
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (result != null && result['token'] != null) {
          final userId = result['userId'];
          final token = result['token'];

          final deletionSuccess = await _service.deleteAccountUser(
            userId: userId,
            token: token,
          );
          if (deletionSuccess) {
            setState(() {
              isAuthenticating = false;
            });
            _emailController.clear();
            _passwordController.clear();
            _nicknameController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conta excluida com sucesso.')),
            );
          } else {
            print('result: $result');
            setState(() {
              isAuthenticating = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Falha ao excluir conta. Verifique a conexao e tente novamente.',
                ),
              ),
            );
          }
        } else {
          print('Authentication error: ${result!["error"]}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erro de autenticacao: Verifique as credenciais e tente novamente.',
              ),
            ),
          );
          setState(() {
            isAuthenticating = false;
          });
        }
      } catch (e) {
        print('Error during authentication: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao conectar com o servidor. Verifique a conexao e tente novamente.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_backgroundAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF20110D).withValues(alpha: 0.78),
                  const Color(0xFF8B3D28).withValues(alpha: 0.58),
                  const Color(0xFFF3E8DD).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Card(
                    elevation: 12,
                    color: const Color(0xFFF9F3EE).withValues(alpha: 0.92),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 72,
                                width: 72,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Image.asset(_iconAsset),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Excluir dados do usuario',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF2B1811),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Pagina dedicada para exclusão de conta, autenticar e excluir permanente dos dados da conta.',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: const Color(0xFF563429),
                                            height: 1.4,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _InfoStrip(
                            title: 'Como funciona',
                            content:
                                'Preencha nickname, email e senha. Depois disso seus dados serão apagados permanentemente do nosso sistema, sem possibilidade de recuperação.',
                          ),
                          const SizedBox(height: 16),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nicknameController,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Nickname',
                                    prefixIcon: Icon(Icons.alternate_email),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe o nickname.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _emailController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.mail_outline),
                                  ),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty ||
                                        !trimmed.contains('@')) {
                                      return 'Informe um email valido.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Senha',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Informe a senha.';
                                    }
                                    if (value.length < 6) {
                                      return 'Use ao menos 6 caracteres.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _authenticate,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7E2F1B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              child: isAuthenticating
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text("Delete Account"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0B28F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF8B3D28),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5B382E),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class UserService {
  final apiUrl = dotenv.env['API_URL'];

  Future<Map<String, dynamic>?> getDeleteAccountInfo({
    required String nickname,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/users/get-delete-account');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to authenticate: ${response.statusCode}');
        return {
          "error": "Authentication failed with status ${response.statusCode}",
        };
      }
    } catch (e) {
      print('Error fetching delete account info: $e');
      return {"error": "Error fetching delete account info: $e"};
    }
  }

  Future<Map<String, dynamic>> deleteAccountUser({
    required String userId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/users/delete-account/$userId');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': data['success'] ?? false, 'message': data['message'] ?? 'Account deletion successful.'};
      } else {
        print('Failed to authenticate: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return {'success': data['success'] ?? false, 'error': data['error'] ?? 'Account deletion failed.'};
      }
    } catch (e) {
      print('Error deleting account: $e');
      return {'success': false, 'error': 'Error deleting account: $e'};
    }
  }
}
