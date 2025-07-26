import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSignUpScreen extends StatefulWidget {
  const AdminSignUpScreen({super.key});

  @override
  State<AdminSignUpScreen> createState() => _AdminSignUpScreenState();
}

class _AdminSignUpScreenState extends State<AdminSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;

  void _signUp() async {
    setState(() {
      _errorText = null;
      _isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorText = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }

      try {
        // Create user with Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Update display name
        await userCredential.user?.updateDisplayName(_nameController.text.trim());

        // Store admin metadata in Firestore
        await FirebaseFirestore.instance
            .collection('admins')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin-login');
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
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Sign Up',
          style: GoogleFonts.poppins(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green[50],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.green[100],
                          child: Icon(Icons.person_add_alt_1, size: 40, color: Colors.green[700]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Admin Account',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        labelText: 'Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined),
                        labelText: 'Email',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) => v == null || v.isEmpty || !v.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: GoogleFonts.poppins(),
                      validator: (v) => v == null || v.isEmpty ? 'Confirm your password' : null,
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(_errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/admin-login'),
                      child: Text(
                        'Already have an account? Log in',
                        style: GoogleFonts.poppins(
                          color: Colors.green[700],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}