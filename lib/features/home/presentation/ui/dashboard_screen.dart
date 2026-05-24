import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/auth/domain/entities/user_e.dart';
import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/presentation/cubit/course_cubit.dart';
import 'package:learn_craft/features/course/presentation/ui/lesson_map_screen.dart';
import 'package:learn_craft/features/profile/presentation/cubit/user_cubit.dart';
import 'package:learn_craft/features/profile/presentation/ui/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          final user = userState is UserLoaded ? userState.user : null;
          return RefreshIndicator(
            color: AppColors.green,
            onRefresh: () async {
              context.read<UserCubit>().loadUser();
              context.read<CourseCubit>().loadCourses();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Coloured hero header ──
                SliverToBoxAdapter(child: _HeroHeader(user: user)),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── Stats row ──
                SliverToBoxAdapter(child: _StatsRow(user: user)),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Continue Learning ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: _SectionHeader(
                      label: 'CONTINUE LEARNING',
                      icon: Icons.play_circle_rounded,
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: BlocBuilder<CourseCubit, CourseState>(
                    builder: (ctx, s) => _ContinueLearning(courseState: s),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // ── Recent courses (max 2) ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: _SectionHeader(
                      label: 'RECENT COURSES',
                      icon: Icons.history_rounded,
                    ),
                  ),
                ),

                BlocBuilder<CourseCubit, CourseState>(
                  builder: (context, courseState) {
                    if (courseState is CourseLoading ||
                        courseState is CourseInitial) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.green),
                          ),
                        ),
                      );
                    }
                    if (courseState is CourseError) {
                      return SliverToBoxAdapter(
                        child: _ErrorCard(message: courseState.message),
                      );
                    }
                    if (courseState is CourseLoaded) {
                      if (courseState.courses.isEmpty) {
                        return const SliverToBoxAdapter(child: _EmptyCourses());
                      }
                      final recent = courseState.courses.take(2).toList();
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                        sliver: SliverList.separated(
                          itemCount: recent.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => _CourseTile(
                            course: recent[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    LessonMapScreen(course: recent[i]),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Hero header ───────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.user});
  final UserEntity? user;

  String get _timeGreeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name.split(' ').first ?? 'there';
    final xp = user?.xpPoints ?? 0;
    const diamonds = 100;
    final avatarUrl = user?.profileImage ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF58CC02), Color(0xFF2E8B00)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: avatar + chips ──
              Row(
                children: [
                  // Profile avatar — taps to profile
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    ),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: avatarUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, _) =>
                                    _avatarFallback(name),
                                errorWidget: (_, _, _) =>
                                    _avatarFallback(name),
                              )
                            : _avatarFallback(name),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // XP chip
                  _HeroChip(
                    icon: Icons.star_rounded,
                    value: '$xp XP',
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 8),
                  // Diamond chip
                  const _HeroChip(
                    icon: Icons.diamond_rounded,
                    value: '$diamonds',
                    color: AppColors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Greeting ──
              Text(
                '$_timeGreeting,',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$name! 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ready to level up today?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: Colors.white.withValues(alpha: 0.25),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.user});
  final UserEntity? user;

  @override
  Widget build(BuildContext context) {
    final xp = user?.xpPoints ?? 0;
    final enrolled = user?.enrolledCourses.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.star_rounded,
              value: '$xp',
              label: 'Total XP',
              color: AppColors.orange,
              bgColor: const Color(0xFFFFF3E0),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.diamond_rounded,
              value: '100',
              label: 'Diamonds',
              color: AppColors.blue,
              bgColor: const Color(0xFFE3F2FD),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.auto_stories_rounded,
              value: '$enrolled',
              label: 'Enrolled',
              color: AppColors.green,
              bgColor: const Color(0xFFE8F5E9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.greyLight, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greyLight,
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.labelGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.green, size: 16),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.labelGrey,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ── Continue Learning hero card ───────────────────────────────
class _ContinueLearning extends StatelessWidget {
  const _ContinueLearning({required this.courseState});
  final CourseState courseState;

  @override
  Widget build(BuildContext context) {
    if (courseState is! CourseLoaded) return const SizedBox(height: 80);

    final courses = (courseState as CourseLoaded).courses;
    final active = courses.where((c) => c.isPublished).toList();

    if (active.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.greyLight, width: 2),
            boxShadow: const [
              BoxShadow(
                color: AppColors.greyLight,
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: AppColors.labelGrey, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No courses started yet.\nGo to Explore to begin!',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final course = active.first;
    final levelColor = _levelColor(course.level);
    final darkColor = _darken(levelColor);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LessonMapScreen(course: course)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [levelColor, darkColor],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: levelColor.withValues(alpha: 0.45),
                offset: const Offset(0, 6),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        course.level.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${course.totalLessons} lessons  •  ${course.category}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: darkColor.withValues(alpha: 0.4),
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        'CONTINUE →',
                        style: TextStyle(
                          color: levelColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: Colors.white, size: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _levelColor(String level) {
    switch (level) {
      case 'Beginner':
        return AppColors.green;
      case 'Intermediate':
        return AppColors.orange;
      case 'Advanced':
        return AppColors.red;
      default:
        return AppColors.blue;
    }
  }

  static Color _darken(Color c) => Color.fromARGB(
        (c.a * 255).round(),
        (c.r * 255 * 0.70).round(),
        (c.g * 255 * 0.70).round(),
        (c.b * 255 * 0.70).round(),
      );
}

// ── Course tile ───────────────────────────────────────────────
class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, required this.onTap});
  final CourseEntity course;
  final VoidCallback onTap;

  static Color _levelColor(String level) {
    switch (level) {
      case 'Beginner':
        return AppColors.green;
      case 'Intermediate':
        return AppColors.orange;
      case 'Advanced':
        return AppColors.red;
      default:
        return AppColors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(course.level);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greyLight, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.greyLight,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.auto_stories_rounded, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          course.level,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${course.totalLessons} lessons',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.chevronGrey, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────
class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined,
              color: AppColors.chevronGrey, size: 48),
          SizedBox(height: 12),
          Text(
            'No courses yet',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.dark),
          ),
          SizedBox(height: 6),
          Text(
            'Tap SEED DATA or go to Explore.',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

// ── Error card ────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.red.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.red, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
