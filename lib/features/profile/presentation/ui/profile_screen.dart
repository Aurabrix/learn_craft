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
          final avatarUrl = state is UserLoaded ? state.user.profileImage : '';
          final username = state is UserLoaded ? state.user.name : '...';
          final email = state is UserLoaded ? state.user.email : '';

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ── Title ──
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Avatar ──
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.avatarBg,
                          border:
                              Border.all(color: AppColors.green, width: 3.5),
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
                                      size: 44),
                                  errorWidget: (ctx, url, err) => const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.iconGrey,
                                      size: 44),
                                )
                              : const Icon(Icons.person_rounded,
                                  color: AppColors.iconGrey, size: 44),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.greenShadow,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Username ──
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Settings ──
                  const _DuoSectionLabel('SETTINGS'),
                  const SizedBox(height: 12),
                  _DuoSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    onTap: () {},
                  ),
                  _DuoSettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {},
                  ),
                  _DuoSettingTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy',
                    onTap: () {},
                  ),
                  _DuoSettingTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    onTap: () {},
                  ),

                  const SizedBox(height: 24),

                  // ── Sign out ──
                  _DuoSignOutButton(
                    onTap: () => _showLogoutDialog(context),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Learn Craft v1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.greyLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
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
                child: const Icon(Icons.logout_rounded,
                    color: AppColors.red, size: 28),
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

// ── Section label (ALL CAPS, Duolingo style) ────────────────
class _DuoSectionLabel extends StatelessWidget {
  const _DuoSectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.labelGrey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── Settings tile (Duolingo style) ──────────────────────────
class _DuoSettingTile extends StatelessWidget {
  const _DuoSettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.chevronGrey,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sign out button (red outline, Duolingo 3D style) ────────
class _DuoSignOutButton extends StatelessWidget {
  const _DuoSignOutButton({required this.onTap});
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
