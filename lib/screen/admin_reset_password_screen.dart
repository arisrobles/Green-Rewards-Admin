import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:random_string/random_string.dart';

class AdminResetPasswordScreen extends StatefulWidget {
  final String email;

  const AdminResetPasswordScreen({
    super.key,
    required this.email, required String verificationCode,
  });

  @override
  State<AdminResetPasswordScreen> createState() => _AdminResetPasswordScreenState();
}

class _AdminResetPasswordScreenState extends State<AdminResetPasswordScreen> with SingleTickerProviderStateMixin {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;
  bool _isButtonEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Add listeners to update button state
    for (var controller in _codeControllers) {
      controller.addListener(_updateButtonState);
    }
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      _animationController.forward();
    });
  }

  void _updateButtonState() {
    final codeIsValid = _codeControllers.every((controller) => controller.text.length == 1);
    final passwordsMatch = _passwordController.text == _confirmPasswordController.text;
    final passwordIsValid = _passwordController.text.length >= 6;

    setState(() {
      _isButtonEnabled = codeIsValid && passwordsMatch && passwordIsValid;
    });
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (index == 5 && value.isNotEmpty) {
      FocusScope.of(context).nextFocus();
    }
  }

  Future<void> _verifyAndResetPassword() async {
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      final enteredCode = _codeControllers.map((c) => c.text).join();

      // Fetch reset code from Firestore
      final doc = await FirebaseFirestore.instance.collection('password_resets').doc(widget.email).get();
      if (!doc.exists) {
        setState(() {
          _isVerifying = false;
          _errorText = 'Reset code expired or invalid';
        });
        _shakeInputFields();
        return;
      }

      final data = doc.data()!;
      final storedCode = data['resetCode'] as String;
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (createdAt == null || DateTime.now().difference(createdAt).inMinutes > 10) {
        setState(() {
          _isVerifying = false;
          _errorText = 'Reset code expired';
        });
        _shakeInputFields();
        return;
      }

      if (enteredCode != storedCode) {
        setState(() {
          _isVerifying = false;
          _errorText = 'Invalid reset code';
        });
        _shakeInputFields();
        return;
      }

      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _isVerifying = false;
          _errorText = 'Passwords do not match';
        });
        return;
      }

      if (_passwordController.text.length < 6) {
        setState(() {
          _isVerifying = false;
          _errorText = 'Password must be at least 6 characters';
        });
        return;
      }

      // Update password
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email == widget.email) {
        await user.updatePassword(_passwordController.text.trim());
      } else {
        // If no user is signed in, sign in first
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: widget.email,
          password: _passwordController.text.trim(), // Temporary workaround; ideally, use a different auth method
        );
        await FirebaseAuth.instance.currentUser!.updatePassword(_passwordController.text.trim());
      }

      // Delete reset code from Firestore
      await FirebaseFirestore.instance.collection('password_resets').doc(widget.email).delete();

      if (mounted) {
        _showSuccessAnimation();
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pushReplacementNamed(context, '/admin-login');
      }
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _errorText = 'Error: ${e.toString()}';
      });
    }
  }

  void _shakeInputFields() {
    final shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 10),
      duration: const Duration(milliseconds: 100),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * (value % 2 == 0 ? 1 : -1), 0),
          child: child,
        );
      },
      child: Container(),
    );

    shakeController.forward().then((_) => shakeController.dispose());
  }

  void _showSuccessAnimation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    try {
      final newResetCode = randomNumeric(6);
      await _sendResetEmail(widget.email, newResetCode);

      // Update reset code in Firestore
      await FirebaseFirestore.instance.collection('password_resets').doc(widget.email).set({
        'resetCode': newResetCode,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New reset code sent'),
            backgroundColor: Colors.green,
          ),
        );

        for (var controller in _codeControllers) controller.clear();
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _sendResetEmail(String email, String code) async {
    final smtpServer = gmail('arisrobles07@gmail.com', 'mgti dcwv vuom npcr');

    final message = Message()
      ..from = const Address('arisrobles07@gmail.com', 'Green Rewards Admin')
      ..recipients.add(email)
      ..subject = 'Password Reset Code'
      ..html = '''
        <h2>Password Reset Request</h2>
        <p>Your password reset code is: <strong>$code</strong></p>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Reset Password',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
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
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'Enter the 6-digit code sent to ${widget.email}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.green[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                        (index) => SizedBox(
                          width: 50,
                          child: TextField(
                            controller: _codeControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: (value) => _onCodeChanged(value, index),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'New Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        errorText: _errorText,
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isVerifying || !_isButtonEnabled ? null : _verifyAndResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isVerifying
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
                  ),
                ),
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TextButton.icon(
                      onPressed: _isResending ? null : _resendCode,
                      icon: _isResending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.green,
                              ),
                            )
                          : const Icon(Icons.refresh, size: 16, color: Colors.green),
                      label: Text(
                        _isResending ? 'Sending...' : 'Resend Code',
                        style: GoogleFonts.poppins(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}