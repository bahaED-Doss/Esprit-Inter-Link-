import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key, required this.onNext}) : super(key: key);
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    const espritRed = Color(0xFF8B1C1C);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Center(
              child: Image.asset(
                'assets/icons/welcome page icon.png',
                width: 220,
                height: 220,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Find Your Internship Here!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: espritRed,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Explore all the most exciting internships based on your interest and study major.',
              style: TextStyle(
                fontSize: 16,
                color: espritRed,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 24, bottom: 24),
                child: FloatingActionButton(
                  backgroundColor: espritRed,
                  onPressed: onNext,
                  child: Image.asset(
                    'assets/icons/next page.png',
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

