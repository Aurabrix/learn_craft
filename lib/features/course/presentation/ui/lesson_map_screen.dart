import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/constants/app_firebase.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/course/data/datasources/course_remote_data_source_impl.dart';
import 'package:learn_craft/features/course/data/repositories/course_repository_impl.dart';
import 'package:learn_craft/features/course/domain/entities/course_entity.dart';
import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';
import 'package:learn_craft/features/course/domain/usecases/get_lessons_use_case.dart';
import 'package:learn_craft/features/course/presentation/cubit/lesson_cubit.dart';
import 'package:learn_craft/features/course/presentation/ui/lesson_study_screen.dart';

// ── Zigzag X positions ───────────────────────────────────────
const List<double> _xPattern = [0.20, 0.45, 0.70, 0.45, 0.20, 0.45, 0.70];

double _nodeX(int index, double width) =>
    _xPattern[index % _xPattern.length] * width;

class LessonMapScreen extends StatelessWidget {
  const LessonMapScreen({super.key, required this.course});

  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LessonCubit(
        getLessonsUseCase: GetLessonsUseCase(
          CourseRepositoryImpl(remoteDataSource: CourseRemoteDataSourceImpl()),
        ),
      )..loadLessons(course.id),
      child: _LessonMapBody(course: course),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────
class _LessonMapBody extends StatefulWidget {
  const _LessonMapBody({required this.course});

  final CourseEntity course;

  @override
  State<_LessonMapBody> createState() => _LessonMapBodyState();
}

class _LessonMapBodyState extends State<_LessonMapBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF8E2),
      body: BlocBuilder<LessonCubit, LessonState>(
        builder: (context, state) {
          final lessons =
              state is LessonLoaded ? state.lessons : <LessonEntity>[];
          final completedCount =
              lessons.where((l) => l.isCompleted).length;
          final progress =
              lessons.isEmpty ? 0.0 : completedCount / lessons.length;
          final currentLesson =
              lessons.where((l) => l.isCurrentLesson).firstOrNull ??
                  lessons.where((l) => !l.isCompleted).firstOrNull;

          return Column(
            children: [
              _Header(
                course: widget.course,
                completedCount: completedCount,
                total: lessons.length,
                progress: progress,
              ),
              Expanded(
                child: state is LessonLoading || state is LessonInitial
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.green),
                      )
                    : state is LessonError
                        ? Center(
                            child: Text(state.message,
                                style: const TextStyle(
                                    color: AppColors.red)))
                        : _QuestMap(
                            lessons: lessons,
                            pulseAnim: _pulseAnim,
                          ),
              ),
              _StartBar(
                currentLesson: currentLesson,
                lessons: lessons,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({
    required this.course,
    required this.completedCount,
    required this.total,
    required this.progress,
  });

  final CourseEntity course;
  final int completedCount;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: back | title | badge ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.dark, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 22,
                  ),
                  // Course title + category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.dark,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          course.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.labelGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Completed / total chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            color: AppColors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$completedCount / $total',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.dark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: AppColors.greyBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom border ──
            Container(
              height: 2,
              color: AppColors.greyLight,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quest map ────────────────────────────────────────────────
class _QuestMap extends StatelessWidget {
  const _QuestMap({required this.lessons, required this.pulseAnim});

  final List<LessonEntity> lessons;
  final Animation<double> pulseAnim;

  static const double _nodeSize   = 80.0;
  static const double _rowHeight  = 130.0;
  static const double _topPad     = 50.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        final totalH = _topPad + lessons.length * _rowHeight + 60.0;

        return SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: W,
            height: math.max(totalH, constraints.maxHeight),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Path ──
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(
                      lessonCount : lessons.length,
                      width       : W,
                      nodeSize    : _nodeSize,
                      rowHeight   : _rowHeight,
                      topPad      : _topPad,
                    ),
                  ),
                ),

                // ── Nodes + labels ──
                ...List.generate(lessons.length, (i) {
                  final lesson   = lessons[i];
                  final cx       = _nodeX(i, W);
                  final cy       = _topPad + i * _rowHeight;
                  final isCurrent = lesson.isCurrentLesson;
                  final onRight  = cx < W * 0.5;

                  // Random avatar — seeded by index so stable per rebuild,
                  // repetition allowed (each node picks independently)
                  final avatarUrl = AppFirebase.avatarUrls[
                      math.Random(i * 31 + 7).nextInt(
                          AppFirebase.avatarUrls.length)];

                  return Stack(
                    children: [
                      // Label card
                      Positioned(
                        left:  onRight ? cx + _nodeSize / 2 + 8 : null,
                        right: onRight ? null : W - cx + _nodeSize / 2 + 8,
                        top:   cy - _nodeSize / 2,
                        child: _LabelCard(
                          lesson  : lesson,
                          index   : i,
                          maxWidth: W * 0.40,
                        ),
                      ),

                      // Node
                      Positioned(
                        left: cx - _nodeSize / 2,
                        top : cy - _nodeSize / 2,
                        child: isCurrent
                            ? AnimatedBuilder(
                                animation: pulseAnim,
                                builder: (_, _) => Transform.scale(
                                  scale: pulseAnim.value,
                                  child: _Node(
                                    lesson       : lesson,
                                    index        : i,
                                    lessons      : lessons,
                                    nodeSize     : _nodeSize,
                                    avatarUrl    : avatarUrl,
                                  ),
                                ),
                              )
                            : _Node(
                                lesson   : lesson,
                                index    : i,
                                lessons  : lessons,
                                nodeSize : _nodeSize,
                                avatarUrl: avatarUrl,
                              ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Node ─────────────────────────────────────────────────────
class _Node extends StatelessWidget {
  const _Node({
    required this.lesson,
    required this.index,
    required this.lessons,
    required this.nodeSize,
    required this.avatarUrl,
  });

  final LessonEntity       lesson;
  final int                index;
  final List<LessonEntity> lessons;
  final double        nodeSize;
  final String        avatarUrl;

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;
    final isCurrent   = lesson.isCurrentLesson;
    final isLocked    = !isCompleted && !isCurrent;

    // Ring colors
    final ringColor = isCompleted
        ? AppColors.greenShadow
        : isCurrent
            ? Colors.white
            : const Color(0xFFCCCCCC);

    // Background tint behind avatar (locked = desaturate)
    final bgColor = isLocked
        ? const Color(0xFFDDDDDD)
        : isCompleted
            ? const Color(0xFF46A302)
            : AppColors.green;

    return GestureDetector(
      onTap: (isCurrent || isCompleted)
          ? () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => LessonStudyScreen(
                  lesson: lesson,
                  lessonNumber: index + 1,
                  lessons: lessons,
                ),
              ))
          : null,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Glow ring for current
          if (isCurrent)
            Container(
              width : nodeSize + 22,
              height: nodeSize + 22,
              decoration: BoxDecoration(
                shape : BoxShape.circle,
                color : AppColors.green.withValues(alpha: 0.25),
              ),
            ),

          // Main circle
          Container(
            width : nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor,
              border: Border.all(color: ringColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color : isLocked
                      ? const Color(0xFFBBBBBB)
                      : AppColors.greenShadow,
                  offset: const Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: isLocked
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.33, 0.33, 0.33, 0, 0,
                        0.33, 0.33, 0.33, 0, 0,
                        0.33, 0.33, 0.33, 0, 0,
                        0,    0,    0,    1, 0,
                      ]),
                      child: _AvatarImage(url: avatarUrl, size: nodeSize),
                    )
                  : _AvatarImage(url: avatarUrl, size: nodeSize),
            ),
          ),

          // Completed checkmark badge
          if (isCompleted)
            Positioned(
              right : 0,
              bottom: 0,
              child : Container(
                width : 26,
                height: 26,
                decoration: BoxDecoration(
                  color : AppColors.green,
                  shape : BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
              ),
            ),

          // Locked badge
          if (isLocked)
            Positioned(
              right : 0,
              bottom: 0,
              child : Container(
                width : 26,
                height: 26,
                decoration: BoxDecoration(
                  color : const Color(0xFFAAAAAA),
                  shape : BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: const Icon(Icons.lock_rounded,
                    color: Colors.white, size: 13),
              ),
            ),

          // Current play badge
          if (isCurrent)
            Positioned(
              right : 0,
              bottom: 0,
              child : Container(
                width : 28,
                height: 28,
                decoration: BoxDecoration(
                  color : Colors.white,
                  shape : BoxShape.circle,
                  border: Border.all(
                      color: AppColors.green, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color : AppColors.greenShadow,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: AppColors.green, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Avatar image ─────────────────────────────────────────────
class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl     : url,
      width        : size,
      height       : size,
      fit          : BoxFit.cover,
      placeholder  : (_, _) => const SizedBox.shrink(),
      errorWidget  : (_, _, _) => const Icon(
          Icons.person_rounded,
          color: Colors.white,
          size: 36),
    );
  }
}

// ── Label card ───────────────────────────────────────────────
class _LabelCard extends StatelessWidget {
  const _LabelCard({
    required this.lesson,
    required this.index,
    required this.maxWidth,
  });

  final LessonEntity lesson;
  final int          index;
  final double       maxWidth;

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;
    final isCurrent   = lesson.isCurrentLesson;
    final isLocked    = !isCompleted && !isCurrent;

    return SizedBox(
      width: maxWidth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.greenLight
              : isCurrent
                  ? Colors.white
                  : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? AppColors.green.withValues(alpha: 0.35)
                : isCurrent
                    ? AppColors.green
                    : const Color(0xFFDDDDDD),
            width: 2,
          ),
          boxShadow: isCurrent
              ? const [
                  BoxShadow(
                    color : AppColors.greyLight,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status badge
            if (isCurrent)
              _Badge(label: 'NOW', bg: AppColors.green, text: Colors.white),
            if (isCompleted)
              _Badge(
                  label: 'DONE',
                  bg: AppColors.greenLight,
                  text: AppColors.green),
            if (isCurrent || isCompleted) const SizedBox(height: 4),

            // Topic
            Text(
              lesson.topic,
              style: TextStyle(
                fontSize  : 13,
                fontWeight: FontWeight.w800,
                color     : isLocked
                    ? const Color(0xFFAAAAAA)
                    : AppColors.dark,
                letterSpacing: -0.2,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (!isLocked && lesson.summary.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                lesson.summary,
                style: TextStyle(
                  fontSize  : 11,
                  color     : isCompleted
                      ? AppColors.green
                      : AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
                maxLines : 1,
                overflow : TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Badge ────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.bg, required this.text});

  final String label;
  final Color  bg;
  final Color  text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color        : bg,
        borderRadius : BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize  : 9,
          fontWeight: FontWeight.w900,
          color     : text,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Dashed path painter ───────────────────────────────────────
class _PathPainter extends CustomPainter {
  const _PathPainter({
    required this.lessonCount,
    required this.width,
    required this.nodeSize,
    required this.rowHeight,
    required this.topPad,
  });

  final int    lessonCount;
  final double width;
  final double nodeSize;
  final double rowHeight;
  final double topPad;

  @override
  void paint(Canvas canvas, Size size) {
    if (lessonCount < 2) return;

    final paint = Paint()
      ..color      = const Color(0xFF8FD44A)
      ..strokeWidth= 4.5
      ..style      = PaintingStyle.stroke
      ..strokeCap  = StrokeCap.round;

    for (int i = 0; i < lessonCount - 1; i++) {
      final x1 = _nodeX(i,     width);
      final y1 = topPad + i       * rowHeight;
      final x2 = _nodeX(i + 1, width);
      final y2 = topPad + (i + 1) * rowHeight;
      _drawDashed(canvas, paint, Offset(x1, y1), Offset(x2, y2));
    }
  }

  void _drawDashed(
      Canvas canvas, Paint paint, Offset start, Offset end) {
    const dash = 10.0;
    const gap  = 7.0;

    final dx   = end.dx - start.dx;
    final dy   = end.dy - start.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    final nx   = dx / dist;
    final ny   = dy / dist;
    final skip = nodeSize / 2 + 8;
    double d   = skip;

    while (d < dist - skip) {
      final de = math.min(d + dash, dist - skip);
      canvas.drawLine(
        Offset(start.dx + nx * d,  start.dy + ny * d),
        Offset(start.dx + nx * de, start.dy + ny * de),
        paint,
      );
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) =>
      old.lessonCount != lessonCount || old.width != width;
}

// ── Bottom START PLAY bar ─────────────────────────────────────
class _StartBar extends StatelessWidget {
  const _StartBar({
    required this.currentLesson,
    required this.lessons,
  });

  final LessonEntity?      currentLesson;
  final List<LessonEntity> lessons;

  @override
  Widget build(BuildContext context) {
    final canPlay = currentLesson != null;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color : Colors.white,
        border: Border(
            top: BorderSide(color: AppColors.greyLight, width: 2)),
        boxShadow: [
          BoxShadow(
            color    : Color(0x12000000),
            blurRadius: 16,
            offset   : Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canPlay) ...[
            Row(
              children: [
                Container(
                  width : 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color : AppColors.green,
                    shape : BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Up next: ${currentLesson!.topic}',
                    style: const TextStyle(
                      fontSize  : 13,
                      fontWeight: FontWeight.w700,
                      color     : AppColors.grey,
                    ),
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: canPlay
                ? () {
                    final idx = lessons.indexOf(currentLesson!);
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LessonStudyScreen(
                        lesson: currentLesson!,
                        lessonNumber: idx + 1,
                        lessons: lessons,
                      ),
                    ));
                  }
                : null,
            child: Container(
              width : double.infinity,
              height: 58,
              decoration: BoxDecoration(
                color         : canPlay ? AppColors.green : AppColors.greyLight,
                borderRadius  : BorderRadius.circular(18),
                boxShadow     : canPlay
                    ? const [
                        BoxShadow(
                          color    : AppColors.greenShadow,
                          offset   : Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width : 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color : Colors.white.withValues(alpha: 0.25),
                      shape : BoxShape.circle,
                    ),
                    child: Icon(
                      canPlay
                          ? Icons.play_arrow_rounded
                          : Icons.check_circle_rounded,
                      color: canPlay ? Colors.white : AppColors.chevronGrey,
                      size : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    canPlay ? 'START PLAY' : 'ALL COMPLETED!',
                    style: TextStyle(
                      fontSize  : 17,
                      fontWeight: FontWeight.w900,
                      color     : canPlay ? Colors.white : AppColors.chevronGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
