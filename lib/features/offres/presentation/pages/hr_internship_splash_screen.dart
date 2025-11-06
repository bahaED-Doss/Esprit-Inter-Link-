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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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

                        // Illustration centrale: taille relative
                        Builder(builder: (context) {
                          final maxSide = constraints.maxWidth < constraints.maxHeight
                              ? constraints.maxWidth
                              : constraints.maxHeight;
                          final illustrationSize = (maxSide * 0.55).clamp(200.0, 360.0);

                          return Container(
                            width: illustrationSize,
                            height: illustrationSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B1C1C).withAlpha((0.1 * 255).round()),
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Grande forme d'arrière-plan
                                Positioned(
                                  left: illustrationSize * 0.15,
                                  top: illustrationSize * 0.2,
                                  child: Container(
                                    width: illustrationSize * 0.45,
                                    height: illustrationSize * 0.6,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B1C1C),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),

                                // Icône de briefcase/business
                                Container(
                                  width: illustrationSize * 0.48,
                                  height: illustrationSize * 0.48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha((0.1 * 255).round()),
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
                                  right: illustrationSize * 0.12,
                                  bottom: illustrationSize * 0.25,
                                  child: Container(
                                    width: illustrationSize * 0.2,
                                    height: illustrationSize * 0.2,
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
                          );
                        }),

                        const SizedBox(height: 36),

                        // Titre principal
                        const Text(
                          'Manage Your',
                          style: TextStyle(
                            fontSize: 36,
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
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8B1C1C),
                                  height: 1.2,
                                ),
                              ),
                              TextSpan(
                                text: 'Offers!',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 18),

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
              ),
            );
          },
        ),
      ),
    );
  }
}
