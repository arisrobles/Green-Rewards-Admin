import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String? _adminName;
  String? _adminEmail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _adminEmail = user.email;
        _adminName = user.displayName ?? 'Admin';
        _isLoading = false;
      });

      // Fallback to Firestore if displayName is not set
      if (user.displayName == null || user.displayName!.isEmpty) {
        final adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(user.uid)
            .get();
        if (adminDoc.exists) {
          setState(() {
            _adminName = adminDoc.data()?['name'] ?? 'Admin';
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _adminName = 'Admin';
        _adminEmail = 'admin@email.com';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/admin-login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Gradient Header
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: Text(
                              'Profile',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Profile Card
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.green[200]!, width: 5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.10),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.green[100],
                                child: const Icon(Icons.person, size: 54, color: Color(0xFF43A047)),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _adminName ?? 'Admin',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[900],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _adminEmail ?? 'admin@email.com',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Divider(
                              color: Colors.green[100],
                              thickness: 1.2,
                              height: 32,
                              indent: 16,
                              endIndent: 16,
                            ),
                            _AnimatedProfileButton(
                              icon: Icons.edit,
                              label: 'Edit Profile',
                              color: Colors.blue,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit Profile tapped!')),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _AnimatedProfileButton(
                              icon: Icons.logout,
                              label: 'Logout',
                              color: Colors.red,
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
    );
  }
}

class _AnimatedProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AnimatedProfileButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}