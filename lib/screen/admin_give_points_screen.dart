import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminGivePointsScreen extends StatefulWidget {
  const AdminGivePointsScreen({super.key});

  @override
  State<AdminGivePointsScreen> createState() => _AdminGivePointsScreenState();
}

class _AdminGivePointsScreenState extends State<AdminGivePointsScreen> {
  final List<Map<String, dynamic>> _accounts = [
    {'name': 'Melvin', 'id': 'user_melvin'},
    {'name': 'Kimberly', 'id': 'user_kimberly'},
    {'name': 'Daren', 'id': 'user_daren'},
    {'name': 'John Doe', 'id': 'user_john'},
    {'name': 'Jane Smith', 'id': 'user_jane'},
  ];

  void _showGivePointsDialog(BuildContext context, String accountName) {
    final TextEditingController pointsController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Give Points',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Points to Give',
                  labelStyle: GoogleFonts.poppins(),
                  hintText: 'e.g., 100',
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
                    // Handle giving points logic here
                    print('Giving 24{pointsController.text} points to $accountName');
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
                    'Give Points',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
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
          'Give Points',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 24),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                ),
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
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
                    Text(
                      'List of Accounts',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 15),
                    ..._accounts.map((account) {
                      return _AnimatedAccountItem(name: account['name'], onTap: () => _showGivePointsDialog(context, account['name']));
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedAccountItem extends StatefulWidget {
  final String name;
  final VoidCallback onTap;
  const _AnimatedAccountItem({required this.name, required this.onTap});

  @override
  State<_AnimatedAccountItem> createState() => _AnimatedAccountItemState();
}

class _AnimatedAccountItemState extends State<_AnimatedAccountItem> with SingleTickerProviderStateMixin {
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
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.green, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  widget.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}