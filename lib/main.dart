import 'package:andrew_diana_wedding/utils/localizations.dart';
import 'package:andrew_diana_wedding/widgets/count_down.dart';
import 'package:andrew_diana_wedding/widgets/language_toggle.dart';
import 'package:flutter/material.dart';
import 'open.dart';
import 'theme/app_theme.dart';
import 'widgets/hero_section.dart';
import 'widgets/date_picker_section.dart';
import 'widgets/rsvp_section.dart';
import 'widgets/venue_section.dart';
import 'widgets/footer_section.dart';
import 'package:flutter/gestures.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:math' as math;


import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeddingInvitationApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class WeddingInvitationApp extends StatelessWidget {
  const WeddingInvitationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      title: "Andrew & Diana — We're Getting Married",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.crimson,
          primary: AppColors.crimson,
        ),
      ),
      home: const _RootScreen(),
    );
  }
}

class _RootScreen extends StatefulWidget {
  const _RootScreen();

  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  html.AudioElement? _audio;
  bool _showHome = false;

  void _onOpen(html.AudioElement audio) {
    if (_showHome) return;
    setState(() {
      _audio = audio;
      _showHome = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // دايماً موجود في الخلف عشان الـ BackdropFilter يشتغل
        WeddingInvitationPage(bgAudio: _audio),

        if (!_showHome) CurtainScreen(onOpen: _onOpen),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class WeddingInvitationPage extends StatefulWidget {
  final html.AudioElement? bgAudio;

  const WeddingInvitationPage({super.key, required this.bgAudio});

  @override
  State<WeddingInvitationPage> createState() => _WeddingInvitationPageState();
}

class _WeddingInvitationPageState extends State<WeddingInvitationPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _datePickerKey = GlobalKey();

  String _locale = 'en';

  html.AudioElement? _bgPlayer;
  bool _isPlaying = false;
  bool audioReady = true;

  @override
  void initState() {
    super.initState();

    if (widget.bgAudio != null) {
      _initAudio(widget.bgAudio!);
    }

    html.window.navigator.mediaSession?.metadata = null;
    html.document.addEventListener('visibilitychange', _onVisibilityChange);
    html.window.addEventListener('pagehide', _onPageHide);
  }

  @override
  void didUpdateWidget(WeddingInvitationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bgAudio != null && oldWidget.bgAudio == null) {
      _initAudio(widget.bgAudio!);
    }
  }

  void _initAudio(html.AudioElement audio) {
    _bgPlayer = audio;
    _isPlaying = !_bgPlayer!.paused;

    _bgPlayer!.onPause.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _bgPlayer!.onPlay.listen((_) {
      if (mounted) setState(() => _isPlaying = true);
    });
  }

  // =========================
  // 🎧 AUDIO CONTROLS
  // =========================

  Future<void> _playAudio() async {
    try {
      if (_bgPlayer == null) {
        _bgPlayer = html.AudioElement()
          ..src = 'assets/assets/audio/special_message.mp3'
          ..preload = 'auto'
          ..volume = 1.0;

        _bgPlayer!.onPause.listen((_) {
          if (mounted) setState(() => _isPlaying = false);
        });

        _bgPlayer!.onPlay.listen((_) {
          if (mounted) setState(() => _isPlaying = true);
        });
      }

      await _bgPlayer!.play();
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint("Play error: $e");
    }
  }

  void _stopAudio() {
    try {
      final oldPlayer = _bgPlayer;
      oldPlayer?.pause();
      oldPlayer?.currentTime = 0;
      _bgPlayer = null;
      oldPlayer?.src = '';
      oldPlayer?.load();
      _clearMediaSession();
      if (mounted) setState(() => _isPlaying = false);
    } catch (e) {
      debugPrint("Stop error: $e");
    }
  }

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      _stopAudio();
    } else {
      await _playAudio();
    }
  }

  void _clearMediaSession() {
    js.context.callMethod('eval', [
      '''
      if ('mediaSession' in navigator) {
        navigator.mediaSession.metadata = null;
        navigator.mediaSession.playbackState = "none";
        try { navigator.mediaSession.setActionHandler("play", null); } catch(e){}
        try { navigator.mediaSession.setActionHandler("pause", null); } catch(e){}
        try { navigator.mediaSession.setActionHandler("stop", null); } catch(e){}
        try { navigator.mediaSession.setActionHandler("seekbackward", null); } catch(e){}
        try { navigator.mediaSession.setActionHandler("seekforward", null); } catch(e){}
        try { navigator.mediaSession.setActionHandler("previoustrack", null); } catch(e){}
        try { navigator.mediaSession.setActionHandler("nexttrack", null); } catch(e){}
      }
    ''',
    ]);
  }

  void _onVisibilityChange(html.Event _) {
    if (html.document.visibilityState == 'hidden') _stopAudio();
  }

  void _onPageHide(html.Event _) {
    _bgPlayer?.pause();
  }

  // =========================
  // UI
  // =========================

  void _toggleLocale() {
    setState(() => _locale = _locale == 'en' ? 'ar' : 'en');
  }

  void _scrollToDatePicker() {
    final ctx = _datePickerKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    html.document.removeEventListener('visibilitychange', _onVisibilityChange);
    html.window.removeEventListener('pagehide', _onPageHide);

    _bgPlayer?.pause();
    _bgPlayer?.currentTime = 0;
    _bgPlayer?.src = '';
    _bgPlayer?.load();
    _clearMediaSession();

    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations(_locale);

    return Scaffold(
      body: Directionality(
        textDirection: loc.isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final deviceType = Responsive.deviceTypeOf(constraints.maxWidth);

            return Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(
                    child: FallingHeartsOverlay(),
                  ),
                ),
                ListView(
                  controller: _scrollController,
                  children: [
                    HeroSection(
                      deviceType: deviceType,
                      loc: loc,
                      coupleNames: loc.heroCoupleNames,
                      weddingDate: loc.heroWeddingDate,
                      onChevronTap: _scrollToDatePicker,
                    ),
                    const SizedBox(height: 12),
                    WeddingCountdown(loc: loc),
                    const SizedBox(height: 12),
                    DatePickerSection(
                      key: _datePickerKey,
                      deviceType: deviceType,
                      loc: loc,
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PartySection(deviceType: deviceType, loc: loc),
                    ),

                    // ---------- RSVP ----------
                    RsvpSection(deviceType: deviceType, loc: loc),

                    const SizedBox(height: 100),
                    FooterSection(loc: loc),
                  ],
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Align(
                      alignment: loc.isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        height: 55,
                        color: AppColors.paper,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: LanguageToggle(
                            currentLocale: _locale,
                            onToggle: _toggleLocale,
                            isPlaying: _isPlaying,
                            audioReady: audioReady,
                            onToggleAudio: _toggleAudio,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 💗 Falling hearts decoration overlay
// ─────────────────────────────────────────────────────────────────────────────

class FallingHeartsOverlay extends StatefulWidget {
  const FallingHeartsOverlay({super.key});

  @override
  State<FallingHeartsOverlay> createState() => _FallingHeartsOverlayState();
}

class _FallingHeartsOverlayState extends State<FallingHeartsOverlay>
    with TickerProviderStateMixin {
  final List<_HeartData> _hearts = [];
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 14; i++) {
      _addHeart(delay: Duration(milliseconds: _rand.nextInt(5000)));
    }
  }

  void _addHeart({Duration delay = Duration.zero}) {
    final duration = Duration(seconds: 7 + _rand.nextInt(6));
    final controller = AnimationController(vsync: this, duration: duration);
    final heart = _HeartData(
      controller: controller,
      left: _rand.nextDouble(),
      size: 10 + _rand.nextDouble() * 14,
      opacity: 0.3 + _rand.nextDouble() * 0.4,
      swayAmplitude: 10 + _rand.nextDouble() * 20,
    );
    _hearts.add(heart);

    Future.delayed(delay, () {
      if (mounted) controller.repeat();
    });
  }

  @override
  void dispose() {
    for (final h in _hearts) {
      h.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        return Stack(
          children: _hearts.map((heart) {
            return AnimatedBuilder(
              animation: heart.controller,
              builder: (context, child) {
                final t = heart.controller.value;
                final top = -30 + t * (height + 60);
                final sway = math.sin(t * 4 * math.pi) * heart.swayAmplitude;
                return Positioned(
                  top: top,
                  left: (heart.left * width + sway).clamp(
                    0.0,
                    width - heart.size,
                  ),
                  child: Opacity(
                    opacity: heart.opacity,
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.crimson,
                      size: heart.size,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}

class _HeartData {
  final AnimationController controller;
  final double left;
  final double size;
  final double opacity;
  final double swayAmplitude;

  _HeartData({
    required this.controller,
    required this.left,
    required this.size,
    required this.opacity,
    required this.swayAmplitude,
  });
}
