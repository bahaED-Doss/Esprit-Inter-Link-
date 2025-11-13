import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationAnim;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rotationAnim = Tween<double>(begin: 0, end: 2 * math.pi).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _bounceAnim = Tween<double>(begin: 0, end: 18).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
    // Ajout de la navigation automatique vers SplashScreen après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.goNamed('splash');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const espritRed = Color(0xFF8B1C1C);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_bounceAnim.value.abs()),
                  child: Transform.rotate(
                    angle: _rotationAnim.value,
                    child: Image.asset(
                      'assets/icons/logoE.png',
                      width: 80,
                      height: 80,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Esprit_Interlink',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: espritRed,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Connecting Student with Opportunities',
              style: TextStyle(
                fontSize: 14,
                color: espritRed,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
