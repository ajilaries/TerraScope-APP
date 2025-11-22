import 'package:flutter/material.dart';

Future<void> showThemeSelectPopup(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose Your Theme",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ThemeBox(
                    title: "Light",
                    color: Colors.white,
                    borderColor: Colors.grey.shade400,
                    onTap: () {
                      Navigator.pop(context);
                      // Next popup -> personalization
                    },
                  ),
                  _ThemeBox(
                    title: "Dark",
                    color: Colors.black,
                    borderColor: Colors.green,
                    textColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      // Next popup -> personalization
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Back",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

class _ThemeBox extends StatelessWidget {
  final String title;
  final Color color;
  final Color borderColor;
  final Color? textColor;
  final VoidCallback onTap;

  const _ThemeBox({
    required this.title,
    required this.color,
    required this.borderColor,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        width: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
