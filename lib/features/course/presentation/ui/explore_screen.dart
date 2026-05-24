import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/presentation/cubit/course_cubit.dart';
import 'package:learn_craft/features/course/presentation/ui/lesson_map_screen.dart';
import 'package:learn_craft/features/profile/presentation/cubit/user_cubit.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<CourseCubit>().loadCourses();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CourseEntity> _filtered(List<CourseEntity> courses) {
    if (_query.isEmpty) return courses;
    return courses.where((c) {
      return c.title.toLowerCase().contains(_query) ||
          c.description.toLowerCase().contains(_query) ||
          c.category.toLowerCase().contains(_query) ||
          c.skillsTaught.any((s) => s.toLowerCase().contains(_query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocBuilder<CourseCubit, CourseState>(
          builder: (context, state) {
            final allCourses =
                state is CourseLoaded ? state.courses : <CourseEntity>[];
            final courses = _filtered(allCourses);

            return RefreshIndicator(
              color: AppColors.green,
              onRefresh: () => context.read<CourseCubit>().loadCourses(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // ── Top bar ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.explore_rounded,
                            color: AppColors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Explore',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.dark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          // XP chip
                          BlocBuilder<UserCubit, UserState>(
                            builder: (context, userState) {
                              final xp = userState is UserLoaded
                                  ? userState.user.xpPoints.toString()
                                  : '0';
                              return _StatChip(
                                icon: Icons.star_rounded,
                                value: xp,
                                color: AppColors.orange,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // ── Search bar ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.greyBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.greyLight, width: 2),
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
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.chevronGrey,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.dark,
                                ),
                                decoration: const InputDecoration(
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
                            // Clear button
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () => _searchCtrl.clear(),
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(Icons.cancel_rounded,
                                      color: AppColors.labelGrey, size: 18),
                                ),
                              )
                            else
                              const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ── Content ──
                  if (state is CourseLoading || state is CourseInitial)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.green),
                      ),
                    )
                  else if (state is CourseError)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        icon: Icons.wifi_off_rounded,
                        iconColor: AppColors.red,
                        title: 'Connection error',
                        subtitle: 'Pull down to retry',
                      ),
                    )
                  else if (courses.isEmpty && _query.isNotEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        icon: Icons.search_off_rounded,
                        iconColor: AppColors.labelGrey,
                        title: 'No results',
                        subtitle: 'No courses match "$_query"',
                      ),
                    )
                  else if (state is CourseLoaded && allCourses.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(
                        icon: Icons.auto_stories_rounded,
                        iconColor: AppColors.chevronGrey,
                        title: 'No courses yet',
                        subtitle:
                            'Tap SEED DATA on Home\nto add a sample course',
                      ),
                    )
                  else if (state is CourseLoaded) ...[
                    // Section header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text(
                              _query.isEmpty ? 'MY COURSES' : 'RESULTS',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.labelGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.green
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${courses.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList.separated(
                        itemCount: courses.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) => _CourseCard(
                          course: courses[index],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LessonMapScreen(
                                  course: courses[index]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Course card ───────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final CourseEntity course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColor(course.level);

    return GestureDetector(
      onTap: onTap,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored top strip
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: levelColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + arrow
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.dark,
                            letterSpacing: -0.3,
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

                  const SizedBox(height: 6),

                  // Description
                  Text(
                    course.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 14),

                  // Skills chips
                  if (course.skillsTaught.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: course.skillsTaught
                          .take(4)
                          .map(
                            (skill) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.greyBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: AppColors.greyLight, width: 1.5),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 14),

                  // Bottom row
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded,
                          size: 15,
                          color: levelColor.withValues(alpha: 0.8)),
                      const SizedBox(width: 5),
                      Text(
                        '${course.totalLessons} lessons',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: levelColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.greenShadow,
                              offset: Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Text(
                          'START',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
}

// ── Empty / error state ───────────────────────────────────────
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat chip ─────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.dark,
            ),
          ),
        ],
      ),
    );
  }
}
