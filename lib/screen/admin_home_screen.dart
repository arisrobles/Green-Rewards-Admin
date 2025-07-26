import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<String> _getAdminName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        return user.displayName!;
      } else {
        // Fallback to Firestore if displayName is not set
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();
        return adminDoc.exists ? adminDoc.data()!['name'] ?? 'Admin' : 'Admin';
      }
    }
    return 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          // Custom Header
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 28, top: 48, right: 90, bottom: 24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FutureBuilder<String>(
                      future: _getAdminName(),
                      builder: (context, snapshot) {
                        final name = snapshot.data ?? 'Admin';
                        return Text(
                          'Welcome, $name!',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 28,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/admin-profile'),
                  child: Material(
                    elevation: 8,
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_outline, color: Colors.green[600], size: 36),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _buildAnimatedFeatureButton(
                    context,
                    icon: Icons.card_giftcard,
                    label: 'Give Points',
                    color: Colors.green,
                    routeName: '/admin-give-points',
                  ),
                  const SizedBox(height: 18),
                  _buildAnimatedFeatureButton(
                    context,
                    icon: Icons.edit,
                    label: 'Edit Rewards',
                    color: Colors.blue,
                    routeName: '/admin-edit-rewards',
                  ),
                  const SizedBox(height: 18),
                  _buildAnimatedFeatureButton(
                    context,
                    icon: Icons.forum_outlined,
                    label: 'Report Forum',
                    color: Colors.orange,
                    routeName: '/report-forum',
                  ),
                  const SizedBox(height: 18),
                  _buildAnimatedFeatureButton(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Transactions',
                    color: Colors.purple,
                    routeName: '/admin-transactions',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFeatureButton(BuildContext context, {required IconData icon, required String label, required Color color, required String routeName}) {
    return _AnimatedButton(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _AnimatedButton({required this.child, required this.onTap});

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}