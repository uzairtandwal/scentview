import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Thora slow aur smooth
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Text niche se upar slide ho kar aayega
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home-logic');
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Luxury Deep Black & Charcoal Gradient
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F0F), 
              Color(0xFF232323),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- GOLDEN LOGO AREA ---
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3), // Gold Shadow
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome, // Modern Star/Magic icon
                        size: 70,
                        color: Color(0xFFD4AF37), // Metallic Gold Color
                      ),
                    ),
                    const SizedBox(height: 40),
                    // --- BRAND NAME ---
                    const Text(
                      'SCENTVIEW',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w300, // Thin luxury font
                        color: Color(0xFFD4AF37), 
                        letterSpacing: 12, // More space between letters
                        fontFamily: 'Serif', 
                      ),
                    ),
                    const SizedBox(height: 15),
                    // --- SUBTITLE ---
                    Container(
                      height: 1,
                      width: 100,
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'THE ART OF FRAGRANCE',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}