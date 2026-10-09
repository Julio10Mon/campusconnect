import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_header.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref.read(authControllerProvider.notifier).register(
            nombre: _nameCtrl.text,
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            confirmPassword: _confirmCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authControllerProvider);
    final isLoading = formState is AuthFormLoading;
    final colors = Theme.of(context).colorScheme;

    ref.listen<AuthFormState>(authControllerProvider, (previous, next) {
      if (next is AuthFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: colors.error),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  const BrandHeader(compact: true),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Crea tu cuenta', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('Regístrate para acceder a CampusConnect.', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _nameCtrl,
                        label: AppStrings.fullName,
                        validator: (v) => (v == null || v.trim().length < 3) ? 'Ingresa tu nombre completo.' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _emailCtrl,
                        label: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Ingresa tu correo.';
                          if (!v.contains('@')) return 'Correo inválido.';
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
                        validator: (v) => (v == null || v.length < 6) ? 'Mínimo 6 caracteres.' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _confirmCtrl,
                        label: AppStrings.confirmPassword,
                        obscureText: _obscure,
                        validator: (v) => (v != _passwordCtrl.text) ? 'Las contraseñas no coinciden.' : null,
                      ),
                      const SizedBox(height: 26),
                      AppButton(label: AppStrings.register, isLoading: isLoading, onPressed: _submit),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('¿Ya tienes cuenta?', style: Theme.of(context).textTheme.bodySmall),
                          TextButton(
                            onPressed: isLoading ? null : () => context.go('/login'),
                            child: const Text(AppStrings.login),
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
}
