import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget kTitle({
  required BuildContext context,
  required String title,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Text(
      title,
      style: GoogleFonts.roboto().copyWith(
        fontSize: 33,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.headline1?.color?.withOpacity(0.78),
      ),
    ),
  );
}
