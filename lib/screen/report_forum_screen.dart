import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportForumScreen extends StatelessWidget {
  const ReportForumScreen({super.key});

  final List<Map<String, dynamic>> _forumPosts = const [
    {
      'user': 'Alonso',
      'time': '5 mins ago',
      'content': 'It feels great knowing that by just segregating our waste properly, I\'m helping the environment!',
      'upvotes': 884,
      'downvotes': 1,
    },
    {
      'user': 'Teodora',
      'time': '2 hours ago',
      'content': 'Hi, I\'m new here! I\'m wondering if plastic sachets (like shampoo packets) go under recyclables or residuals? I want to make sure I\'m doing it right so I\'m not losing points. Appreciate any tips from the pros here!',
      'upvotes': 569,
      'downvotes': 2,
    },
    {
      'user': 'Realonda',
      'time': '5 hours ago',
      'content': 'Bringing recyclables directly to the drop-off center gives bonus points!',
      'upvotes': 120,
      'downvotes': 0,
    },
    {
      'user': 'Maria',
      'time': '1 day ago',
      'content': 'Does anyone know where I can dispose of old batteries safely in our barangay?',
      'upvotes': 75,
      'downvotes': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Report Forum',
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
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              itemCount: _forumPosts.length,
              itemBuilder: (context, index) {
                final post = _forumPosts[index];
                return _AnimatedForumPostCard(post: post);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedForumPostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const _AnimatedForumPostCard({required this.post});

  @override
  State<_AnimatedForumPostCard> createState() => _AnimatedForumPostCardState();
}

class _AnimatedForumPostCardState extends State<_AnimatedForumPostCard> with SingleTickerProviderStateMixin {
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
    final post = widget.post;
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
          margin: const EdgeInsets.only(bottom: 20.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Colors.green, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['user'],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.green[900],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            post['time'],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  post['content'],
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 20, color: Colors.green[400]),
                        const SizedBox(width: 4),
                        Text('${post['upvotes']}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.w500)),
                        const SizedBox(width: 15),
                        Icon(Icons.arrow_downward, size: 20, color: Colors.red[300]),
                        const SizedBox(width: 4),
                        Text('${post['downvotes']}', style: GoogleFonts.poppins(fontSize: 14, color: Colors.red[400], fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Icon(Icons.chat_bubble_outline, size: 22, color: Colors.grey[600]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}