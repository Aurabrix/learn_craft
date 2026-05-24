import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/presentation/cubit/course_cubit.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CourseCubit>().loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.greenShadow,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Search bar (Duo style) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.greyBg,
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
              child: const Row(
                children: [
                  SizedBox(width: 14),
                  Icon(Icons.search_rounded, color: AppColors.grey, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(
                          color: AppColors.chevronGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Section title ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'ALL COURSES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.labelGrey,
                letterSpacing: 1,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Course list ──
          Expanded(
            child: BlocBuilder<CourseCubit, CourseState>(
              builder: (context, state) {
                if (state is CourseLoading || state is CourseInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  );
                }

                if (state is CourseError) {
                  return _EmptyState(
                    icon: Icons.error_outline_rounded,
                    iconColor: AppColors.red,
                    title: 'Something went wrong',
                    subtitle: state.message,
                  );
                }

                if (state is CourseLoaded) {
                  if (state.courses.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.menu_book_rounded,
                      iconColor: AppColors.greyLight,
                      title: 'No courses yet',
                      subtitle: 'Tap SEED DATA to add a sample course',
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.green,
                    onRefresh: () =>
                        context.read<CourseCubit>().loadCourses(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: state.courses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _CourseCard(course: state.courses[index]),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty / error state ─────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 64),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Course card (Duo 3D style) ──────────────────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(course.level);

    return GestureDetector(
      onTap: () {
        // TODO: navigate to course detail
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyLight, width: 2),
          boxShadow: const [
            BoxShadow(
              color: AppColors.greyLight,
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // ── Icon ──
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _categoryIcon(course.category),
                color: color,
                size: 26,
              ),
            ),

            const SizedBox(width: 14),

            // ── Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.menu_book_rounded,
                        label: '${course.totalLessons} lessons',
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.quiz_rounded,
                        label: '${course.totalQuizzes} quizzes',
                      ),
                      const Spacer(),
                      _LevelBadge(level: course.level),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.chevronGrey,
              size: 24,
            ),
          ],
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

  static IconData _categoryIcon(String category) {
    switch (category) {
      case 'Mobile Development':
        return Icons.phone_android_rounded;
      case 'Web Development':
        return Icons.language_rounded;
      case 'Data Science':
        return Icons.analytics_rounded;
      case 'Design':
        return Icons.palette_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}

// ── Info chip ───────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Level badge (Duo colored pill) ──────────────────────────
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final color = _CourseCard._levelColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
