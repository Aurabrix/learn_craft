import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_assets.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/auth/presentation/ui/duo_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              // ── Hero image ──────────────────────────────
              Image.asset(
                AppAssets.appHero,
                height: 280,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 32),

              // ── Title ───────────────────────────────────
              Text(
                'Learn anything,\nanytime.',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.2,
                  color: AppColors.dark,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Upload a doc or URL and turn it into\na gamified learning experience.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.dark.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Filled button ───────────────────────────
              DuoGreenButton(
                label: 'Get Started',
                onTap: () => context.push(AppPaths.createUser),
              ),

              const SizedBox(height: 14),

              // ── Outlined button ─────────────────────────
              DuoOutlinedButton(
                label: 'I already have an account',
                onTap: () => context.push(AppPaths.login),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
