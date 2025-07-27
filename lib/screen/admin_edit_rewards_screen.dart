import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'dart:typed_data';

class AdminEditRewardsScreen extends StatefulWidget {
  const AdminEditRewardsScreen({super.key});

  @override
  State<AdminEditRewardsScreen> createState() => _AdminEditRewardsScreenState();
}

class _AdminEditRewardsScreenState extends State<AdminEditRewardsScreen> {
  final CollectionReference _rewardsCollection =
      FirebaseFirestore.instance.collection('rewards');

  void _showAddProductDialog() {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController pointsCostController = TextEditingController();
    final TextEditingController stockAmountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    Uint8List? selectedImage;
    String? base64Image;

    Future<void> _pickAndCompressImage() async {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);

        if (image == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No image selected')),
          );
          return;
        }

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
          // On web, use the original bytes (no compression available)
          compressedImage = imageBytes;
        }

        // Convert to base64
        final String base64String = base64Encode(compressedImage);
        selectedImage = compressedImage;
        base64Image = base64String;
            } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.add_box, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Add New Product',
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
                      onTap: () async {
                        await _pickAndCompressImage();
                        setDialogState(() {}); // Update dialog UI
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.add_a_photo, size: 40, color: Colors.green),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: pointsCostController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Pts cost',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: stockAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock Amount',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (productNameController.text.isEmpty ||
                              pointsCostController.text.isEmpty ||
                              stockAmountController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill all required fields')),
                            );
                            return;
                          }
                          try {
                            await _rewardsCollection.add({
                              'id': DateTime.now().millisecondsSinceEpoch.toString(),
                              'name': productNameController.text,
                              'points': int.tryParse(pointsCostController.text) ?? 0,
                              'stock': int.tryParse(stockAmountController.text) ?? 0,
                              'description': descriptionController.text,
                              'image': base64Image != null
                                  ? 'data:image/jpeg;base64,$base64Image'
                                  : 'https://via.placeholder.com/100/CCCCCC/000000?text=${Uri.encodeComponent(productNameController.text)}',
                            });
                            setDialogState(() {
                              selectedImage = null;
                              base64Image = null;
                            });
                            Navigator.of(context).pop();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding reward: $e')),
                            );
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
                        child: Text(
                          'Add Product',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Rewards',
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
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Drag product to delete',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[900],
                      ),
                    ),
                    Icon(Icons.delete_outline, color: Colors.red[400], size: 28),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: _rewardsCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error loading rewards');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final rewards = snapshot.data!.docs;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: rewards.length,
                      itemBuilder: (context, index) {
                        final item = rewards[index].data() as Map<String, dynamic>;
                        return _AnimatedRewardEditCard(
                          item: item,
                          onDelete: () => _rewardsCollection.doc(rewards[index].id).delete(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: FloatingActionButton(
                    onPressed: _showAddProductDialog,
                    backgroundColor: Colors.green[400],
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
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

class _AnimatedRewardEditCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  const _AnimatedRewardEditCard({required this.item, required this.onDelete});

  @override
  State<_AnimatedRewardEditCard> createState() => _AnimatedRewardEditCardState();
}

class _AnimatedRewardEditCardState extends State<_AnimatedRewardEditCard>
    with SingleTickerProviderStateMixin {
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
    final item = widget.item;
    final imageUrl = item['image']?.startsWith('data:image') == true
        ? item['image']
        : item['image'] ?? 'https://via.placeholder.com/100';
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onLongPress: widget.onDelete,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(imageUrl.split(',')[1]),
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            height: 80,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '${item['points']} pts',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Remaining stock: ${item['stock']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey,
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