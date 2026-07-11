import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small pill-shaped EN / عربي switch.
///
/// Tapping it flips [currentLocale] (handled by the parent via [onToggle]),
/// which in turn re-renders the whole page in the other language and flips
/// its reading direction.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    required this.currentLocale,
    required this.onToggle,

    required this.isPlaying,
    required this.audioReady,
    required this.onToggleAudio,
  });

  final String currentLocale;
  final VoidCallback onToggle;

  final bool isPlaying;
  final bool audioReady;
  final VoidCallback onToggleAudio;

  @override
  Widget build(BuildContext context) {
    final isArabic = currentLocale == 'ar';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            height: 35,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.rose,
                width: 1.2,
              ),
              color: AppColors.paper,
              boxShadow: [
                BoxShadow(
                  color: AppColors.crimson.withOpacity(.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LangTab(
                    label: 'EN',
                    active: !isArabic,
                  ),
                  _LangTab(
                    label: 'عربي',
                    active: isArabic,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        _MusicButton(
          isPlaying: isPlaying,
          audioReady: audioReady,
          onTap: onToggleAudio,
        ),
      ],
    );
  }}

class _LangTab extends StatelessWidget {
  const _LangTab({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppColors.crimson : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: active ? Colors.white : AppColors.inkSoft,
        ),
      ),
    );
  }
}
class _MusicButton extends StatelessWidget {
  const _MusicButton({
    required this.isPlaying,
    required this.audioReady,
    required this.onTap,
  });

  final bool isPlaying;
  final bool audioReady;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: audioReady ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlaying
              ? AppColors.crimson.withOpacity(.12)
              : Colors.transparent,
          border: Border.all(
            color: isPlaying
                ? AppColors.crimson
                : AppColors.rose,
          ),
        ),
        child: Center(
          child: audioReady
              ? Icon(
            isPlaying
                ? Icons.music_note
                : Icons.music_off,
            size: 16,
            color: isPlaying
                ? AppColors.crimson
                : AppColors.inkSoft,
          )
              : const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
