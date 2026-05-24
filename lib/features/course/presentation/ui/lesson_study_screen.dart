import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/course/domain/entities/lesson_entity.dart';
import 'package:learn_craft/features/quiz/presentation/ui/quiz_screen.dart';

class LessonStudyScreen extends StatelessWidget {
  const LessonStudyScreen({
    super.key,
    required this.lesson,
    required this.lessonNumber,
    required this.lessons,
  });

  final LessonEntity       lesson;
  final int                lessonNumber;
  final List<LessonEntity> lessons;

  int get _totalLessons => lessons.length;

  /// Next lesson if any and not locked
  LessonEntity? get _nextLesson {
    final nextIndex = lessonNumber; // lessonNumber is 1-based, so nextIndex = lessonNumber
    if (nextIndex >= lessons.length) return null;
    final next = lessons[nextIndex];
    // Only navigate forward if it's current or completed (unlocked)
    if (!next.isCompleted && !next.isCurrentLesson) return null;
    return next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _TopBar(
            lessonNumber: lessonNumber,
            totalLessons: _totalLessons,
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Lesson hero card ──
                SliverToBoxAdapter(
                  child: _LessonHero(
                    lesson: lesson,
                    lessonNumber: lessonNumber,
                  ),
                ),

                // ── Content label ──
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 12),
                    child: Row(
                      children: [
                        Icon(Icons.menu_book_rounded,
                            color: AppColors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'STUDY MATERIAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.labelGrey,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Markdown content ──
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverToBoxAdapter(
                    child: MarkdownBody(
                      data: lesson.content,
                      styleSheet: _mdStyle(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom bar ──
      bottomNavigationBar: _BottomBar(
        lesson: lesson,
        lessonNumber: lessonNumber,
        lessons: lessons,
        nextLesson: _nextLesson,
      ),
    );
  }

  MarkdownStyleSheet _mdStyle() {
    return MarkdownStyleSheet(
      h1: const TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w900,
        color: AppColors.dark,
        height: 1.3,
      ),
      h2: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.dark,
        height: 1.35,
      ),
      h3: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.dark,
        height: 1.4,
      ),
      p: const TextStyle(
        fontSize: 15,
        color: AppColors.grey,
        height: 1.7,
        fontWeight: FontWeight.w500,
      ),
      listBullet: const TextStyle(
        fontSize: 15,
        color: AppColors.grey,
        height: 1.7,
        fontWeight: FontWeight.w500,
      ),
      code: const TextStyle(
        fontSize: 13,
        fontFamily: 'monospace',
        color: AppColors.dark,
        backgroundColor: Color(0xFFF0F0F0),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight, width: 1.5),
      ),
      codeblockPadding: const EdgeInsets.all(16),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: AppColors.green, width: 4),
        ),
      ),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.greyLight, width: 1.5),
        ),
      ),
    );
  }
}

// ── Progress top bar ──────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.lessonNumber, required this.totalLessons});

  final int lessonNumber;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final progress = lessonNumber / totalLessons;

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.dark, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 22,
                  ),
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
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: AppColors.greyLight, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.greyLight,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      '$lessonNumber / $totalLessons',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 2, color: AppColors.greyLight),
          ],
        ),
      ),
    );
  }
}

// ── Lesson hero card ──────────────────────────────────────────
class _LessonHero extends StatelessWidget {
  const _LessonHero({required this.lesson, required this.lessonNumber});

  final LessonEntity lesson;
  final int lessonNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, Color(0xFF46A302)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.greenShadow,
            offset: Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lesson number badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'LESSON $lessonNumber',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Topic
          Text(
            lesson.topic,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),

          // Summary
          if (lesson.summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              lesson.summary,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Completed badge
          if (lesson.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.lesson,
    required this.lessonNumber,
    required this.lessons,
    required this.nextLesson,
  });

  final LessonEntity        lesson;
  final int                 lessonNumber;
  final List<LessonEntity>  lessons;
  final LessonEntity?       nextLesson;

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: AppColors.greyLight, width: 2)),
      ),
      child: isCompleted
          ? _CompletedBar(
              nextLesson: nextLesson,
              lessonNumber: lessonNumber,
              lessons: lessons,
              lesson: lesson,
            )
          : _StudyBar(lesson: lesson),
    );
  }
}

// ── Bar when lesson is NOT completed ─────────────────────────
class _StudyBar extends StatelessWidget {
  const _StudyBar({required this.lesson});
  final LessonEntity lesson;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status chip
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded,
                  color: AppColors.chevronGrey, size: 18),
              SizedBox(width: 6),
              Text(
                'Study',
                style: TextStyle(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // TAKE QUIZ button
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  courseId: lesson.courseId,
                  lessonId: lesson.lessonId,
                  lessonTopic: lesson.topic,
                  isLessonCompleted: false,
                ),
              ),
            ),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.greenShadow,
                    offset: Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'TAKE QUIZ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bar when lesson IS completed ──────────────────────────────
class _CompletedBar extends StatelessWidget {
  const _CompletedBar({
    required this.lesson,
    required this.lessonNumber,
    required this.lessons,
    required this.nextLesson,
  });

  final LessonEntity       lesson;
  final int                lessonNumber;
  final List<LessonEntity> lessons;
  final LessonEntity?      nextLesson;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Review quiz button (outline)
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizScreen(
                  courseId: lesson.courseId,
                  lessonId: lesson.lessonId,
                  lessonTopic: lesson.topic,
                  isLessonCompleted: true,
                ),
              ),
            ),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyLight, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.greyLight,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.replay_rounded,
                      color: AppColors.dark, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'REVIEW',
                    style: TextStyle(
                      color: AppColors.dark,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // NEXT button (green 3D) or "All Done" chip
        Expanded(
          child: nextLesson != null
              ? GestureDetector(
                  onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LessonStudyScreen(
                        lesson: nextLesson!,
                        lessonNumber: lessonNumber + 1,
                        lessons: lessons,
                      ),
                    ),
                  ),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.greenShadow,
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.35),
                        width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.celebration_rounded,
                          color: AppColors.green, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'ALL DONE!',
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
