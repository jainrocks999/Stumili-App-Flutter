import 'package:flutter/material.dart';

class GradientOutlinedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double borderRadius;
  final double height;
  final List<Color> gradientColors;

  const GradientOutlinedButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.borderRadius = 14,
    this.height = 48,
    this.gradientColors = const [Color(0xFFD485D1), Color(0xFFB72658)],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Gradient border
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          // Inner button with padding to show border
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(2), // border thickness
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius - 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius - 2),
                  onTap: onPressed,
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: gradientColors,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white, // overridden by gradient
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
