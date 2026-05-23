import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/utils/app_toast.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'duo_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      AppToast.error(context, 'Please enter your email');
      return;
    }
    if (!email.contains('@')) {
      AppToast.error(context, 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      AppToast.error(context, 'Please enter your password');
      return;
    }
    if (password.length < 8) {
      AppToast.error(context, 'Password must be at least 8 characters');
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(email: email, password: password),
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
                        'Welcome back!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1A2E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log in to continue your streak 🔥',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF777777),
                        ),
                      ),

                      const SizedBox(height: 32),

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

                      const SizedBox(height: 12),

                      // ── Forgot password ────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forgot password?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF1CB0F6),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Login button ───────────────────
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return DuoGreenButton(
                            label: 'LOG IN',
                            isLoading: state is AuthLoading,
                            onTap: state is AuthLoading ? null : _onLogin,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Sign up link ───────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF777777),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppPaths.createUser),
                            child: Text(
                              'SIGN UP',
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
