import 'package:andrew_diana_wedding/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:andrew_diana_wedding/utils/localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

import 'dart:math' as math;

class _Palette {
  static const cream = Color(0xFFFBF3EC);
  static const crimson = Color(0xFFD62839);
  static const crimsonDark = Color(0xFFB81F30);
  static const border = Color(0xFFE85D6B);
}

class PartySection extends StatelessWidget {
  const PartySection({
    super.key,
    required this.deviceType,
    required this.loc,
  });

  final DeviceType deviceType;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: loc.churchTitle,
          deviceType: deviceType,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _PartyCard(
            icon: Icons.celebration, // fallback: Icons.favorite_outline
            tag: loc.churchTag,
            name: loc.partyName,
            address: loc.partyAddress,
            date: loc.partyDate,
            dayName: loc.partyDayName,
            time: loc.partyTime,
            mapUrl: loc.partyMapUrl,
            buttonLabel: loc.partyOpenMap,
          ),
        ),
      ],
    );
  }
}

class _PartyCard extends StatelessWidget {
  final IconData icon;
  final String tag;
  final String name;
  final String address;
  final String date;
  final String dayName;
  final String time;
  final String mapUrl;
  final String buttonLabel;

  const _PartyCard({
    required this.icon,
    required this.tag,
    required this.name,
    required this.address,
    required this.date,
    required this.dayName,
    required this.time,
    required this.mapUrl,
    required this.buttonLabel,
  });

  Future<void> _openMap() async {
    if (kIsWeb) {
      await launchUrl(
        Uri.parse(mapUrl),
        webOnlyWindowName: '_self',
      );
    } else {
      final uri = Uri.parse(mapUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Palette.border.withOpacity(.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header — نفس رسمة الكنيسة الأصلية بالظبط ─────────────
          // (الاسم اتشال من هنا، أصبح مكتوب واضح تحت في الديتلز
          // بدل ما يكون بس نص فوق الصورة)
          Stack(
            children: [
              SizedBox(
                height: 130,
                width: double.infinity,
                child: CustomPaint(painter: _VenueHeaderPainter()),
              ),
              Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black26,
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 14,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 13, color: _Palette.crimson),
                      const SizedBox(width: 5),
                      Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _Palette.crimson,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Details ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── اسم الكنيسة — مكتوب واضح كنص عادي، مش فوق صورة ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.church,
                      size: 18,
                      color: _Palette.crimson,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _Palette.crimsonDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: _Palette.crimson,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _Palette.crimson,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── التاريخ واليوم والميعاد ───────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _MiniBadge(
                        icon: Icons.calendar_month_rounded,
                        label: dayName,
                        value: date,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MiniBadge(
                        icon: Icons.access_time_rounded,
                        label: '',
                        value: time,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          _Palette.crimson,
                          _Palette.crimsonDark,
                        ],
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _openMap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(
                        Icons.map_outlined,
                        size: 15,
                        color: _Palette.cream,
                      ),
                      label: Text(
                        buttonLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _Palette.crimson.withOpacity(.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _Palette.crimson.withOpacity(.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: _Palette.crimson),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label.isNotEmpty)
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: _Palette.crimsonDark,
                    ),
                  ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _Palette.crimson,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _Palette.crimson.withOpacity(.05),
          _Palette.crimson.withOpacity(.12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    canvas.drawCircle(
      Offset(size.width * .5, size.height * .32),
      46,
      Paint()..color = _Palette.crimson.withOpacity(.06),
    );

    canvas.drawLine(
      Offset(0, size.height * .92),
      Offset(size.width, size.height * .92),
      Paint()
        ..color = _Palette.crimson.withOpacity(.18)
        ..strokeWidth = 1,
    );

    final cx = size.width * .5;
    final baseY = size.height * .90;

    final fill = Paint()..color = _Palette.crimson;
    final line = Paint()
      ..color = _Palette.crimsonDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final white = Paint()..color = Colors.white.withOpacity(.95);

    _drawTower(canvas, Offset(cx - 44, baseY), fill, line, white);
    _drawTower(canvas, Offset(cx + 44, baseY), fill, line, white);

    final naveRect = Rect.fromLTWH(cx - 26, baseY - 46, 52, 46);
    canvas.drawRect(naveRect, fill);
    canvas.drawRect(naveRect, line);

    final roofPath = Path()
      ..moveTo(cx - 32, baseY - 46)
      ..lineTo(cx, baseY - 66)
      ..lineTo(cx + 32, baseY - 46)
      ..close();
    canvas.drawPath(roofPath, fill);
    canvas.drawPath(roofPath, line);

    canvas.drawLine(
      Offset(cx, baseY - 66),
      Offset(cx, baseY - 46),
      Paint()
        ..color = Colors.white.withOpacity(.35)
        ..strokeWidth = 1.4,
    );

    final crossPaint = Paint()
      ..color = _Palette.crimsonDark
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, baseY - 66), Offset(cx, baseY - 80), crossPaint);
    canvas.drawLine(
        Offset(cx - 5, baseY - 74), Offset(cx + 5, baseY - 74), crossPaint);

    final roseCenter = Offset(cx, baseY - 30);
    canvas.drawCircle(roseCenter, 8, white);
    canvas.drawCircle(roseCenter, 8, line);
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * 3.14159 / 180;
      canvas.drawLine(
        roseCenter,
        roseCenter + Offset(math.cos(angle), math.sin(angle)) * 8,
        Paint()
          ..color = _Palette.crimson.withOpacity(.6)
          ..strokeWidth = 0.9,
      );
    }
    canvas.drawCircle(roseCenter, 2, Paint()..color = _Palette.crimson);

    final doorRect = Rect.fromLTWH(cx - 6, baseY - 18, 12, 18);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      white,
    );
    canvas.drawLine(
      Offset(cx, baseY - 18),
      Offset(cx, baseY),
      Paint()
        ..color = _Palette.crimson.withOpacity(.4)
        ..strokeWidth = 0.8,
    );

    for (int i = 0; i < 3; i++) {
      final w = 34.0 + i * 10;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(cx, baseY + 2 + i * 3.2),
          width: w,
          height: 3,
        ),
        Paint()..color = _Palette.crimson.withOpacity(.5 - i * .1),
      );
    }
  }

  void _drawTower(
      Canvas canvas,
      Offset base,
      Paint fill,
      Paint line,
      Paint white,
      ) {
    final rect = Rect.fromLTWH(base.dx - 8, base.dy - 40, 16, 40);
    canvas.drawRect(rect, fill);
    canvas.drawRect(rect, line);

    final spire = Path()
      ..moveTo(base.dx - 9, base.dy - 40)
      ..lineTo(base.dx, base.dy - 58)
      ..lineTo(base.dx + 9, base.dy - 40)
      ..close();
    canvas.drawPath(spire, fill);
    canvas.drawPath(spire, line);

    canvas.drawLine(
      Offset(base.dx, base.dy - 58),
      Offset(base.dx, base.dy - 64),
      Paint()
        ..color = _Palette.crimsonDark
        ..strokeWidth = 1.6,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy - 24),
          width: 4,
          height: 10,
        ),
        const Radius.circular(2),
      ),
      white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title, required this.deviceType});
  final DeviceType deviceType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.caveat(
            fontSize: deviceType == DeviceType.desktop ? 60 : 40,
            color: _Palette.crimson,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}