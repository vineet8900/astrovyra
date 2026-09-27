import 'dart:convert';

import 'package:astrokavach/api/newsletter_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/auth/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewsletterScreen extends StatefulWidget {
  const NewsletterScreen({super.key});

  @override
  State<NewsletterScreen> createState() => _NewsletterScreenState();
}

class _NewsletterScreenState extends State<NewsletterScreen> {
  static const String _prefsKeyStatus = 'newsletter_status';
  static const String _prefsKeyLegacy = 'newsletter_subscribed';

  String _email = '';
  int _newsletterStatus = 0;
  bool _loadingPrefs = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('userdata');
    String email = '';
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final decoded = json.decode(userJson);
        if (decoded is Map) {
          email = decoded['email']?.toString().trim() ?? '';
        }
      } catch (_) {}
    }
    int st =
        prefs.getInt(_prefsKeyStatus) ?? _migrateLegacyNewsletterPrefs(prefs);
    if (!mounted) return;
    setState(() {
      _email = email;
      _newsletterStatus = st;
      _loadingPrefs = false;
    });
  }

  int _migrateLegacyNewsletterPrefs(SharedPreferences prefs) {
    final legacy = prefs.getBool(_prefsKeyLegacy);
    if (legacy == null) return 0;
    final v = legacy ? 1 : 0;
    prefs.setInt(_prefsKeyStatus, v);
    return v;
  }

  Future<void> _submit() async {
    if (_email.isEmpty) return;
    setState(() => _actionLoading = true);
    final res = await NewsletterApi.postEmail(_email);
    if (!mounted) return;
    if (res == null) {
      setState(() => _actionLoading = false);
      Fluttertoast.showToast(msg: 'Something went wrong. Try again.');
      return;
    }
    if (!res.requestOk) {
      setState(() => _actionLoading = false);
      Fluttertoast.showToast(
        msg: res.message.isNotEmpty ? res.message : 'Request failed.',
      );
      return;
    }
    setState(() {
      _actionLoading = false;
      _newsletterStatus = res.newsletterStatus;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyStatus, _newsletterStatus);
  }

  bool get _hasValidEmail => _email.isNotEmpty && _email.contains('@');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'Newsletter',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: _hasValidEmail ? _buildContent() : _buildNoEmail(),
              ),
            ),
    );
  }

  Widget _buildNoEmail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_unread_outlined,
            size: 64, color: Colors.grey.shade400),
        const SizedBox(height: 24),
        Text(
          'Please update your profile first',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Add a valid email address in My Profile to subscribe to the newsletter.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: CustomStyles.ctaColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            ).then((_) => _load());
          },
          child: const Text(
            'Go to My Profile',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final navy = CustomStyles.ctaColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_newsletterStatus == 1) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFD4EDDA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFC3E6CB)),
            ),
            child: Text(
              'Successfully Subscribed!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF155724),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Subscribe to our newsletter',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.grey.shade900,
            letterSpacing: -0.3,
          ),
        ),
        if (_newsletterStatus == 1) ...[
          const SizedBox(height: 12),
          Text(
            'You have Subscribed Successfully.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
              height: 1.45,
            ),
          ),
        ],
        SizedBox(height: _newsletterStatus == 1 ? 20 : 16),
        Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _actionLoading ? null : _submit,
            child: _actionLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _newsletterStatus == 1 ? 'Unsubscribe' : 'Subscribe',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
        ),
      ],
    );
  }
}
