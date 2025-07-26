import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCredentialsLoginScreen extends StatefulWidget {
  const AdminCredentialsLoginScreen({super.key});

  @override
  State<AdminCredentialsLoginScreen> createState() => _AdminCredentialsLoginScreenState();
}

class _AdminCredentialsLoginScreenState extends State<AdminCredentialsLoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onLoginTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onLoginTapCancel() {
    _animationController.reverse();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check if the user is an admin
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();

      if (!adminDoc.exists) {
        // If not an admin, sign out and show error
        await FirebaseAuth.instance.signOut();
        setState(() {
          _errorText = 'This account is not authorized as an admin';
          _isLoading = false;
        });
        return;
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/admin-home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green[50],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.green[100],
                        child: Icon(Icons.lock_outline, size: 44, color: Colors.green[700]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Admin Login',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Password',
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(_errorText!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTapDown: _onLoginTapDown,
                    onTapUp: _onLoginTapUp,
                    onTapCancel: _onLoginTapCancel,
                    onTap: _isLoading ? null : _login,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green[600]!,
                              Colors.green[400]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.login, color: Colors.white),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Login',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/admin-signup'),
                        child: Text(
                          "Don't have an account? Sign up",
                          style: GoogleFonts.poppins(
                            color: Colors.green[700],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/admin-forgot'),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            color: Colors.blue,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}