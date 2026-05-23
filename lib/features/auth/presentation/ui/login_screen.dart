import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/core/utils/app_toast.dart';
import 'package:learn_craft/core/services/feedback_service.dart';
import 'package:learn_craft/core/widgets/app_button.dart';
import 'package:learn_craft/core/widgets/custom_textfield.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          AppToast.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.brandPrimary,
        body: Stack(
          children: [
            // Gradient hero background
            Container(
              height: screenHeight * 0.42,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8B7FFF), AppColors.brandPrimary],
                ),
              ),
            ),

            // Decorative circles on hero
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),

            // White card form area
            Column(
              children: [
                SizedBox(height: screenHeight * 0.30),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.lightOnSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue your journey',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightOnSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 28),
                          CustomTextfield(
                            label: 'Email',
                            hint: 'you@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icon(
                              Icons.mail_outline_rounded,
                              color: AppColors.brandPrimary.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextfield(
                            label: 'Password',
                            hint: 'Min. 8 characters',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.brandPrimary.withValues(alpha: 0.7),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.grey500,
                              ),
                              onPressed: () {
                                FeedbackService.instance.tap();
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: AppElevatedButton(
                                  onPressed:
                                      state is AuthLoading ? null : _onLogin,
                                  child: state is AuthLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Sign In'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.lightOnSurface
                                      .withValues(alpha: 0.55),
                                ),
                              ),
                              TapFeedback(
                                onTap: () => context.push(AppPaths.createUser),
                                child: Text(
                                  'Sign up',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.brandPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Hero content (logo + branding over gradient)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Learn Craft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
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
