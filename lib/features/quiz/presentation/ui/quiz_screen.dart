import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_craft/core/theme/app_colors.dart';
import 'package:learn_craft/features/quiz/data/datasources/quiz_remote_data_source_impl.dart';
import 'package:learn_craft/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:learn_craft/features/quiz/domain/entities/question_entity.dart';
import 'package:learn_craft/features/quiz/domain/entities/quiz_entity.dart';
import 'package:learn_craft/features/quiz/domain/usecases/get_quiz_use_case.dart';
import 'package:learn_craft/features/quiz/presentation/cubit/quiz_cubit.dart';

// ── Entry point ──────────────────────────────────────────────
class QuizScreen extends StatelessWidget {
  const QuizScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
    required this.lessonTopic,
    this.isLessonCompleted = false,
  });

  final String courseId;
  final String lessonId;
  final String lessonTopic;
  final bool   isLessonCompleted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuizCubit(
        getQuizUseCase: GetQuizUseCase(
          QuizRepositoryImpl(
            dataSource: QuizRemoteDataSourceImpl(),
          ),
        ),
      )..loadQuiz(courseId: courseId, lessonId: lessonId),
      child: _QuizBody(
        lessonTopic: lessonTopic,
        isLessonCompleted: isLessonCompleted,
      ),
    );
  }
}

// ── Body (cubit consumer) ─────────────────────────────────────
class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.lessonTopic,
    required this.isLessonCompleted,
  });
  final String lessonTopic;
  final bool   isLessonCompleted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading || state is QuizInitial) {
            return const _LoadingView();
          }
          if (state is QuizError) {
            return _ErrorView(message: state.message);
          }
          if (state is QuizNotFound) {
            return const _ErrorView(
                message: 'No quiz available for this lesson yet.');
          }
          if (state is QuizLoaded) {
            return _QuizPlay(
              quiz: state.quiz,
              lessonTopic: lessonTopic,
              isLessonCompleted: isLessonCompleted,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Actual quiz gameplay ──────────────────────────────────────
class _QuizPlay extends StatefulWidget {
  const _QuizPlay({
    required this.quiz,
    required this.lessonTopic,
    required this.isLessonCompleted,
  });
  final QuizEntity quiz;
  final String     lessonTopic;
  final bool       isLessonCompleted;

  @override
  State<_QuizPlay> createState() => _QuizPlayState();
}

class _QuizPlayState extends State<_QuizPlay>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _isChecked = false;
  int _hearts = 3;
  int _xpEarned = 0;
  int _correctCount = 0;

  bool get _reviewMode => widget.isLessonCompleted;

  // Feedback animation
  late final AnimationController _feedbackCtrl;
  late final Animation<Offset> _feedbackSlide;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _feedbackCtrl,
      curve: Curves.easeOut,
    ));

    // Review mode: pre-select correct answer and show explanation immediately
    if (_reviewMode && widget.quiz.questions.isNotEmpty) {
      _selectedOption =
          widget.quiz.questions[0].correctOptionIndex;
      _isChecked = true;
      _feedbackCtrl.value = 1.0; // jump to fully visible
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  QuestionEntity get _question =>
      widget.quiz.questions[_currentIndex];

  bool get _isCorrect =>
      _selectedOption == _question.correctOptionIndex;

  bool get _isLastQuestion =>
      _currentIndex == widget.quiz.questions.length - 1;

  void _selectOption(int index) {
    if (_isChecked) return;
    setState(() => _selectedOption = index);
  }

  void _check() {
    if (_selectedOption == null) return;
    setState(() => _isChecked = true);

    if (_isCorrect) {
      _xpEarned += _question.xpPoints;
      _correctCount++;
    } else {
      if (_hearts > 0) _hearts--;
    }

    _feedbackCtrl.forward(from: 0);
  }

  void _next() {
    if (_isLastQuestion || _hearts == 0) {
      _feedbackCtrl.reverse();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _QuizResult(
            quiz: widget.quiz,
            lessonTopic: widget.lessonTopic,
            xpEarned: _xpEarned,
            correctCount: _correctCount,
            heartsLeft: _hearts,
            isReviewMode: _reviewMode,
          ),
        ),
      );
      return;
    }

    if (_reviewMode) {
      // In review mode: jump to next question already checked
      final nextIndex = _currentIndex + 1;
      setState(() {
        _currentIndex = nextIndex;
        _selectedOption =
            widget.quiz.questions[nextIndex].correctOptionIndex;
        _isChecked = true;
      });
      _feedbackCtrl.value = 1.0; // keep panel visible instantly
    } else {
      _feedbackCtrl.reverse();
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isChecked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _question;
    final total = widget.quiz.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Stack(
      children: [
        Column(
          children: [
            // ── Top bar ──
            _TopBar(
              progress: progress,
              hearts: _hearts,
              isReviewMode: _reviewMode,
              onClose: () => Navigator.of(context).pop(),
            ),

            // ── Question area ──
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(20, 32, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty + XP chip row
                    Row(
                      children: [
                        _DifficultyChip(difficulty: q.difficulty),
                        const Spacer(),
                        _XpChip(xp: q.xpPoints),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Question label
                    Text(
                      _reviewMode ? 'Review answer' : 'Choose the correct answer',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.labelGrey,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Question text
                    Text(
                      q.questionText,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Options
                    ...List.generate(q.options.length, (i) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 14),
                        child: _OptionTile(
                          label: q.options[i],
                          index: i,
                          isSelected: _selectedOption == i,
                          isChecked: _isChecked,
                          isCorrect: i == q.correctOptionIndex,
                          onTap: () => _selectOption(i),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── Bottom CHECK / CONTINUE button ──
            _CheckButton(
              isChecked: _isChecked,
              hasSelection: _selectedOption != null,
              isCorrect: _isChecked ? _isCorrect : false,
              isLastQuestion: _isLastQuestion,
              heartsLeft: _hearts,
              onCheck: _check,
              onNext: _next,
            ),
          ],
        ),

        // ── Feedback panel (slides up from bottom) ──
        if (_isChecked)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _feedbackSlide,
              child: _FeedbackPanel(
                isCorrect: _isCorrect,
                explanation: q.explanation,
                isLastQuestion: _isLastQuestion,
                heartsLeft: _hearts,
                isReviewMode: _reviewMode,
                onNext: _next,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.progress,
    required this.hearts,
    required this.isReviewMode,
    required this.onClose,
  });

  final double progress;
  final int hearts;
  final bool isReviewMode;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.labelGrey, size: 26),
              onPressed: onClose,
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
            const SizedBox(width: 14),
            // Hearts (hidden in review mode)
            if (!isReviewMode)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      Icons.favorite_rounded,
                      color: i < hearts
                          ? AppColors.red
                          : AppColors.greyLight,
                      size: 22,
                    ),
                  );
                }),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded,
                        color: AppColors.blue, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'REVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.blue,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Difficulty chip ───────────────────────────────────────────
class _DifficultyChip extends StatelessWidget {
  const _DifficultyChip({required this.difficulty});
  final String difficulty;

  static Color _color(String d) {
    switch (d) {
      case 'Beginner':
        return AppColors.green;
      case 'Easy':
        return AppColors.blue;
      case 'Medium':
        return AppColors.orange;
      case 'Hard':
        return AppColors.red;
      default:
        return AppColors.labelGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(difficulty);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ── XP chip ───────────────────────────────────────────────────
class _XpChip extends StatelessWidget {
  const _XpChip({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.orange.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.orange, size: 14),
          const SizedBox(width: 4),
          Text(
            '+$xp XP',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.orange,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option tile ───────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isChecked,
    required this.isCorrect,
    required this.onTap,
  });

  final String label;
  final int index;
  final bool isSelected;
  final bool isChecked;
  final bool isCorrect;
  final VoidCallback onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  Color get _borderColor {
    if (!isSelected) return AppColors.greyLight;
    if (!isChecked) return AppColors.blue;
    return isCorrect ? AppColors.green : AppColors.red;
  }

  Color get _bgColor {
    if (!isSelected) return Colors.white;
    if (!isChecked) return AppColors.blueLight;
    return isCorrect
        ? AppColors.green.withValues(alpha: 0.08)
        : AppColors.red.withValues(alpha: 0.08);
  }

  Color get _shadowColor {
    if (!isSelected) return AppColors.greyLight;
    if (!isChecked) return const Color(0xFF1490CC);
    return isCorrect ? AppColors.greenShadow : AppColors.redShadow;
  }

  Color get _letterBg {
    if (!isSelected) return AppColors.greyBg;
    if (!isChecked) return AppColors.blue.withValues(alpha: 0.15);
    return isCorrect
        ? AppColors.green.withValues(alpha: 0.15)
        : AppColors.red.withValues(alpha: 0.15);
  }

  Color get _letterColor {
    if (!isSelected) return AppColors.labelGrey;
    if (!isChecked) return AppColors.blue;
    return isCorrect ? AppColors.green : AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    // After check, show correct always (even if unselected)
    final showCorrect = isChecked && isCorrect;
    final showWrong = isChecked && isSelected && !isCorrect;

    final effectiveBorder = showCorrect
        ? AppColors.green
        : showWrong
            ? AppColors.red
            : _borderColor;
    final effectiveBg = showCorrect
        ? AppColors.green.withValues(alpha: 0.08)
        : showWrong
            ? AppColors.red.withValues(alpha: 0.08)
            : _bgColor;

    return GestureDetector(
      onTap: isChecked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: effectiveBorder, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: (isSelected && !isChecked)
                  ? _shadowColor
                  : AppColors.greyLight,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Letter badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: showCorrect
                    ? AppColors.green.withValues(alpha: 0.15)
                    : showWrong
                        ? AppColors.red.withValues(alpha: 0.15)
                        : _letterBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: showCorrect
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.green, size: 20)
                  : showWrong
                      ? const Icon(Icons.close_rounded,
                          color: AppColors.red, size: 20)
                      : Center(
                          child: Text(
                            _letters[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: _letterColor,
                            ),
                          ),
                        ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: showCorrect
                      ? AppColors.green
                      : showWrong
                          ? AppColors.red
                          : AppColors.dark,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CHECK / CONTINUE button ───────────────────────────────────
class _CheckButton extends StatelessWidget {
  const _CheckButton({
    required this.isChecked,
    required this.hasSelection,
    required this.isCorrect,
    required this.isLastQuestion,
    required this.heartsLeft,
    required this.onCheck,
    required this.onNext,
  });

  final bool isChecked;
  final bool hasSelection;
  final bool isCorrect;
  final bool isLastQuestion;
  final int heartsLeft;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  // Only show this when feedback panel is NOT shown
  @override
  Widget build(BuildContext context) {
    if (isChecked) return const SizedBox.shrink();

    final active = hasSelection;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: AppColors.greyLight, width: 2)),
      ),
      child: GestureDetector(
        onTap: active ? onCheck : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 56,
          decoration: BoxDecoration(
            color: active ? AppColors.green : AppColors.greyLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: AppColors.greenShadow,
                      offset: Offset(0, 5),
                      blurRadius: 0,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            'CHECK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : AppColors.labelGrey,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Feedback panel ────────────────────────────────────────────
class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.isCorrect,
    required this.explanation,
    required this.isLastQuestion,
    required this.heartsLeft,
    required this.isReviewMode,
    required this.onNext,
  });

  final bool isCorrect;
  final String explanation;
  final bool isLastQuestion;
  final int heartsLeft;
  final bool isReviewMode;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    // In review mode always show green (correct answer shown)
    final effectiveCorrect = isReviewMode ? true : isCorrect;

    final bg = effectiveCorrect
        ? AppColors.green.withValues(alpha: 0.08)
        : AppColors.red.withValues(alpha: 0.08);
    final color = effectiveCorrect ? AppColors.green : AppColors.red;
    final shadowColor =
        effectiveCorrect ? AppColors.greenShadow : AppColors.redShadow;
    final icon = effectiveCorrect
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;
    final label = isReviewMode
        ? 'Correct Answer'
        : (effectiveCorrect ? 'Great job!' : 'Incorrect');
    final btnLabel = isLastQuestion
        ? (isReviewMode ? 'DONE' : 'SEE RESULTS')
        : 'CONTINUE';

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: color, width: 2.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),

          // Explanation
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 18),

          // CONTINUE button
          GestureDetector(
            onTap: onNext,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(0, 5),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                btnLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result screen ─────────────────────────────────────────────
class _QuizResult extends StatelessWidget {
  const _QuizResult({
    required this.quiz,
    required this.lessonTopic,
    required this.xpEarned,
    required this.correctCount,
    required this.heartsLeft,
    this.isReviewMode = false,
  });

  final QuizEntity quiz;
  final String lessonTopic;
  final int xpEarned;
  final int correctCount;
  final int heartsLeft;
  final bool isReviewMode;

  bool get _passed => correctCount >= (quiz.totalQuestions * 0.6).ceil();

  @override
  Widget build(BuildContext context) {
    // Review mode: just show a "Reviewed!" screen and go back
    if (isReviewMode) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 24),
                const Text(
                  'Review Complete!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'You reviewed all the answers.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () => Navigator.of(context)
                    ..pop()
                    ..pop(),
                  child: Container(
                    width: double.infinity,
                    height: 58,
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
                    child: const Text(
                      'BACK TO LESSON',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
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

    final passed = _passed;
    final accent = passed ? AppColors.green : AppColors.red;
    final accentShadow =
        passed ? AppColors.greenShadow : AppColors.redShadow;
    final emoji = passed ? '🎉' : '😢';
    final title = passed ? 'Lesson Complete!' : 'Keep Practicing!';
    final subtitle = passed
        ? 'You passed the quiz.\nGreat work!'
        : 'You need ${(quiz.totalQuestions * 0.6).ceil()} correct to pass.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Big emoji ──
              Text(emoji,
                  style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 24),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.dark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // ── Stat cards ──
              Row(
                children: [
                  _StatCard(
                    icon: Icons.check_circle_rounded,
                    value: '$correctCount / ${quiz.totalQuestions}',
                    label: 'Correct',
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.star_rounded,
                    value: '+$xpEarned',
                    label: 'XP Earned',
                    color: AppColors.orange,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.favorite_rounded,
                    value: '$heartsLeft',
                    label: 'Hearts Left',
                    color: AppColors.red,
                  ),
                ],
              ),

              const Spacer(),

              // ── CTA ──
              GestureDetector(
                onTap: () {
                  // Pop back to lesson map
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentShadow,
                        offset: const Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    passed ? 'CONTINUE' : 'TRY AGAIN',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              if (!passed) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.greyLight, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.greyLight,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'REVIEW LESSON',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.dark,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
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
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.labelGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.green),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_outlined,
                  color: AppColors.labelGrey, size: 64),
              const SizedBox(height: 20),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.greenShadow,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Text(
                    'GO BACK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
