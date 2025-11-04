import 'package:flutter/material.dart';

/// Écran de bienvenue pour la gestion des offres de stage (HR)
class HRInternshipSplashScreen extends StatelessWidget {
  final VoidCallback onNext;

  const HRInternshipSplashScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo ESPRIT en haut
              Align(
                alignment: Alignment.topRight,
                child: Image.asset(
                  'assets/icons/logoE.png',
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFF8B1C1C),
                      child: const Icon(Icons.business, color: Colors.white, size: 30),
                    );
                  },
                ),
              ),
              
              const Spacer(),
              
              // Illustration centrale
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1C1C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grande forme d'arrière-plan
                    Positioned(
                      left: 50,
                      top: 80,
                      child: Container(
                        width: 150,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B1C1C),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    
                    // Icône de briefcase/business
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.work_outline,
                        size: 70,
                        color: Color(0xFF8B1C1C),
                      ),
                    ),
                    
                    // Icône de vérification
                    Positioned(
                      right: 50,
                      bottom: 100,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Color(0xFF66BB6A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Titre principal
              const Text(
                'Manage Your',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Internship\n',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8B1C1C),
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Offers!',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Sous-titre
              const Text(
                'Create and manage internship opportunities.\nReview applications and build your team.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Bouton continuer
              GestureDetector(
                onTap: onNext,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B1C1C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x408B1C1C),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
