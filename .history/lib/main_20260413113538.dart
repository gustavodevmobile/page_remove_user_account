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

  bool _isAuthenticating = false;
  bool _isDeleting = false;
  bool _isAuthenticated = false;
  bool _deletionRequested = false;
  String? _statusMessage;
  bool _usedDemoMode = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() {
        _isAuthenticating = true;
        _statusMessage = null;
        _deletionRequested = false;
      });

      final result = await _service.getDeleteAccountInfo(
        nickname: _nicknameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isAuthenticating = false;
         _deletionRequested = true;
      });
      return result;
    }
    return false;
  }

  // Future<void> _requestDeletion() async {
  //   setState(() {
  //     _isDeleting = true;
  //     _statusMessage = null;
  //   });

  //   final result = await _service.requestDeletion(
  //     nickname: _nicknameController.text.trim(),
  //     email: _emailController.text.trim(),
  //   );

  //   if (!mounted) {
  //     return;
  //   }

  //   setState(() {
  //     _isDeleting = false;
  //     _deletionRequested = result.isSuccess;
  //     _statusMessage = result.message;
  //   });
  // }

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
                                      'Pagina dedicada para revisar, autenticar e solicitar a exclusao permanente dos dados da conta.',
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
                                'Preencha nickname, email e senha. A autenticacao ocorre no servidor configurado. Depois disso, o botao de exclusao e liberado.',
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
                              onPressed: _isAuthenticating || _isDeleting
                                  ? null
                                  : _authenticate,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF7E2F1B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                              ),
                              child: Text(
                                _isAuthenticating
                                    ? 'Autenticando...'
                                    : 'Autenticar no servidor',
                              ),
                            ),
                          ),
                          if (_usedDemoMode) ...[
                            const SizedBox(height: 14),
                            const _ModeBanner(
                              text:
                                  'Modo demonstracao ativo. Defina DELETE_ACCOUNT_AUTH_URL e DELETE_ACCOUNT_DELETE_URL para usar seu backend real.',
                            ),
                          ],
                          if (_statusMessage != null) ...[
                            const SizedBox(height: 14),
                            _StatusMessage(
                              message: _statusMessage!,
                              isSuccess: _isAuthenticated || _deletionRequested,
                            ),
                          ],
                          if (_isAuthenticated) ...[
                            const SizedBox(height: 24),
                            const _DeletionDetailsCard(),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.tonal(
                                onPressed: _isDeleting
                                    ? null
                                    : _requestDeletion,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFB3261E),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                ),
                                child: Text(
                                  _isDeleting
                                      ? 'Excluindo dados...'
                                      : 'Excluir meus dados',
                                ),
                              ),
                            ),
                          ],
                          if (_deletionRequested) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                'Solicitacao recebida. Os dados pessoais e de autenticacao associados a conta serao removidos segundo a politica do servico.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF194D1F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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

class _DeletionDetailsCard extends StatelessWidget {
  const _DeletionDetailsCard();

  static const _supportEmail = String.fromEnvironment(
    'DELETE_ACCOUNT_SUPPORT_EMAIL',
    defaultValue: 'suporte@seudominio.com',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9C2B2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informacoes importantes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF40241C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A exclusao remove dados cadastrais, credenciais e historico vinculado a conta. Registros exigidos por obrigacao legal podem ser mantidos pelo prazo minimo necessario.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5E4138),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Suporte: $_supportEmail',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF8B3D28),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeBanner extends StatelessWidget {
  const _ModeBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6D8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1BF5A)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6E5800),
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({required this.message, required this.isSuccess});

  final String message;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSuccess
        ? const Color(0xFFE7F6EA)
        : const Color(0xFFFDECEC);
    final foregroundColor = isSuccess
        ? const Color(0xFF1C5A2A)
        : const Color(0xFF8E2323);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}

class UserService {
  final apiUrl = dotenv.env['API_URL'];

  Future<bool> getDeleteAccountInfo({
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
        return data['success'] ?? false;
      } else {
        print('Failed to authenticate: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error fetching delete account info: $e');
      return false;
    }
  }
}
