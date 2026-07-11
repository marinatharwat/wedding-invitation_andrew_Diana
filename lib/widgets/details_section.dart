import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:andrew_diana_wedding/utils/localizations.dart';
import '../theme/app_theme.dart';

class DetailsSection extends StatelessWidget {
  const DetailsSection({
    super.key,
    required this.deviceType,
    required this.loc,
  });

  final DeviceType deviceType;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final isDesktop = deviceType == DeviceType.desktop;
    final isTablet = deviceType == DeviceType.tablet;

    final items = [
      (
      icon: Icons.calendar_today_outlined,
      text: loc.detailsDateText,
      ),
      (
      icon: Icons.access_time,
      text: loc.detailsTimeText,
      ),
    ];

    final rows = items
        .map((item) => _DetailRow(
      icon: item.icon,
      text: item.text,
    ))
        .toList();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 860 : (isTablet ? 600 : double.infinity),
        ),
        child: Column(
          children: [
            Text(
              loc.detailsTitle,
              style: GoogleFonts.caveat(
                fontSize: deviceType == DeviceType.desktop ? 60 : 40,
                color: AppColors.crimson,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 22),
            isDesktop
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows
                  .map(
                    (r) => Expanded(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                    child: r,
                  ),
                ),
              )
                  .toList(),
            )
                : Column(
                children: rows),
          ],
        ),
      ),
    );
  }
}
class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: AppColors.crimson),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: AppText.copy(13.5),
            ),
          ),
        ),
      ],
    );
  }
}