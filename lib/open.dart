import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;

class CurtainScreen extends StatefulWidget {
  final void Function(html.AudioElement audio) onOpen;

  const CurtainScreen({super.key, required this.onOpen});

  @override
  State<CurtainScreen> createState() => _CurtainScreenState();
}

class _CurtainScreenState extends State<CurtainScreen> {
  // ---- Palette (matches the web splash screen) ----
  static const Color cream = Color(0xFFFEF6F2);
  static const Color ribbonPale = Color(0xFFEFC9C2);
  static const Color ribbon = Color(0xFFA83A34);
  static const Color ribbonDeep = Color(0xFF7E2620);
  static const Color inkSoft = Color(0xFF6B3B33);
  static const Color titleDark = Color(0xFF3A1512);

  bool _opened = false;
  html.AudioElement? _audio;

  @override
  void initState() {
    super.initState();
    _audio = html.AudioElement()
      ..src = 'assets/assets/audio/special_message.mp3'
      ..preload = 'auto'
      ..volume = 1.0;
  }

  void _open() {
    if (_opened) return;
    setState(() => _opened = true);
    _audio?.play().catchError((e) => debugPrint('Play error: $e'));
    widget.onOpen(_audio!);
  }

  @override
  void dispose() {
    if (_opened) {
      // الصوت اتبعت للـ parent — متمسهوش هنا
    } else {
      _audio?.pause();
      _audio?.src = '';
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
        color: Colors.transparent,
        child: GestureDetector(
            onTap: _open,
            child: Stack(fit: StackFit.expand, children: [
              BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: cream.withOpacity(0.25),
                ),
              ),

              Center(
                child: Container(
                  width: 0.8,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ribbon.withOpacity(0.0),
                        ribbon.withOpacity(0.7),
                        ribbon.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // floating hearts scattered around the circle
              ..._buildFloatingHearts(size),

              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cream.withOpacity(0.95),
                    border: Border.all(
                      color: ribbonPale.withOpacity(0.8),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ribbonDeep.withOpacity(0.16),
                        blurRadius: 26,
                        spreadRadius: 6,
                      ),
                      BoxShadow(
                        color: ribbon.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: const Icon(
                          Icons.favorite,
                          color: ribbon,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        ' Andrew & Diana ',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: titleDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(height: 10),
                      Text(
                        'Tap to Open',
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 10,
                          letterSpacing: 2,
                          color: inkSoft.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ])));
  }

  // small decorative hearts drifting near the circle, purely visual
  List<Widget> _buildFloatingHearts(Size size) {
    final positions = <Offset>[
      Offset(size.width * 0.28, size.height * 0.32),
      Offset(size.width * 0.72, size.height * 0.30),
      Offset(size.width * 0.22, size.height * 0.68),
      Offset(size.width * 0.78, size.height * 0.66),
      Offset(size.width * 0.5, size.height * 0.20),
    ];
    final sizes = [14.0, 10.0, 12.0, 9.0, 11.0];

    return List.generate(positions.length, (i) {
      return Positioned(
        left: positions[i].dx,
        top: positions[i].dy,
        child: Icon(
          Icons.favorite,
          size: sizes[i],
          color: ribbon.withOpacity(0.25),
        ),
      );
    });
  }
}