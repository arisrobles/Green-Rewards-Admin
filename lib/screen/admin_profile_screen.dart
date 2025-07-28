import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'dart:typed_data';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _nameController = TextEditingController();
  String? _adminEmail;
  bool _isLoading = true;
  String? _errorMessage;
  User? _user;
  String? _profileImageBase64; // Store Base64 string for profile image
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchAdminData();
  }

  Future<void> _fetchAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      _user = FirebaseAuth.instance.currentUser;
      if (_user == null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin-login', (route) => false);
        }
        return;
      }

      // Fetch admin data from Firestore
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(_user!.uid)
          .get();

      if (mounted) {
        setState(() {
          _adminEmail = _user!.email ?? 'admin@email.com';
          _nameController.text = _user!.displayName ?? adminDoc.data()?['name'] ?? 'Admin';
          _profileImageBase64 = adminDoc.exists ? adminDoc.data()!['profileImage'] : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndCompressImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
      );
      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
        }
        return;
      }

      // Read image bytes
      Uint8List imageBytes = await image.readAsBytes();

      // Compress the image (mobile only)
      Uint8List? compressedImage;
      if (!kIsWeb) {
        compressedImage = await FlutterImageCompress.compressWithList(
          imageBytes,
          minHeight: 200,
          minWidth: 200,
          quality: 70,
          format: CompressFormat.jpeg,
        );
      } else {
        compressedImage = imageBytes;
      }

      // Convert to Base64
      final String base64String = base64Encode(compressedImage);

      if (mounted) {
        setState(() {
          _profileImageBase64 = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick image: $e';
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      if (_user != null) {
        // Update displayName in Firebase Auth
        await _user!.updateDisplayName(_nameController.text.trim());

        // Save profile data to Firestore
        final adminData = {
          'name': _nameController.text.trim(),
          'email': _user!.email,
          'updatedAt': FieldValue.serverTimestamp(),
          'profileImage': _profileImageBase64 ?? FieldValue.delete(),
        };

        await FirebaseFirestore.instance
            .collection('admins')
            .doc(_user!.uid)
            .set(adminData, SetOptions(merge: true));

        await _user!.reload();
        if (mounted) {
          setState(() {
            _user = FirebaseAuth.instance.currentUser;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully.'),
              backgroundColor: Color(0xFF43A047),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/admin-login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditProfileDialog() {
    // Store dialog context separately to check if dialog is still mounted
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: _isLoading
                          ? null
                          : () async {
                              await _pickAndCompressImage();
                              setDialogState(() {});
                            },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                        ),
                        child: _profileImageBase64 != null && _profileImageBase64!.startsWith('data:image')
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(_profileImageBase64!.split(',')[1]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.black54,
                                  ),
                                ),
                              )
                            : const Icon(Icons.add_a_photo, size: 40, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: TextEditingController(text: _adminEmail),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      enabled: false,
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                await _saveProfile();
                                if (mounted && _errorMessage == null && dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : Text(
                                'Save Profile',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
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
                            InkWell(
                              onTap: _isLoading ? null : _showEditProfileDialog,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300, width: 2),
                                ),
                                child: _profileImageBase64 != null && _profileImageBase64!.startsWith('data:image')
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(_profileImageBase64!.split(',')[1]),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.person, size: 60, color: Color(0xFF43A047)),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _isLoading ? null : _showEditProfileDialog,
                              child: const Text(
                                'Upload Image',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2196F3),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _nameController.text.isEmpty ? 'Admin' : _nameController.text,
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
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            _AnimatedProfileButton(
                              icon: Icons.edit,
                              label: 'Edit Profile',
                              color: Colors.blue,
                              onTap: _showEditProfileDialog,
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class _AnimatedProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AnimatedProfileButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

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