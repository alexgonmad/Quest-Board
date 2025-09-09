import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Splash screen that shows the Elpa mascot inside a circle
/// animating from the bottom with a quick overshoot and settle.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  bool _isReadyToProceed = false;

  void _resetAnimation() {
    setState(() {
      _isReadyToProceed = false;
    });
    _controller
      ..reset()
      ..forward();
  }

  @override
  void initState() {
    super.initState();

    // Total duration 2s to keep the animation visible long enough.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Start below the screen, overshoot slightly above center, then settle.
    _slideAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 1.2),
          end: const Offset(0, -0.06), // a little above the final spot
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.06),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);

    // When animation finishes, enable the continue button.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() => _isReadyToProceed = true);
      }
    });

    // Kick off the animation on first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double diameter =
              (constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth
                  : constraints.maxHeight) *
              0.38; // responsive size

          return Stack(
            children: [
              // Center area target
              Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _ElpaCircle(diameter: diameter),
                ),
              ),
              if (kDebugMode)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    minimum: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isReadyToProceed)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const _FallbackHome(),
                                ),
                              );
                            },
                            child: const Text('Continuar'),
                          ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _resetAnimation,
                          child: const Text('Reiniciar animación'),
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

class _ElpaCircle extends StatelessWidget {
  const _ElpaCircle({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipOval(
        child: Image.asset('assets/images/elpa_happy.png', fit: BoxFit.cover),
      ),
    );
  }
}

/// Temporary fallback home that will be replaced by the real router/home.
class _FallbackHome extends StatelessWidget {
  const _FallbackHome();

  @override
  Widget build(BuildContext context) {
    return const _LegacyHomeProxy();
  }
}

/// This widget simply uses the existing MyHomePage as the landing page
/// without changing the rest of the template code.
class _LegacyHomeProxy extends StatelessWidget {
  const _LegacyHomeProxy();

  @override
  Widget build(BuildContext context) {
    // If the project later introduces GoRouter and a proper home screen,
    // update the navigation in the SplashScreen to route there instead.
    return const _TemplateHome();
  }
}

/// Extracted template home from the default main.dart to keep splash focused.
class _TemplateHome extends StatelessWidget {
  const _TemplateHome();

  @override
  Widget build(BuildContext context) {
    return const _TemplateScaffold();
  }
}

class _TemplateScaffold extends StatefulWidget {
  const _TemplateScaffold();

  @override
  State<_TemplateScaffold> createState() => _TemplateScaffoldState();
}

class _TemplateScaffoldState extends State<_TemplateScaffold> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quest Board')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pantalla principal de ejemplo'),
            const SizedBox(height: 8),
            Text('Counter: $_counter'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _counter++),
        child: const Icon(Icons.add),
      ),
    );
  }
}
