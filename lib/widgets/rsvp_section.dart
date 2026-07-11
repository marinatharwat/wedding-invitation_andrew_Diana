import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:andrew_diana_wedding/utils/localizations.dart';
import '../theme/app_theme.dart';

enum AttendingStatus { yes, no }

class RsvpSection extends StatefulWidget {
  const RsvpSection({
    super.key,
    required this.deviceType,
    required this.loc,
  });

  final DeviceType deviceType;
  final AppLocalizations loc;

  @override
  State<RsvpSection> createState() => _RsvpSectionState();
}

class _RsvpSectionState extends State<RsvpSection> {
  // 🔗 رابط الـ Google Apps Script Web App
  static const _scriptUrl =
      'https://script.google.com/macros/s/AKfycbwEwq2XBOSGynBLVZHz7dgcclP5J9OFWblY8wyeHvxJwS304mxAHCysKlAaW6qdMZw/exec';

  static const _cream = Color(0xFFFBF3EC);
  static const _crimson = Color(0xFFD62839);
  static const _crimsonDark = Color(0xFFB81F30);
  static const _border = Color(0xFFE85D6B);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  AttendingStatus? _attending;
  bool _submitted = false;
  bool _loading = false;
  String? _errorMessage;

  // only the name is required — attendance and message are optional
  bool get _canSubmit => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(_scriptUrl).replace(queryParameters: {
        'name': _nameController.text.trim(),
        'attending': _attending == null
            ? ''
            : (_attending == AttendingStatus.yes ? 'yes' : 'no'),
        'message': _messageController.text.trim(),
      });

      await http.get(uri);

      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'حصل خطأ، حاول تاني');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = widget.deviceType == DeviceType.desktop;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _submitted ? _buildThanks(isDesktop) : _buildForm(isDesktop),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDesktop) {
    // half of the seal sits above the card's top border, half inside it
    final double sealSize = isDesktop ? 190 : 150;

    return Column(
      children: [
        // title made smaller so "أرسلوا لنا رسالة" fits comfortably
        // without wrapping into a big, heavy line
        Text(
          widget.loc.guestMessageTitleLine1,
          textAlign: TextAlign.center,
          style: GoogleFonts.greatVibes(
            fontSize: isDesktop ? 36 : 30,
            color: _crimson,
          ),
        ),
        Text(
          widget.loc.guestMessageTitleLine2,
          textAlign: TextAlign.center,
          style: GoogleFonts.greatVibes(
            fontSize: isDesktop ? 36 : 30,
            color: _crimson,
          ),
        ),

        const SizedBox(height: 6),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: sealSize / 2),
              padding: EdgeInsets.fromLTRB(22, sealSize / 2 + 18, 22, 22),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.001),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _border, width: 1.6),
              ),
              child: Column(
                children: [
                  Text(
                    widget.loc.guestAttendingQuestion,
                    style: GoogleFonts.jost(
                      fontSize: 13,
                      letterSpacing: .5,
                      color: _crimsonDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _AttendingChip(
                          label: widget.loc.guestAttendingYes,
                          selected: _attending == AttendingStatus.yes,
                          onTap: () =>
                              setState(() => _attending = AttendingStatus.yes),
                          crimson: _crimson,
                          border: _border,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AttendingChip(
                          label: widget.loc.guestAttendingNo,
                          selected: _attending == AttendingStatus.no,
                          onTap: () =>
                              setState(() => _attending = AttendingStatus.no),
                          crimson: _crimson,
                          border: _border,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  /// NAME FIELD (required)
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.jost(fontSize: 15, color: _crimsonDark),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "${widget.loc.guestMessageNameHint} *",
                      hintStyle: GoogleFonts.jost(
                        fontSize: 14,
                        color: _crimson.withOpacity(.45),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _border, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: _crimson, width: 1.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// MESSAGE FIELD (optional)
                  SizedBox(
                    height: 180,
                    child: TextField(
                      controller: _messageController,
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: GoogleFonts.jost(fontSize: 14, color: _crimsonDark),
                      decoration: InputDecoration(
                        hintText: widget.loc.guestMessageHint,
                        hintStyle: GoogleFonts.jost(
                          fontSize: 14,
                          color: _crimson.withOpacity(.4),
                        ),
                        contentPadding: const EdgeInsets.all(18),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _border, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: _crimson, width: 1.8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: _canSubmit ? _crimson : _border.withOpacity(.5),
                      ),
                      child: ElevatedButton(
                        onPressed: (!_canSubmit || _loading) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          widget.loc.guestMessageSendButton,
                          style: GoogleFonts.jost(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jost(
                        fontSize: 12,
                        color: _crimson,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: sealSize,
              height: sealSize,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cream,
                border: Border.all(color: _crimson, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _crimson.withOpacity(.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/1.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThanks(bool isDesktop) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: .8, end: 1.1),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (_, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: isDesktop ? 190 : 160,
            height: isDesktop ? 190 : 160,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _cream,
              border: Border.all(color: _crimson, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _crimson.withOpacity(.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                "assets/images/1.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          widget.loc.guestMessageThankYouTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.greatVibes(
            fontSize: 32,
            color: _crimson,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.loc.guestMessageThankYouBody(_nameController.text),
          textAlign: TextAlign.center,
          style: GoogleFonts.jost(
            fontSize: 14,
            height: 1.6,
            color: _crimsonDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.loc.guestMessageThankYouFooter,
          textAlign: TextAlign.center,
          style: GoogleFonts.jost(
            fontSize: 20,
            color: _crimson,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ATTENDING CHIP — optional yes/no pill button
// ─────────────────────────────────────────────

class _AttendingChip extends StatelessWidget {
  const _AttendingChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.crimson,
    required this.border,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color crimson;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        width: double.infinity,
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? crimson : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? crimson : border,
            width: 1.3,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jost(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : crimson,
          ),
        ),
      ),
    );
  }
}