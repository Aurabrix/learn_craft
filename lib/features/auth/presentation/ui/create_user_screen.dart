import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/utils/app_toast.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'duo_widgets.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _usernameController = TextEditingController();
  final _emailController    = TextEditingController();
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
    final email    = _emailController.text.trim();
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

    context.read<AuthBloc>().add(
      CreateUserRequested(name: username, email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) AppToast.error(context, state.message);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DuoBackButton(onTap: () => context.pop()),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── Title ──────────────────────────
                      Text(
                        'Create a profile',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1A2E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Join thousands of learners today 🚀',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF777777),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Username ───────────────────────
                      DuoLabel('USERNAME'),
                      const SizedBox(height: 6),
                      DuoTextField(
                        controller: _usernameController,
                        hint: 'e.g. QuizMaster99',
                      ),

                      const SizedBox(height: 20),

                      // ── Email ──────────────────────────
                      DuoLabel('EMAIL ADDRESS'),
                      const SizedBox(height: 6),
                      DuoTextField(
                        controller: _emailController,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      // ── Password ───────────────────────
                      DuoLabel('PASSWORD'),
                      const SizedBox(height: 6),
                      DuoTextField(
                        controller: _passwordController,
                        hint: '••••••••',
                        obscureText: _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFFAAAAAA),
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Continue button ────────────────
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return DuoGreenButton(
                            label: 'CREATE ACCOUNT',
                            isLoading: state is AuthLoading,
                            onTap: state is AuthLoading ? null : _onContinue,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Login link ─────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF777777),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'LOG IN',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF58CC02),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
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
