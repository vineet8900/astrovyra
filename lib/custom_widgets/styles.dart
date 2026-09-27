import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomStyles {
  /// API base (no trailing slash). Change server only here.
  static const String apiBaseUrl = 'https://astro.vyntrixa.in/api';

  /// Website origin (share links, product URLs).
  static const String webBaseUrl = 'https://astro.vyntrixa.in';

  /// Host only (e.g. [Uri.https]).
  static const String apiHost = 'astro.vyntrixa.in';

  /// `${apiBaseUrl}/` for legacy `...${CustomStyles.baseUrl}path` concatenation.
  static String get baseUrl => '$apiBaseUrl/';

  // Updated Color Palette
  static Color bgcolor =
      Color.fromARGB(147, 255, 246, 229); // Stardust Cream - Primary Background
  static Color accentColor = Color(0xFFE8E8E8);
  static Color secondaryAccent =
      Color(0xFFA7D8F0); // Celestial Blue - Secondary Accent
  static Color ctaColor = Color(0xFF0E4677);
  static Color detailColor = Color(0xFFFCF5D2); // Pastel Sage - Icons/Details
  static const Color detailsOrange = Color(0xFFFF6A00);

  /// Offer / booking countdown boxes (backgrounds only; labels use black text).
  static const Color offerCountdownDaysBg = Color(0xFFC8E6C9);
  static const Color offerCountdownHoursBg = Color(0xFFFFE0B2);
  static const Color offerCountdownMinutesBg = Color(0xFFBBDEFB);
  static const Color offerCountdownSecondsBg = Color(0xFFE1BEE7);
  static Color bgredcolor = Color(0xffFA3E3E);
  static Color darkgreen = Color(0xFF006400);
  static Color lightgreen = Color(0xFF90EE90);
  static Color green = Color(0xFF4CAF50);
  static Color pinki = Color(0xFF0E4677);
  static const Color chatActionGreen = Color(0xFF34A853);
  static const Color callActionBlue = Color(0xFF2196F3);
  static Color get callActionBackground => callActionBlue;
  static Color get videoActionBackground => bgredcolor;
  static const TextStyle chatPillTextWhite = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );
  static const TextStyle chatRateCardLabelWhite = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );
  static Color whiteColor = Color.fromRGBO(255, 255, 255, 1);
  static Color grey = Color(0xFF9E9E9E);
  //staic Color white1 = Color(value)

  // Text Styles - White
  static TextStyle white = GoogleFonts.lato(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle white12500 = GoogleFonts.lato(
      fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white);
  static TextStyle white13600 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white);

  // Text Styles - Black
  static TextStyle black12400 = GoogleFonts.lato(
      fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black);
  static TextStyle black12500 = GoogleFonts.lato(
      fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle black13600 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle black14400 = GoogleFonts.lato(
      fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black);
  static TextStyle black14500 = GoogleFonts.lato(
      fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black);
  static TextStyle black14600 = GoogleFonts.lato(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle black18600 = GoogleFonts.lato(
      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle black16600 = GoogleFonts.lato(
      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  static TextStyle black25600 = GoogleFonts.lato(
      fontSize: 25, fontWeight: FontWeight.w600, color: Colors.black);

  // Text Styles - Grey
  static TextStyle grey12400 = GoogleFonts.lato(
      fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey);
  static TextStyle grey14400 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey.shade700);
  static TextStyle grey12500 = GoogleFonts.montserrat(
      fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey);
  static TextStyle grey12300 = GoogleFonts.lato(
      fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey.shade200);
  static TextStyle grey14600 = GoogleFonts.lato(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700);

  // Text Styles - Colors
  static TextStyle red15600 = GoogleFonts.lato(
      fontSize: 15, fontWeight: FontWeight.w600, color: Colors.red);
  static TextStyle red13500 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red);
  static TextStyle blue13500 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blue);
  static TextStyle ord13500 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w500, color: Colors.orange);
  static TextStyle green14600 = GoogleFonts.lato(
      fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green);
  static TextStyle blue13600 = GoogleFonts.lato(
      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blue);
}
