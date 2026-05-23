import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:learn_craft/core/constants/app_firebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_craft/core/constants/app_paths.dart';
import 'package:learn_craft/core/utils/app_toast.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';
import 'duo_widgets.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  int _step = 0; // 0 = avatar, 1 = username, 2 = email+password

  // Step data
  String? _selectedAvatarUrl;
  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  // Username availability
  Timer? _debounce;
  bool? _usernameAvailable;   // null = not checked, true = available, false = taken
  bool _usernameChecking = false;

  void _onUsernameChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();

    if (trimmed.length < 3) {
      setState(() {
        _usernameAvailable = null;
        _usernameChecking = false;
      });
      return;
    }

    setState(() => _usernameChecking = true);
    _debounce = Timer(const Duration(milliseconds: 600), () {
      context.read<AuthBloc>().add(CheckUsernameRequested(trimmed));
    });
  }

  // ── Navigation ──────────────────────────────────────────────
  void _onNext() {
    if (_step == 0) {
      if (_selectedAvatarUrl == null) {
        AppToast.error(context, 'Please pick an avatar first');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      final username = _usernameCtrl.text.trim();
      if (username.isEmpty) {
        AppToast.error(context, 'Please enter a username');
        return;
      }
      if (username.length < 3) {
        AppToast.error(context, 'Username must be at least 3 characters');
        return;
      }
      if (_usernameAvailable == false) {
        AppToast.error(context, 'Username is already taken');
        return;
      }
      if (_usernameChecking) {
        AppToast.error(context, 'Checking username, please wait...');
        return;
      }
      setState(() => _step = 2);
    } else {
      _submit();
    }
  }

  void _onBack() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  void _submit() {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty) {
      AppToast.error(context, 'Please enter your email');
      return;
    }
    if (!email.contains('@')) {
      AppToast.error(context, 'Please enter a valid email');
      return;
    }
    if (password.isEmpty) {
      AppToast.error(context, 'Please enter a password');
      return;
    }
    if (password.length < 8) {
      AppToast.error(context, 'Password must be at least 8 characters');
      return;
    }

    context.read<AuthBloc>().add(
      CreateUserRequested(
        name:      _usernameCtrl.text.trim(),
        email:     email,
        password:  password,
        avatarUrl: _selectedAvatarUrl ?? '',
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ── Step titles ─────────────────────────────────────────────
  static const _titles    = ['Pick your avatar', 'Choose a username', 'Set up login'];
  static const _subtitles = [
    'This is how others will see you',
    'Make it fun and memorable',
    'Keep your account safe',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) AppToast.error(context, state.message);
        if (state is UsernameAvailable) {
          setState(() { _usernameAvailable = true; _usernameChecking = false; });
        }
        if (state is UsernameUnavailable) {
          setState(() { _usernameAvailable = false; _usernameChecking = false; });
        }
        if (state is UsernameChecking) {
          setState(() => _usernameChecking = true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    DuoBackButton(onTap: _onBack),
                    const SizedBox(width: 16),
                    Expanded(child: _StepRail(current: _step, total: 3)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // ── Title ────────────────────────────
                      Text(
                        _titles[_step],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A1A2E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _subtitles[_step],
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF777777),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Step content ─────────────────────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.08, 0),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_step),
                          child: [
                            _AvatarStep(
                              urls: AppFirebase.avatarUrls,
                              selected: _selectedAvatarUrl,
                              onSelect: (url) =>
                                  setState(() => _selectedAvatarUrl = url),
                            ),
                            _UsernameStep(
                              controller: _usernameCtrl,
                              onChanged: _onUsernameChanged,
                              isAvailable: _usernameAvailable,
                              isChecking: _usernameChecking,
                            ),
                            _EmailPasswordStep(
                              emailCtrl:    _emailCtrl,
                              passwordCtrl: _passwordCtrl,
                              obscure:      _obscure,
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ][_step],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Next / Create button ──────────────
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return DuoGreenButton(
                            label: _step == 2 ? 'CREATE ACCOUNT' : 'NEXT',
                            isLoading: state is AuthLoading,
                            onTap: state is AuthLoading ? null : _onNext,
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Already have an account ───────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF777777),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppPaths.login),
                            child: Text(
                              'LOG IN',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF58CC02),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
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

// ── Step rail progress bar ───────────────────────────────────
class _StepRail extends StatelessWidget {
  const _StepRail({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
            height: 6,
            decoration: BoxDecoration(
              color: done ? const Color(0xFF58CC02) : const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 0: Avatar grid ──────────────────────────────────────
class _AvatarStep extends StatelessWidget {
  const _AvatarStep({
    required this.urls,
    required this.selected,
    required this.onSelect,
  });

  final List<String> urls;
  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: Text(
            'No avatars available.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
          ),
        ),
      );
    }

    final hasSelection = selected != null;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: urls.length,
      itemBuilder: (_, i) {
        final url        = urls[i];
        final isSelected = url == selected;

        return _AvatarTile(
          url: url,
          isSelected: isSelected,
          dimmed: hasSelection && !isSelected,
          onTap: () => onSelect(url),
        );
      },
    );
  }
}

class _AvatarTile extends StatefulWidget {
  const _AvatarTile({
    required this.url,
    required this.isSelected,
    required this.dimmed,
    required this.onTap,
  });

  final String url;
  final bool isSelected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  State<_AvatarTile> createState() => _AvatarTileState();
}

class _AvatarTileState extends State<_AvatarTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.08), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _AvatarTile old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final scale = widget.isSelected ? _bounce.value : 1.0;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: widget.dimmed ? 0.45 : 1.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: widget.dimmed ? 0.85 : scale,
              child: child,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF58CC02)
                  : const Color(0xFF3A3A3A),
              width: widget.isSelected ? 3.5 : 2,
            ),
            boxShadow: widget.isSelected
                ? [
                    const BoxShadow(
                      color: Color(0xFF46A302),
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2A2A2A),
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (ctx, url) => Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(Icons.person_rounded,
                          color: Color(0xFF666666)),
                    ),
                    errorWidget: (ctx, url, err) => Container(
                      color: const Color(0xFF2A2A2A),
                      child: const Icon(Icons.broken_image_rounded,
                          color: Color(0xFF666666)),
                    ),
                  ),
                ),
                // ── Animated checkmark badge ──
                AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  scale: widget.isSelected ? 1.0 : 0.0,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF58CC02),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF46A302),
                            offset: Offset(0, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step 1: Username ─────────────────────────────────────────
class _UsernameStep extends StatelessWidget {
  const _UsernameStep({
    required this.controller,
    required this.onChanged,
    required this.isAvailable,
    required this.isChecking,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool? isAvailable;
  final bool isChecking;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoLabel('USERNAME'),
        const SizedBox(height: 6),
        DuoTextField(
          controller: controller,
          hint: 'e.g. QuizMaster99',
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),

        // ── Availability status chip ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: isChecking
              ? _buildChip(
                  key: const ValueKey('checking'),
                  icon: _buildSpinner(),
                  text: 'Checking...',
                  bgColor: const Color(0xFFE8F4FD),
                  fgColor: const Color(0xFF1CB0F6),
                  borderColor: const Color(0xFFB3DEFA),
                )
              : isAvailable == true
                  ? _buildChip(
                      key: const ValueKey('available'),
                      icon: const Icon(Icons.check_circle_rounded, size: 16,
                          color: Color(0xFF58CC02)),
                      text: 'Available!',
                      bgColor: const Color(0xFFEAFBE0),
                      fgColor: const Color(0xFF58CC02),
                      borderColor: const Color(0xFFC4EDA8),
                    )
                  : isAvailable == false
                      ? _buildChip(
                          key: const ValueKey('taken'),
                          icon: const Icon(Icons.cancel_rounded, size: 16,
                              color: Color(0xFFFF4B4B)),
                          text: 'Already taken',
                          bgColor: const Color(0xFFFFF0F0),
                          fgColor: const Color(0xFFFF4B4B),
                          borderColor: const Color(0xFFFFCCCC),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  static Widget _buildSpinner() {
    return const SizedBox(
      width: 14,
      height: 14,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Color(0xFF1CB0F6),
      ),
    );
  }

  static Widget _buildChip({
    required Key key,
    required Widget icon,
    required String text,
    required Color bgColor,
    required Color fgColor,
    required Color borderColor,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Email + Password ─────────────────────────────────
class _EmailPasswordStep extends StatelessWidget {
  const _EmailPasswordStep({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggleObscure,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DuoLabel('EMAIL ADDRESS'),
        const SizedBox(height: 6),
        DuoTextField(
          controller: emailCtrl,
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const DuoLabel('PASSWORD'),
        const SizedBox(height: 6),
        DuoTextField(
          controller: passwordCtrl,
          hint: '--------',
          obscureText: obscure,
          suffixIcon: GestureDetector(
            onTap: onToggleObscure,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFFAAAAAA),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
