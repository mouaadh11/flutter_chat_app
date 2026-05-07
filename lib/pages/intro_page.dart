import 'dart:math' as math;

import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage>
    with SingleTickerProviderStateMixin {
  static const List<_IntroSlide> _slides = [
    _IntroSlide(
      icon: Icons.chat_rounded,
      title: 'Chat in the moment',
      subtitle:
          'Start smooth conversations and keep every message easy to find.',
      bubbles: ['Hey!', 'Ready to chat?', 'Always.'],
    ),
    _IntroSlide(
      icon: Icons.person_search_rounded,
      title: 'Find your people',
      subtitle: 'Search by username and jump into a conversation in seconds.',
      bubbles: ['Maya', 'Alex', 'Sam'],
    ),
    _IntroSlide(
      icon: Icons.account_circle_rounded,
      title: 'Make it yours',
      subtitle:
          'Set up your profile, avatar, and name so friends recognize you.',
      bubbles: ['New avatar', 'Profile ready', 'Looks good'],
    ),
    _IntroSlide(
      icon: Icons.notifications_active_rounded,
      title: 'Never miss a reply',
      subtitle:
          'Get notified when a new message lands, then open the chat fast.',
      bubbles: ['Ping!', 'New reply', 'Open chat'],
    ),
  ];

  late final PageController _pageController;
  late final AnimationController _floatController;
  double _page = 0;

  int get _currentIndex => _page.round().clamp(0, _slides.length - 1);
  bool get _isLastPage => _currentIndex == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _pageController.addListener(_handlePageChanged);
  }

  void _handlePageChanged() {
    setState(() {
      _page = _pageController.page ?? _pageController.initialPage.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageChanged)
      ..dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_isLastPage) {
      widget.onFinished();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_rounded,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Chat App',
                    style: TextStyle(
                      color: colorScheme.inversePrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: widget.onFinished,
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final distance = (_page - index).clamp(-1.0, 1.0);

                  return _IntroSlideView(
                    slide: slide,
                    pageDistance: distance,
                    floatAnimation: _floatController,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => _ProgressDot(isActive: index == _currentIndex),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _goNext,
                    icon: Icon(
                      _isLastPage
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(_isLastPage ? 'Get Started' : 'Next'),
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

class _IntroSlideView extends StatelessWidget {
  const _IntroSlideView({
    required this.slide,
    required this.pageDistance,
    required this.floatAnimation,
  });

  final _IntroSlide slide;
  final double pageDistance;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textOffset = pageDistance * -34;
    final visualOffset = pageDistance * 52;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visualSize = math.min(
            constraints.maxWidth,
            math.max(190.0, constraints.maxHeight * 0.44),
          );

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(visualOffset, 0),
                child: Opacity(
                  opacity: (1 - pageDistance.abs() * 0.4).clamp(0.0, 1.0),
                  child: _AnimatedChatVisual(
                    slide: slide,
                    size: visualSize,
                    animation: floatAnimation,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Transform.translate(
                offset: Offset(textOffset, 0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.92, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Column(
                    children: [
                      Icon(slide.icon, color: colorScheme.primary, size: 34),
                      const SizedBox(height: 14),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.inversePrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedChatVisual extends StatelessWidget {
  const _AnimatedChatVisual({
    required this.slide,
    required this.size,
    required this.animation,
  });

  final _IntroSlide slide;
  final double size;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final bob = math.sin(animation.value * math.pi) * 12;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size * 0.76,
                height: size * 0.76,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colorScheme.outline),
                ),
              ),
              Transform.translate(
                offset: Offset(0, -bob),
                child: Container(
                  width: size * 0.43,
                  height: size * 0.43,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.22),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(
                    slide.icon,
                    color: colorScheme.onPrimary,
                    size: size * 0.18,
                  ),
                ),
              ),
              _FloatingBubble(
                text: slide.bubbles[0],
                alignment: Alignment.topLeft,
                offset: Offset(14, 26 + bob * 0.3),
                isPrimary: true,
              ),
              _FloatingBubble(
                text: slide.bubbles[1],
                alignment: Alignment.centerRight,
                offset: Offset(-6, -16 - bob * 0.4),
              ),
              _FloatingBubble(
                text: slide.bubbles[2],
                alignment: Alignment.bottomLeft,
                offset: Offset(26, -28 + bob * 0.5),
                isPrimary: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingBubble extends StatelessWidget {
  const _FloatingBubble({
    required this.text,
    required this.alignment,
    required this.offset,
    this.isPrimary = false,
  });

  final String text;
  final Alignment alignment;
  final Offset offset;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isPrimary ? colorScheme.primary : colorScheme.tertiary;
    final foreground = isPrimary
        ? colorScheme.onPrimary
        : colorScheme.inversePrimary;

    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 138),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary ? Colors.transparent : colorScheme.outline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressDot extends StatelessWidget {
  const _ProgressDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: isActive ? 26 : 8,
      height: 8,
      margin: const EdgeInsets.only(right: 7),
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.outline,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _IntroSlide {
  const _IntroSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bubbles,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bubbles;
}
