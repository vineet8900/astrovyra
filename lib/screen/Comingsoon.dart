import 'dart:math';

import 'package:flutter/material.dart';

class Comingsoon extends StatefulWidget {
  const Comingsoon({super.key});

  @override
  State<Comingsoon> createState() => _ComingsoonState();
}

class _ComingsoonState extends State<Comingsoon> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 480;
    final isMedium = size.width >= 480 && size.width < 768;
    final isLarge = size.width >= 768 && size.width < 1024;
    final isXLarge = size.width >= 1024;

    // Responsive values
    double logoSize = isSmall
        ? 80
        : isMedium
            ? 100
            : isLarge
                ? 120
                : 140;
    double iconSize = logoSize * 0.5;
    double titleSize = isSmall
        ? 32
        : isMedium
            ? 40
            : isLarge
                ? 48
                : 56;
    double subtitleSize = isSmall
        ? 16
        : isMedium
            ? 18
            : isLarge
                ? 20
                : 22;
    double horizontalPadding = isSmall
        ? 20
        : isMedium
            ? 30
            : isLarge
                ? 40
                : 60;
    double emailMaxWidth = isSmall
        ? double.infinity
        : isMedium
            ? 350
            : isLarge
                ? 400
                : 450;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B2A), // Deep night blue
              Color(0xFF1B263B), // Dark blue
              Color(0xFF2D1B69), // Purple
              Color(0xFF6A4C93), // Light purple
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              //min-height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1),

                  // Stars decoration
                  Container(
                    width: double.infinity,
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 20,
                          left: size.width * 0.2,
                          child:
                              Icon(Icons.star, color: Colors.yellow, size: 12),
                        ),
                        Positioned(
                          top: 40,
                          right: size.width * 0.3,
                          child:
                              Icon(Icons.star, color: Colors.white70, size: 8),
                        ),
                        Positioned(
                          top: 10,
                          right: size.width * 0.1,
                          child:
                              Icon(Icons.star, color: Colors.yellow, size: 16),
                        ),
                        Positioned(
                          top: 60,
                          left: size.width * 0.1,
                          child:
                              Icon(Icons.star, color: Colors.white70, size: 10),
                        ),
                      ],
                    ),
                  ),

                  // Crystal Ball / Astro Icon
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6A4C93),
                          Color(0xFF9A7AA0),
                          Color(0xFFB8860B),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Main Text
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        Text(
                          'HareKrishna',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          'Coming Soon',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize + 4,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB8860B),
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          'Discover your destiny through the stars.\nConnect with expert astrologers and\nunlock the secrets of the universe.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleSize - 2,
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Astro Features
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //_buildFeature(Icons.stars, 'Horoscope', isSmall),
                        //_buildFeature(Icons.timeline, 'Predictions', isSmall),
                        // _buildFeature(Icons.chat, 'Chat with\nAstrologers', isSmall),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Email Input
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Container(
                      constraints: BoxConstraints(maxWidth: emailMaxWidth),
                      height: isSmall ? 50 : 55,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: const Color(0xFFB8860B).withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter your email for early access',
                                hintStyle: TextStyle(
                                  color: Colors.white60,
                                  fontSize: isSmall ? 14 : 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(6),
                            width: isSmall ? 38 : 43,
                            height: isSmall ? 38 : 43,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB8860B), Color(0xFF6A4C93)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: isSmall ? 18 : 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Bottom text
                  Text(
                    '✨ The stars are aligning for something magical ✨',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      color: Colors.white60,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text, bool isSmall) {
    return Column(
      children: [
        Container(
          width: isSmall ? 50 : 60,
          height: isSmall ? 50 : 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFB8860B).withOpacity(0.3),
            ),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFB8860B),
            size: isSmall ? 24 : 28,
          ),
        ),
        SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 10 : 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
