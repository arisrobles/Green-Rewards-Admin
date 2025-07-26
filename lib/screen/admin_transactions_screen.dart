import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  final List<Map<String, dynamic>> _adminTransactionsData = [
    {'date': '5/24/2025', 'time': '12:52 AM', 'type': 'Points Given', 'details': {'accountName': 'Melvin', 'address': '123 Main St', 'pointsGiven': 100, 'productBought': 'N/A'}},
    {'date': '5/23/2025', 'time': '10:30 AM', 'type': 'Product Availed', 'details': {'accountName': 'Kimberly', 'address': '456 Oak Ave', 'pointsGiven': 0, 'productBought': 'Pencil (1pc)'}},
    {'date': '5/22/2025', 'time': '03:15 PM', 'type': 'Points Given', 'details': {'accountName': 'Daren', 'address': '789 Pine Ln', 'pointsGiven': 50, 'productBought': 'N/A'}},
    {'date': '5/21/2025', 'time': '09:00 AM', 'type': 'Product Availed', 'details': {'accountName': 'John Doe', 'address': '101 Elm Rd', 'pointsGiven': 0, 'productBought': 'Rice (1kg)'}},
  ];

  void _showReceiptDialog(BuildContext context, Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                'Receipt',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReceiptRow('Date:', '${transaction['date']} ${transaction['time']}'),
              _buildReceiptRow('Account Name:', transaction['details']['accountName']),
              _buildReceiptRow('Address:', transaction['details']['address']),
              _buildReceiptRow('Points Given:', '${transaction['details']['pointsGiven']}'),
              _buildReceiptRow('Product bought:', transaction['details']['productBought']),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.poppins(
                      color: Colors.green[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
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
          'Transactions',
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
              children: List.generate(_adminTransactionsData.length, (index) {
                final data = _adminTransactionsData[index];
                return _AnimatedTransactionItem(
                  key: ValueKey(data['date'] + data['time']),
                  onTap: () => _showReceiptDialog(context, data),
                  icon: data['type'] == 'Points Given' ? Icons.card_giftcard : Icons.shopping_bag,
                  color: data['type'] == 'Points Given' ? Colors.green : Colors.blue,
                  date: data['date'],
                  time: data['time'],
                  type: data['type'],
                  accountName: data['details']['accountName'],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTransactionItem extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String date;
  final String time;
  final String type;
  final String accountName;
  const _AnimatedTransactionItem({Key? key, required this.onTap, required this.icon, required this.color, required this.date, required this.time, required this.type, required this.accountName}) : super(key: key);

  @override
  State<_AnimatedTransactionItem> createState() => _AnimatedTransactionItemState();
}

class _AnimatedTransactionItemState extends State<_AnimatedTransactionItem> with SingleTickerProviderStateMixin {
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
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.color.withOpacity(0.15),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.type,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.accountName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.date,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    widget.time,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}