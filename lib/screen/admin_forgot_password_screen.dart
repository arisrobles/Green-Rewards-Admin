import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:random_string/random_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminForgotPasswordScreen extends StatefulWidget {
  const AdminForgotPasswordScreen({super.key});

  @override
  State<AdminForgotPasswordScreen> createState() => _AdminForgotPasswordScreenState();
}

class _AdminForgotPasswordScreenState extends State<AdminForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  Future<void> _sendResetEmail(String email, String resetCode) async {
    final smtpServer = gmail('arisrobles07@gmail.com', 'mgti dcwv vuom npcr');

    final message = Message()
      ..from = const Address('arisrobles07@gmail.com', 'Green Rewards Admin')
      ..recipients.add(email)
      ..subject = 'Password Reset Code'
      ..html = '''
        <h2>Password Reset Request</h2>
        <p>Your password reset code is: <strong>$resetCode</strong></p>
        <p>Please enter this code in the Green Rewards Admin App to reset your password.</p>
        <p>This code is valid for 10 minutes. If you did not request a password reset, please ignore this email.</p>
        <p>Best regards,<br>Green Rewards Team</p>
      ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Reset email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending reset email: $e');
      throw Exception('Failed to send reset email: $e');
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      String email = _emailController.text.trim();
      if (email.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorText = 'Please enter an email address';
        });
        return;
      }
      if (!_emailRegex.hasMatch(email)) {
        setState(() {
          _isLoading = false;
          _errorText = 'Please enter a valid email address';
        });
        return;
      }

      // Generate a 6-digit reset code
      final resetCode = randomNumeric(6);

      // Store reset code in Firestore with timestamp
      await FirebaseFirestore.instance.collection('password_resets').doc(email).set({
        'resetCode': resetCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send reset email
      await _sendResetEmail(email, resetCode);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate to reset password screen with email only
        Navigator.pushNamed(
          context,
          '/admin-reset-password',
          arguments: {'email': email},
        );
      }
    } catch (e) {
      print('Error in _resetPassword: $e');
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to send reset email. Please try again.';
      });
    }
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
                      errorText: _errorText,
                    ),
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.emailAddress,
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
                              'Send Reset Code',
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
                      'Back to Login',
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
    );
  }
}