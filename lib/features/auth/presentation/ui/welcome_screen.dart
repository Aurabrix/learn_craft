import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_assets.dart';
import 'package:learn_craft/core/constants/app_paths.dart';

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
                  color: const Color(0xFF1A1A2E),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Upload a doc or URL and turn it into\na gamified learning experience.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Filled button ───────────────────────────
              _GreenFilledButton(
                label: 'Get Started',
                onTap: () => context.push(AppPaths.createUser),
              ),

              const SizedBox(height: 14),

              // ── Outlined button ─────────────────────────
              _GreenOutlinedButton(
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

// ── Filled green button ──────────────────────────────────────
class _GreenFilledButton extends StatelessWidget {
  const _GreenFilledButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const _green = Color(0xFF58CC02);
  static const _greenShadow = Color(0xFF46A302);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: _greenShadow,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ── Outlined green button ────────────────────────────────────
class _GreenOutlinedButton extends StatelessWidget {
  const _GreenOutlinedButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  static const _green = Color(0xFF58CC02);
  static const _borderColor = Color(0xFFD0D0D0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _borderColor, width: 2),
          boxShadow: const [
            BoxShadow(
              color: _borderColor,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _green,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
