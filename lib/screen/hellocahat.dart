// GlobalChatService.dart
import 'package:astrokavach/model/AIastrologermodel/aiastrologer.dart';
import 'package:astrokavach/screen/aichatscreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class GlobalChatService {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;
  static AiAstrologer? _currentAstrologer;
  static BuildContext? _context;
  static Timer? _hideTimer;

  static int? _joinedConsultationId;

  static void showFloatingChatButton(BuildContext context,
      {AiAstrologer? astrologer}) {
    _context = context;

    if (astrologer != null) {
      _currentAstrologer = astrologer;
    }

    final currentConsultationId = _currentAstrologer?.consultation?.id ?? 0;
    final hasActiveChat = currentConsultationId != 0;
    if (!hasActiveChat || currentConsultationId == _joinedConsultationId) {
      hideFloatingChatButton();
      return;
    }

    _hideTimer?.cancel();

    if (!_isShowing) {
      _createOverlay(context);
      _isShowing = true;
    }

    _hideTimer = Timer(const Duration(seconds: 15), () {
      hideFloatingChatButton();
    });
  }

  static void _handleChatButtonTap() {
    if (_currentAstrologer == null || _context == null) return;

    if (_currentAstrologer!.consultation != null) {
      _joinedConsultationId = _currentAstrologer!.consultation!.id;
    }

    hideFloatingChatButton();

    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => KundliAIChatScreen(
          consultationId: _currentAstrologer!.consultation!.id,
          astrologerName: _currentAstrologer!.name,
        ),
      ),
    );
  }

  static void resetJoinedState() {
    _joinedConsultationId = null;
  }

  static void _createOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildFloatingButton(),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  static Widget _buildFloatingButton() {
    final buttonText = "Join Chat";
    final buttonColor = Colors.green;

    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _handleChatButtonTap(),
          child: Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [buttonColor, buttonColor.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(_currentAstrologer!.image),
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentAstrologer!.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.forum,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _updateOverlay() {
    if (_overlayEntry != null && _isShowing) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  static void hideFloatingChatButton() {
    _hideTimer?.cancel();
    _hideTimer = null;

    if (_overlayEntry != null && _isShowing) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  static void dispose() {
    hideFloatingChatButton();
    _currentAstrologer = null;
    _context = null;
    _joinedConsultationId = null; // dispose mein bhi reset kar dein
  }
}
