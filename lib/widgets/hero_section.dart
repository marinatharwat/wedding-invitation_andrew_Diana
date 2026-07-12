import 'package:andrew_diana_wedding/utils/localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.deviceType,
    required this.coupleNames,
    required this.weddingDate,
    required this.onChevronTap,
    required this.loc,
  });

  final DeviceType deviceType;

  // expected format: "Name1 & Name2" (also accepts "+", "and", or Arabic "و")
  final String coupleNames;
  final String weddingDate;
  final VoidCallback onChevronTap;
  final AppLocalizations loc;

  static const _cream = Color(0xFFFBF3EC);
  static const _crimson = Color(0xFFD62839);

  bool get _isDesktop => deviceType == DeviceType.desktop;

  List<String> get _names {
    final raw = coupleNames.trim();
    final parts = raw.split(
      RegExp(r'\s*&\s*|\s*\+\s*|\s+and\s+|\s+و', caseSensitive: false),
    );
    final cleaned =
    parts.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    if (cleaned.length >= 2) {
      return [cleaned[0], cleaned[1]];
    }
    return [raw, ''];
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = switch (deviceType) {
      DeviceType.desktop => const Size(280, 340),
      DeviceType.tablet => const Size(230, 280),
      DeviceType.mobile => const Size(260, 320),
    };

    final names = _names;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      ClipPath(
        clipper: WaveClipper(),
        child: Container(
          width: double.infinity,
          color: _crimson,
          padding: const EdgeInsets.fromLTRB(28, 70, 28, 54),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _VerseBlock(
                raw: loc.heroEyebrow,
                isDesktop: _isDesktop,
                color: Colors.white,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: onChevronTap,
                child: const _BobbingChevron(),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 15),
      Text(
        loc.youAreInvited,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: _isDesktop ? 28 : 22,
          fontWeight: FontWeight.w600,
          color: _crimson,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        loc.theWeddingOf,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: _isDesktop ? 28 : 22,
          fontWeight: FontWeight.w600,
          color: _crimson,
        ),
      ),
      const SizedBox(height: 15),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          names[0],
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontFamily: 'AlexBrush',
            fontSize: _isDesktop ? 76 : 64,
            color: _crimson,
            height: 1.35,
          ),
        ),
      ),
      if (names[1].isNotEmpty) ...[
        const SizedBox(height: 4),
        // divider between names — plain "&" in the same serif
        // family as the eyebrow/date, not the cursive font
        Text(
          '&',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: _crimson,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            names[1],
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            style: TextStyle(
              fontFamily: 'AlexBrush',
              fontSize: _isDesktop ? 76 : 64,
              color: _crimson,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _photo(frameSize),
        const SizedBox(height: 20),
      ]
    ]);
  }

  Widget _photo(Size size) {
    return SizedBox(
      width: 400,
      height: 450,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // circular photo
          Positioned(
            left: 10,
            top: 10,
            right: 10,
            bottom: 10,
            child: ClipOval(
              child: Image.asset(
                "assets/images/2.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          // thin decorative ring around the circle
        ],
      ),
    );
  }
}

class _VerseBlock extends StatelessWidget {
  const _VerseBlock({
    required this.raw,
    required this.isDesktop,
    required this.color,
  });

  final String raw;
  final bool isDesktop;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final lines = raw.split('\n');
    final verse = lines.first.trim();
    final reference =
    lines.length > 1 ? lines.sublist(1).join(' ').trim() : '';

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: isDesktop ? 420 : 300),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Text(
            '“ $verse ”',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: isDesktop ? 19 : 16.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              height: 1.75,
              color: color,
            ),
          ),
          if (reference.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reference.replaceAll(RegExp(r'[()]'), '').toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 11,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SIMPLE WAVE CLIPPER
// ─────────────────────────────────────────────

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 30,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ─────────────────────────────────────────────
// CHEVRON
// ─────────────────────────────────────────────

class _BobbingChevron extends StatefulWidget {
  const _BobbingChevron();

  @override
  State<_BobbingChevron> createState() => _BobbingChevronState();
}

class _BobbingChevronState extends State<_BobbingChevron>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.value * 6),
          child: const Icon(
            Icons.keyboard_arrow_down,
            size: 26,
            color: HeroSection._cream,
          ),
        );
      },
    );
  }
}