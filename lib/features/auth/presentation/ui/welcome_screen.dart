import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      body: Stack(
        children: [
          // ── Gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8B7FFF), AppColors.brandPrimary, Color(0xFF5A52D5)],
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -80,
            right: -80,
            child: _circle(220, 0.08),
          ),
          Positioned(
            top: screenHeight * 0.14,
            left: -50,
            child: _circle(130, 0.05),
          ),
          Positioned(
            top: screenHeight * 0.36,
            right: -30,
            child: _circle(100, 0.06),
          ),

          // ── White card at bottom ──
          Column(
            children: [
              SizedBox(height: screenHeight * 0.50),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to\nplay? 🎯',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: AppColors.lightOnSurface,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Join thousands of players testing their knowledge every day.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightOnSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Stats row
                        Row(
                          children: [
                            _buildStat('10K+', 'Players'),
                            Container(
                              width: 1,
                              height: 36,
                              color: AppColors.lightBorder,
                            ),
                            _buildStat('500+', 'Quizzes'),
                            Container(
                              width: 1,
                              height: 36,
                              color: AppColors.lightBorder,
                            ),
                            _buildStat('20+', 'Topics'),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // Get started
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => context.go(AppPaths.createUser),
                            child: const Text('Get Started'),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Sign in link
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => context.go(AppPaths.login),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandPrimary,
                              side: const BorderSide(
                                color: AppColors.softBorder,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('I already have an account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Hero: category icons + app name + tagline ──
          SafeArea(
            child: SizedBox(
              height: screenHeight * 0.50,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category icon trio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IconTile(
                          icon: Icons.science_rounded,
                          color: AppColors.gameTeal,
                          size: 48,
                        ),
                        const SizedBox(width: 14),
                        _IconTile(
                          icon: Icons.quiz_rounded,
                          color: Colors.white,
                          size: 68,
                          iconSize: 36,
                          isLarge: true,
                        ),
                        const SizedBox(width: 14),
                        _IconTile(
                          icon: Icons.castle_rounded,
                          color: AppColors.gameCoral,
                          size: 48,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Learn Craft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level up your knowledge!',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );

  Widget _buildStat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.brandPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.color,
    required this.size,
    this.iconSize,
    this.isLarge = false,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isLarge ? Colors.white : color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(isLarge ? 22 : 16),
        boxShadow: isLarge
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
        border: isLarge
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Icon(
        icon,
        color: isLarge ? AppColors.brandPrimary : Colors.white,
        size: iconSize ?? (size * 0.5),
      ),
    );
  }
}
