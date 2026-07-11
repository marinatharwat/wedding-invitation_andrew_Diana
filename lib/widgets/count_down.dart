import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:andrew_diana_wedding/utils/localizations.dart';


final DateTime weddingDate = DateTime(2026, 7, 28);

// Same palette used across HeroSection / DatePickerSection.
class _Palette {
  static const cream = Color(0xFFFBF3EC);
  static const crimson = Color(0xFFD62839);
  static const crimsonDark = Color(0xFFB81F30);
  static const border = Color(0xFFE85D6B);
}

class WeddingCountdown extends StatefulWidget {
  const WeddingCountdown({super.key, this.targetDate, this.loc});

  final DateTime? targetDate;
  final AppLocalizations? loc;

  @override
  State<WeddingCountdown> createState() => _WeddingCountdownState();
}

class _WeddingCountdownState extends State<WeddingCountdown> {
  late Timer _timer;
  late Duration _remaining;
  late DateTime _target;

  @override
  void initState() {
    super.initState();
    _target = widget.targetDate ?? weddingDate;
    _remaining = _calculateRemaining();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => setState(() => _remaining = _calculateRemaining()),
    );
  }

  Duration _calculateRemaining() {
    final diff = _target.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc ?? const AppLocalizations('en');

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    final isOver = _remaining.inSeconds <= 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final headlineSize = (w * 0.09).clamp(28.0, 52.0);
        final dateLabelSize = (w * 0.032).clamp(12.0, 15.0);
        final circleSize = (w * 0.08).clamp(52.0, 76.0);
        final numSize = circleSize * 0.34;

        return Center(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                loc.heroCountdownTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.aboreto(
                  fontSize: headlineSize * 0.65,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: _Palette.crimson,
                ),
              ),
              SizedBox(height:10),
              Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.04,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: _Palette.crimson,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _Palette.border, width: 1.4),
                  boxShadow: [
                    BoxShadow(
                      color: _Palette.crimsonDark.withOpacity(.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isOver
                        ? CustomPaint(
                      size: const Size(40, 42),
                      painter: _HeartPainter(
                        fillColor: _Palette.cream,
                        strokeColor: _Palette.cream,
                        strokeWidth: 0,
                      ),
                    )
                        : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 16,
                      children: [
                        _Unit(
                          value: days,
                          label: loc.unitDays,
                          size: circleSize,
                          numSize: numSize,
                        ),
                        _Unit(
                          value: hours,
                          label: loc.unitHours,
                          size: circleSize,
                          numSize: numSize,
                        ),
                        _Unit(
                          value: minutes,
                          label: loc.unitMinutes,
                          size: circleSize,
                          numSize: numSize,
                        ),
                        _Unit(
                          value: seconds,
                          label: loc.unitSeconds,
                          size: circleSize,
                          numSize: numSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      loc.countdownDate,
                      style: GoogleFonts.marcellus(
                        fontSize: dateLabelSize,
                        letterSpacing: 3,
                        color: _Palette.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Unit extends StatelessWidget {
  const _Unit({
    required this.value,
    required this.label,
    required this.size,
    required this.numSize,
  });

  final int value;
  final String label;
  final double size;
  final double numSize;

  @override
  Widget build(BuildContext context) {
    // hearts read a bit narrower than tall, so give the badge a touch
    // more height than width for a natural heart proportion
    final badgeWidth = size;
    final badgeHeight = size * 1.08;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: badgeWidth,
          height: badgeHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // cream heart body on the crimson card background
              CustomPaint(
                size: Size(badgeWidth, badgeHeight),
                painter: _HeartPainter(
                  fillColor: _Palette.cream,
                  strokeColor: _Palette.border,
                  strokeWidth: 1.5,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: badgeHeight * 0.08),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: GoogleFonts.marcellus(
                    fontSize: numSize,
                    color: _Palette.crimsonDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          label,
          style: GoogleFonts.jost(
            fontSize: 10,
            letterSpacing: 1.4,
            color: _Palette.cream,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// HEART SHAPE PAINTER (filled)
// ─────────────────────────────────────────────

class _HeartPainter extends CustomPainter {
  _HeartPainter({
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  Path _heartPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(w * 0.5, h * 0.98);
    path.cubicTo(
      w * -0.05, h * 0.62,
      w * 0.05, h * 0.05,
      w * 0.5, h * 0.28,
    );
    path.cubicTo(
      w * 0.95, h * 0.05,
      w * 1.05, h * 0.62,
      w * 0.5, h * 0.98,
    );
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _heartPath(size);

    canvas.drawPath(path, Paint()..color = fillColor);

    if (strokeWidth > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// ─────────────────────────────────────────────
// HEART SHAPE PAINTER (outline only) — small accent heart at the top
// ─────────────────────────────────────────────

class _OutlineHeartPainter extends CustomPainter {
  _OutlineHeartPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.98)
      ..cubicTo(w * -0.05, h * 0.62, w * 0.05, h * 0.02, w * 0.5, h * 0.26)
      ..cubicTo(w * 0.95, h * 0.02, w * 1.05, h * 0.62, w * 0.5, h * 0.98)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}