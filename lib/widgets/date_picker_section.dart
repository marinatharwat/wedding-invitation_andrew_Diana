import 'package:flutter/material.dart';
import 'package:andrew_diana_wedding/utils/localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'day_card.dart';
class DatePickerSection extends StatelessWidget {
  const DatePickerSection({
    super.key,
    required this.deviceType,
    required this.loc,
  });

  final DeviceType deviceType;
  final AppLocalizations loc;

  // the actual wedding day
  static const int weddingDay = 28;
  static const int weddingMonth = 7;
  static const int weddingYear = 2026;

  bool get _isDesktop => deviceType == DeviceType.desktop;

  @override
  Widget build(BuildContext context) {
    final isDesktop = deviceType == DeviceType.desktop;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            loc.datePickerTitle,
            textAlign: TextAlign.center,
            style: AppText.title(isDesktop ? 31 : 28).copyWith(
              color: WeddingMonthCalendar._crimson,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            loc.datePickerBody,
            textAlign: TextAlign.center,
            style: AppText.copy(14).copyWith(  color:  WeddingMonthCalendar.ribbonDeep,),
          ),
          const SizedBox(height: 26),
          WeddingMonthCalendar(
            year: weddingYear,
            month: weddingMonth,
            highlightDay: weddingDay,
            loc: loc,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FULL MONTH CALENDAR CARD — red & cream wedding theme
// ─────────────────────────────────────────────

class WeddingMonthCalendar extends StatelessWidget {
  const WeddingMonthCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.highlightDay,
    required this.loc,
  });

  final int year;
  final int month;
  final int highlightDay;
  final AppLocalizations loc;

  // Palette pulled from the invitation card:
  // deep crimson red as the dominant color, warm cream as the
  // light contrast, with a thin red line-art border.
  static const _cream = Color(0xFFFBF3EC);
  static const _crimson = Color(0xFFD62839);
  static const _crimsonDark = Color(0xFFB81F30);
  static const _border = Color(0xFFE85D6B);
  static const Color ribbonDeep =  Color(0xFF2B0306);

  int _firstWeekday(int y, int m) {
    final firstDay = DateTime(y, m, 1);
    return firstDay.weekday % 7;
  }

  int _daysInMonth(int y, int m) {
    return DateTime(y, m + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = _firstWeekday(year, month);
    final totalDays = _daysInMonth(year, month);

    final cells = <int?>[
      ...List.filled(firstWeekday, null),
      ...List.generate(totalDays, (i) => i + 1),
    ];

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    // لو الـ localization ناقصة استخدم أسماء افتراضية
    final weekdays = loc.weekdayShort.length == 7
        ? loc.weekdayShort
        : const [
      "Sun",
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
    ];

    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: _crimson,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _border,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: _crimsonDark.withOpacity(.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month / year label
          Text(
            loc.monthYearLabel(month, year),
            style: GoogleFonts.jost(
              fontSize: 13,
              letterSpacing: 3,
              color: _cream,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // small heart divider, echoes the line-art hearts on the card
          Icon(
            Icons.favorite_border,
            size: 14,
            color: _cream.withOpacity(.85),
          ),
          const SizedBox(height: 14),

          // inner cream panel holding the grid, matching the card's
          // cream section above the red block
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: _cream,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _border.withOpacity(.6),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: List.generate(
                    7,
                        (i) => Expanded(
                      child: Center(
                        child: Text(
                          weekdays[i],
                          style: GoogleFonts.jost(
                            fontSize: 11,
                            color: _crimson.withOpacity(.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cells.length,
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final day = cells[index];

                    if (day == null) {
                      return const SizedBox.shrink();
                    }

                    final isWeddingDay = day == highlightDay;

                    return Center(
                      child: isWeddingDay
                          ? _PulsingHeartDay(
                        day: day,
                        fillColor: _crimson,
                        numberColor: _cream,
                      )
                          : Text(
                        "$day",
                        style: GoogleFonts.jost(
                          fontSize: 13,
                          color: _crimsonDark,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PULSING HEART — custom-drawn shape (not the Material
// favorite icon) with a slow, gentle heartbeat animation
// on the wedding day cell.
// ─────────────────────────────────────────────

class _PulsingHeartDay extends StatefulWidget {
  const _PulsingHeartDay({
    required this.day,
    required this.fillColor,
    required this.numberColor,
  });

  final int day;
  final Color fillColor;
  final Color numberColor;

  @override
  State<_PulsingHeartDay> createState() => _PulsingHeartDayState();
}

class _PulsingHeartDayState extends State<_PulsingHeartDay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    // gentle beat: 1.0 -> 1.14 -> 1.0, eased like a real pulse
    // rather than a linear bounce
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.14)
            .chain(CurveTween(curve: Curves.easeOutSine)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.14, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInSine)),
        weight: 55,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(32, 30),
              painter: _HeartPainter(
                fillColor: widget.fillColor,
                highlightColor: widget.numberColor.withOpacity(.18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                "${widget.day}",
                style: GoogleFonts.jost(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: widget.numberColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hand-drawn-style heart shape (Bezier curves), used instead of the
/// default Material `Icons.favorite` glyph so it matches the
/// invitation's illustrated look — includes a soft inner highlight
/// for a bit of dimension instead of a flat icon fill.
class _HeartPainter extends CustomPainter {
  _HeartPainter({
    required this.fillColor,
    required this.highlightColor,
  });

  final Color fillColor;
  final Color highlightColor;

  Path _heartPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    path.moveTo(w * 0.5, h * 0.98);
    path.cubicTo(
      w * -0.05, h * 0.62,
      w * 0.05, h * 0.02,
      w * 0.5, h * 0.26,
    );
    path.cubicTo(
      w * 0.95, h * 0.02,
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

    // a soft light patch near the top-left lobe so the heart doesn't
    // read as a completely flat block of red
    final highlight = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width * 0.32, size.height * 0.28),
        radius: size.width * 0.14,
      ));
    canvas.save();
    canvas.clipPath(path);
    canvas.drawPath(highlight, Paint()..color = highlightColor);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.highlightColor != highlightColor;
  }
}