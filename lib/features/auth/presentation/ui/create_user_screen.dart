import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/utils/app_toast.dart';
import 'package:learn_craft/core/utils/extensions.dart';
import 'package:learn_craft/core/widgets/custom_textfield.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      AppToast.error(context, 'Please enter a username');
      return;
    }
    if (email.isEmpty) {
      AppToast.error(context, 'Please enter your email');
      return;
    }
    if (!email.contains('@')) {
      AppToast.error(context, 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      AppToast.error(context, 'Please enter a password');
      return;
    }
    if (password.length < 8) {
      AppToast.error(context, 'Password must be at least 8 characters');
      return;
    }

    context.push(AppPaths.otp, extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              48.vBox,
              Text(
                'Create account',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              8.vBox,
              Text(
                'Fill in your details to get started.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              40.vBox,
              CustomTextfield(
                label: 'Username',
                hint: 'e.g. johndoe',
                controller: _usernameController,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              16.vBox,
              CustomTextfield(
                label: 'Email',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline),
              ),
              16.vBox,
              CustomTextfield(
                label: 'Password',
                hint: 'Min. 8 characters',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              32.vBox,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onContinue,
                  child: const Text('Continue'),
                ),
              ),
              24.vBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: theme.textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Log in',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
