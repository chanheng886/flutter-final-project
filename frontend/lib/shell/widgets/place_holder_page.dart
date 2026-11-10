import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PlaceHolderPage extends StatelessWidget {
  const new({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
