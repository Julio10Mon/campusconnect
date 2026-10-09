import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';
import '../../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  // Botón social activo
  String? _pendingProvider;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _pendingProvider = null);
      ref.read(authControllerProvider.notifier).login(_emailCtrl.text, _passwordCtrl.text);
    }
  }

  void _submitGoogle() {
    setState(() => _pendingProvider = 'google');
    ref.read(authControllerProvider.notifier).loginWithGoogle();
  }

  void _submitFacebook() {
    setState(() => _pendingProvider = 'facebook');
    ref.read(authControllerProvider.notifier).loginWithFacebook();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authControllerProvider);
    final isLoading = formState is AuthFormLoading;
    final colors = Theme.of(context).colorScheme;

    ref.listen<AuthFormState>(authControllerProvider, (previous, next) {
      if (next is AuthFormError) {
        setState(() => _pendingProvider = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: colors.error),
        );
      }
      // Redirección automática
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BrandHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Inicia sesión',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Accede con tu correo institucional o personal.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 28),
                      AppTextField(
                        controller: _emailCtrl,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Ingresa tu correo.';
                          if (!value.contains('@')) return 'Correo inválido.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _passwordCtrl,
                        label: AppStrings.password,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isLoading ? null : () => _showResetDialog(context),
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        label: AppStrings.login,
                        isLoading: isLoading && _pendingProvider == null,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: colors.outline)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('O continúa con', style: Theme.of(context).textTheme.labelMedium),
                          ),
                          Expanded(child: Divider(color: colors.outline)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SocialLoginButton(
                        iconAsset: 'assets/icons/google_logo.png',
                        label: 'Continuar con Google',
                        isLoading: isLoading && _pendingProvider == 'google',
                        onPressed: isLoading ? null : _submitGoogle,
                      ),
                      const SizedBox(height: 12),
                      SocialLoginButton(
                        icon: Icons.facebook,
                        iconColor: const Color(0xFF1877F2),
                        label: 'Continuar con Facebook',
                        isLoading: isLoading && _pendingProvider == 'facebook',
                        onPressed: isLoading ? null : _submitFacebook,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('¿No tienes cuenta?', style: Theme.of(context).textTheme.bodySmall),
                          TextButton(
                            onPressed: isLoading ? null : () => context.go('/register'),
                            child: const Text(AppStrings.register),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _emailCtrl.text);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Recuperar contraseña'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: AppStrings.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).sendPasswordReset(ctrl.text);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Si el correo existe, te enviamos un enlace de recuperación.')),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
