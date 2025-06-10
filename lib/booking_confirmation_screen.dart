import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingConfirmationPage extends StatefulWidget {
  final String groundName;
  final String bookedDate;
  final String session;

  const BookingConfirmationPage({
    super.key,
    required this.groundName,
    required this.bookedDate,
    required this.session,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;
  bool _showContent = false;
  bool _showDateSection = false;
  bool _showSessionDetails = false;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create scale animation
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6),
      ),
    );

    // Create bounce animation for the shake effect
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.04)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.04, end: -0.04)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.04, end: 0.02)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.02, end: 0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8),
      ),
    );

    // Initialize confetti controller

    // Set up listener for animation completion
    _controller.addListener(() {
      if (_controller.value > 0.7 && !_showContent) {
        setState(() {
          _showContent = true;
        });
      }
      if (_controller.value > 0.8 && !_showDateSection) {
        setState(() {
          _showDateSection = true;
        });
      }
      if (_controller.value > 0.9 && !_showSessionDetails) {
        setState(() {
          _showSessionDetails = true;
          // Play confetti when all animations are complete
        });
      }
    });

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade100],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Confetti widget positioned at the top

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated confirmation card
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Transform.rotate(
                              angle: _bounceAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: confirmationCard(context),
                      ),
                      const SizedBox(height: 30),

                      // Animated button appearance
                      AnimatedOpacity(
                        opacity: _showSessionDetails ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedSlide(
                          offset: _showSessionDetails
                              ? Offset.zero
                              : const Offset(0, 0.5),
                          duration: const Duration(milliseconds: 500),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF32A05F),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 8,
                              shadowColor:
                                  const Color(0xFF32A05F).withOpacity(0.5),
                            ),
                            onPressed: () {
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            child: Text(
                              "Back to Home",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget confirmationCard(BuildContext context) {
    // Parse the date
    final DateTime parsedDate = DateTime.parse(widget.bookedDate);

    // Format for display
    final String dayNumber = DateFormat('dd').format(parsedDate);
    final String monthName = DateFormat('MMMM').format(parsedDate);
    final String year = DateFormat('yyyy').format(parsedDate);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with "Match Requested" text
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.asset(
                  'assets/booking.jpg', // Replace with your image path
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.green.shade400,
                            Colors.green.shade800,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.sports_soccer,
                          size: 80,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Animated "Match Requested" text
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  opacity: _showContent ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: _showContent ? value : 0.5,
                          child: Text(
                            "MATCH REQUESTED",
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Ground name with animated appearance
          AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedPadding(
              padding: EdgeInsets.fromLTRB(20, _showContent ? 25 : 0, 20, 15),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groundName,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Ground Location",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Date section with animated appearance
          AnimatedOpacity(
            opacity: _showDateSection ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left - Day
                  _buildAnimatedDateColumn(
                    text: dayNumber,
                    label: "DAY",
                    color: Colors.red.shade600,
                    fontSize: 24,
                    delay: const Duration(milliseconds: 0),
                  ),
                  // Vertical divider
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  // Center - Month
                  _buildAnimatedDateColumn(
                    text: monthName,
                    label: "MONTH",
                    color: Colors.black,
                    fontSize: 20,
                    delay: const Duration(milliseconds: 150),
                  ),
                  // Vertical divider
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  // Right - Year
                  _buildAnimatedDateColumn(
                    text: year,
                    label: "YEAR",
                    color: Colors.black,
                    fontSize: 20,
                    delay: const Duration(milliseconds: 300),
                  ),
                ],
              ),
            ),
          ),

          // Session information with animated appearance
          AnimatedOpacity(
            opacity: _showSessionDetails ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: AnimatedPadding(
              padding: EdgeInsets.all(_showSessionDetails ? 20.0 : 0.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Session Details",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: _showSessionDetails ? value : 0.8,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade50.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            widget.session[0].toUpperCase() +
                                widget.session.substring(1),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDateColumn({
    required String text,
    required String label,
    required Color color,
    required double fontSize,
    required Duration delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: _showDateSection ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Column(
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
