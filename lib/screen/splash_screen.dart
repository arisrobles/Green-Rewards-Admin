import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/admin-login');
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.emoji_nature, size: 60, color: Color(0xFF43A047)),
                ),
                const SizedBox(height: 32),
                Text(
                  'Trash Rewards Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Manage rewards, points, and more',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 