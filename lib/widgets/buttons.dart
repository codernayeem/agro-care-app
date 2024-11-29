import 'package:flutter/material.dart';

import '../theme/colors.dart';

class MyButtons {
  static Widget filledButton1(String text, void Function() onPressed,
      {bool loading = false, IconData? icon}) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loading
              ? const SizedBox(
                  height: 27,
                  width: 27,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: "SanFranciscoLight",
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600),
                ),
          if (icon != null) const SizedBox(width: 10),
          if (icon != null)
            const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  static Widget filledButton2(String text, void Function() onPressed,
      {bool loading = false, Widget? icon, Color color = Colors.black87}) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          if (icon != null) const SizedBox(width: 10),
          loading
              ? const SizedBox(
                  height: 27,
                  width: 27,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(fontSize: 16, color: color),
                ),
        ],
      ),
    );
  }
}
