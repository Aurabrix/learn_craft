import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learn_craft/features/auth/presentation/ui/duo_widgets.dart';
import 'package:learn_craft/features/profile/presentation/cubit/user_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final user = state is UserLoaded ? state.user : null;
          final avatarUrl = user?.profileImage ?? '';
          final username = user?.name ?? '...';
          final email = user?.email ?? '';
          final xp = user?.xpPoints ?? 0;
          final totalCredits = user?.totalAiCredits ?? 100;
          final usedCredits = user?.usedAiCredits ?? 0;
          final courses = user?.enrolledCourses.length ?? 0;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 14),

                  // ── Top bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_rounded,
                          color: AppColors.green,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.dark,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.greyBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.greyLight,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_rounded,
                              color: AppColors.grey,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Avatar ──
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.avatarBg,
                      border: Border.all(color: AppColors.green, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.greenShadow,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: avatarUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => const Icon(
                                Icons.person_rounded,
                                color: AppColors.iconGrey,
                                size: 42,
                              ),
                              errorWidget: (ctx, url, err) => const Icon(
                                Icons.person_rounded,
                                color: AppColors.iconGrey,
                                size: 42,
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              color: AppColors.iconGrey,
                              size: 42,
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Name ──
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),

                  if (user?.isPremium == true) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            size: 14,
                            color: AppColors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'SUPER',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.orange,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Stats row ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.greyBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.greyLight,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.greyLight,
                            offset: Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            _StatItem(
                              icon: Icons.star_rounded,
                              color: AppColors.orange,
                              value: _fmtNum(xp),
                              label: 'XP',
                            ),
                            _verticalDivider(),
                            _StatItem(
                              icon: Icons.auto_awesome_rounded,
                              color: AppColors.blue,
                              value: '${totalCredits - usedCredits}',
                              label: 'Credits',
                            ),
                            _verticalDivider(),
                            _StatItem(
                              icon: Icons.menu_book_rounded,
                              color: AppColors.green,
                              value: '$courses',
                              label: 'Courses',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── AI Credits usage bar ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _AiCreditsBar(
                      total: totalCredits,
                      used: usedCredits,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Menu ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _DuoMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profile',
                          onTap: () {},
                        ),
                        _DuoMenuTile(
                          icon: Icons.translate_rounded,
                          title: 'Language',
                          trailing: (user?.preferredLanguage ?? 'en')
                              .toUpperCase(),
                          onTap: () {},
                        ),
                        _DuoMenuTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          onTap: () {},
                        ),
                        _DuoMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Sign out ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _DuoSignOutTile(
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String _fmtNum(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  static Widget _verticalDivider() {
    return Container(
      width: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.greyLight,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign out?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You will need to sign in again\nto continue playing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              DuoGreenButton(
                label: 'STAY',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<AuthBloc>().add(LogoutRequested());
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.red, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'SIGN OUT',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.red,
                      letterSpacing: 0.5,
                    ),
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

// ── Stat item inside the stats bar ──────────────────────────
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.labelGrey,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Credits usage bar (same style as XP bar) ────────────
class _AiCreditsBar extends StatelessWidget {
  const _AiCreditsBar({required this.total, required this.used});
  final int total;
  final int used;

  @override
  Widget build(BuildContext context) {
    final remaining = total - used;
    final progress = total > 0 ? used / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blue.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.5),
                      offset: const Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$remaining Credits Left',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                      ),
                    ),
                    Text(
                      '$used used out of $total',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.blue.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppColors.red : AppColors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Menu tile (Duolingo 3D border style) ────────────────────
class _DuoMenuTile extends StatelessWidget {
  const _DuoMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.greyLight, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.greyLight,
                offset: Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.greyBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.grey, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dark,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.labelGrey,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.chevronGrey,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sign out tile (red Duolingo 3D style) ───────────────────
class _DuoSignOutTile extends StatelessWidget {
  const _DuoSignOutTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.redShadow,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'SIGN OUT',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.red,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
