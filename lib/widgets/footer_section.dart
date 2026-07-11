import 'package:flutter/material.dart';
import 'package:andrew_diana_wedding/utils/localizations.dart';
import 'package:andrew_diana_wedding/widgets/insta.dart';
import '../theme/app_theme.dart';

class FooterSection extends StatelessWidget {
  final AppLocalizations? loc;

  const FooterSection({super.key, this.loc, });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Andrew & Diana .28 July 2026',
        style: AppText.button.copyWith(color: AppColors.crimson,fontSize:12 )
        ),
        Image.asset(
          "assets/images/1.png",
          height: 120,
          width: 120,
        ),
        MomentoInstagramWidget(loc: loc),
      ],
    );
  }
}