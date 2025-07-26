import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminEditRewardsScreen extends StatefulWidget {
  const AdminEditRewardsScreen({super.key});

  @override
  State<AdminEditRewardsScreen> createState() => _AdminEditRewardsScreenState();
}

class _AdminEditRewardsScreenState extends State<AdminEditRewardsScreen> {
  final List<Map<String, dynamic>> _rewardItems = [
    {
      'id': 'pencil',
      'name': 'Pencil (1pc)',
      'points': 500,
      'stock': 100,
      'image': 'https://via.placeholder.com/100/FFD700/000000?query=pencil',
    },
    {
      'id': 'rice',
      'name': 'Rice (1kg)',
      'points': 1500,
      'stock': 50,
      'image': 'https://via.placeholder.com/100/8B4513/FFFFFF?query=rice',
    },
    {
      'id': 'notebook',
      'name': 'Notebook (1pc)',
      'points': 700,
      'stock': 200,
      'image': 'https://via.placeholder.com/100/ADD8E6/000000?query=notebook',
    },
  ];

  void _showAddProductDialog() {
    final TextEditingController productNameController = TextEditingController();
    final TextEditingController pointsCostController = TextEditingController();
    final TextEditingController stockAmountController = TextEditingController();

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_a_photo, size: 40, color: Colors.green),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _rewardItems.add({
                          'id': DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': productNameController.text,
                          'points': int.tryParse(pointsCostController.text) ?? 0,
                          'stock': int.tryParse(stockAmountController.text) ?? 0,
                          'image': 'https://via.placeholder.com/100/CCCCCC/000000?text=New+Item',
                        });
                      });
                      Navigator.of(context).pop();
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
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
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
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _rewardItems.length,
                  itemBuilder: (context, index) {
                    final item = _rewardItems[index];
                    return _AnimatedRewardEditCard(item: item);
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
  const _AnimatedRewardEditCard({required this.item});

  @override
  State<_AnimatedRewardEditCard> createState() => _AnimatedRewardEditCardState();
}

class _AnimatedRewardEditCardState extends State<_AnimatedRewardEditCard> with SingleTickerProviderStateMixin {
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
    return GestureDetector(
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
                    child: Image.network(
                      item['image'],
                      height: 80,
                      fit: BoxFit.contain,
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