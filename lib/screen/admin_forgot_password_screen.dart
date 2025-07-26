import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminForgotPasswordScreen extends StatefulWidget {
  const AdminForgotPasswordScreen({super.key});

  @override
  State<AdminForgotPasswordScreen> createState() => _AdminForgotPasswordScreenState();
}

class _AdminForgotPasswordScreenState extends State<AdminForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  void _resetPassword() async {
    setState(() { _isLoading = true; _message = null; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _message = 'If this email exists, a reset link has been sent.';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
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
          'Forgot Password',
          style: GoogleFonts.poppins(
            color: Colors.green[800],
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
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
                            color: Colors.green.withOpacity(0.10),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.green[100],
                        child: Icon(Icons.lock_reset, size: 36, color: Colors.green[700]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reset your password',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined),
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _resetPassword,
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
                              'Reset Password',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 18),
                    Text(_message!, style: GoogleFonts.poppins(color: Colors.green[700], fontSize: 15)),
                  ],
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/admin-login'),
                    child: Text(
                      'Back to Login',
                      style: GoogleFonts.poppins(
                        color: Colors.green[700],
                        fontSize: 15,
                        // No underline
                      ),
                    ),
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