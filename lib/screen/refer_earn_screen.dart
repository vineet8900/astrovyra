import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/refer_earn_model/refer_earn_model.dart';
import 'package:astrokavach/screen/earnings_dashboard_screen.dart';
import 'package:astrokavach/screen/referral_rules_screen.dart';
import 'package:astrokavach/screen/product_commissions_screen.dart';
import 'package:astrokavach/screen/app_referrals_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  bool _loading = true;
  String? _error;
  ReferEarnData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      if (_data == null) _loading = true;
      _error = null;
    });
    final d = await AstroApiService.fetchReferEarn();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (d != null) {
        _data = d;
        _error = null;
      } else if (_data == null) {
        _error = 'Unable to load.';
      }
    });
  }

  String _money(num v) {
    return '₹${v.toDouble().toStringAsFixed(2)}';
  }

  String get _refCode => _data?.referCode.isNotEmpty == true ? _data!.referCode : 'N/A';

  String get _refLink {
    if (_data?.referralLink.isNotEmpty == true) return _data!.referralLink;
    if (_data?.referCode.isNotEmpty == true) {
      return '${CustomStyles.webBaseUrl}/user/register?ref=${_data!.referCode}';
    }
    return '${CustomStyles.webBaseUrl}/user/register?ref=';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'Refer & Earn',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        child: _loading && _data == null
            ? _ReferEarnLoadingShimmer()
            : _error != null && _data == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _load,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_loading && _data != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          _topCard(context),
                          const SizedBox(height: 16),
                          _statsCard(),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _topCard(BuildContext context) {
    final blue = CustomStyles.callActionBlue;
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.card_giftcard_rounded, color: blue, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Refer & Earn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your referral earnings and open detailed reports.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 520;
                final codeBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Referral Code',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _refCode,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _refCode));
                          Fluttertoast.showToast(msg: 'Code copied');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text(
                          'Copy Code',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                );
                final linkBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Referral Link',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              _refLink,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _refLink));
                            Fluttertoast.showToast(msg: 'Link copied');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: blue,
                            side: BorderSide(color: blue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.link, size: 16, color: blue),
                              const SizedBox(width: 4),
                              Text(
                                'Copy Link',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: blue,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      codeBlock,
                      const SizedBox(height: 20),
                      linkBlock,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: codeBlock),
                    const SizedBox(width: 20),
                    Expanded(child: linkBlock),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Text(
              'Share',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _shareBtn(
                    color: const Color(0xFF25D366),
                    icon: FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 20,
                    ),
                    onTap: () => _openShare(
                      'https://wa.me/?text=${Uri.encodeComponent(_refLink)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _shareBtn(
                    color: const Color(0xFF1877F2),
                    icon: FaIcon(
                      FontAwesomeIcons.facebookF,
                      color: Colors.white,
                      size: 18,
                    ),
                    onTap: () => _openShare(
                      'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(_refLink)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _shareBtn(
                    color: const Color(0xFF1DA1F2),
                    icon: FaIcon(
                      FontAwesomeIcons.twitter,
                      color: Colors.white,
                      size: 18,
                    ),
                    onTap: () => _openShare(
                      'https://twitter.com/intent/tweet?url=${Uri.encodeComponent(_refLink)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _shareBtn(
                    color: const Color(0xFFE53935),
                    icon: const Icon(Icons.email_rounded,
                        color: Colors.white, size: 20),
                    onTap: () async {
                      final uri = Uri.parse(
                        'mailto:?body=${Uri.encodeComponent(_refLink)}',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        await Share.share(_refLink);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Your friends can use this link to sign up. Rewards are credited based on program rules.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openShare(String url) async {
    final u = Uri.parse(url);
    if (await canLaunchUrl(u)) {
      await launchUrl(u, mode: LaunchMode.externalApplication);
    }
  }

  Widget _shareBtn({
    required Color color,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 44,
          child: Center(child: icon),
        ),
      ),
    );
  }

  Widget _statsCard() {
    final blue = CustomStyles.callActionBlue;
    const green = Color(0xFF2E7D32);
    final d = _data;
    final lifetimeSum = d != null
        ? d.referralWalletLifetime + d.commissionWalletLifetime
        : 0;
    final ar = d?.activeReferrals;
    final pc = d?.productCommission;
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.05,
          children: [
            _statTile(
              label: 'Earnings',
              value: _money(d?.earnings ?? 0),
              valueColor: green,
              sub: 'Lifetime: ${_money(lifetimeSum)}',
              trailing: _blueIconBox(
                blue,
                Icons.show_chart_rounded,
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EarningsDashboardScreen(),
                  ),
                );
              },
            ),
            _statTile(
              label: 'Referral Wallet',
              value: _money(d?.referralWallet ?? 0),
              valueColor: green,
              sub: 'Lifetime: ${_money(d?.referralWalletLifetime ?? 0)}',
              trailing: _blueIconBox(
                blue,
                Icons.card_giftcard_rounded,
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EarningsDashboardScreen(
                      initialWalletType: 'referral',
                    ),
                  ),
                );
              },
            ),
            _statTile(
              label: 'Commission Wallet',
              value: _money(d?.commissionWallet ?? 0),
              valueColor: green,
              sub: 'Lifetime: ${_money(d?.commissionWalletLifetime ?? 0)}',
              trailing: _blueIconBox(
                blue,
                Icons.account_balance_wallet_outlined,
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const EarningsDashboardScreen(
                      initialWalletType: 'commission',
                    ),
                  ),
                );
              },
            ),
            _statTile(
              label: 'Active Referrals',
              value: '${ar?.creditedCount ?? 0} credited',
              valueColor: Colors.grey.shade900,
              sub:
                  'Earned: ${_money(ar?.earnedAmount ?? 0)} · Pending: ${ar?.pendingCount ?? 0}',
              trailing: _blueIconBox(
                blue,
                Icons.person_add_alt_1_rounded,
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AppReferralsScreen(),
                  ),
                );
              },
            ),
            _statTile(
              label: 'Product Commissions',
              value: _money(pc?.creditedAmount ?? 0),
              valueColor: Colors.grey.shade900,
              sub:
                  'Orders: ${pc?.orders ?? 0} · Pending: ${_money(pc?.pendingAmount ?? 0)}',
              trailing: _blueIconBox(
                blue,
                Icons.payments_outlined,
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ProductCommissionsScreen(),
                  ),
                );
              },
            ),
            _statTile(
              label: 'Referral Rules',
              value: 'Read',
              valueColor: Colors.grey.shade900,
              sub: 'Eligibility, limits & expiry',
              trailing: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              onTap: () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const ReferralRulesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _blueIconBox(Color blue, IconData data) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(data, color: Colors.white, size: 18),
    );
  }

  Widget _statTile({
    required String label,
    required String value,
    required Color valueColor,
    required String sub,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing,
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferEarnLoadingShimmer extends StatelessWidget {
  const _ReferEarnLoadingShimmer();

  static BoxDecoration _bone({double radius = 4}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: _bone(radius: 8),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 20,
                                width: 140,
                                decoration: _bone(),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: _bone(),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 12,
                                width: 200,
                                decoration: _bone(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 12,
                      width: 110,
                      decoration: _bone(),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 26,
                      width: 140,
                      decoration: _bone(),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 44,
                      width: double.infinity,
                      decoration: _bone(radius: 8),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: _bone(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: _bone(radius: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 88,
                          height: 48,
                          child: DecoratedBox(
                            decoration: _bone(radius: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 14,
                      width: 48,
                      decoration: _bone(),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: _bone(radius: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: _bone(radius: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: _bone(radius: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            height: 44,
                            decoration: _bone(radius: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: _bone(),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 260,
                      decoration: _bone(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              elevation: 2,
              shadowColor: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: List.generate(
                    6,
                    (_) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 11,
                                  decoration: _bone(),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: _bone(radius: 6),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 14,
                            width: 72,
                            decoration: _bone(),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 9,
                            width: double.infinity,
                            decoration: _bone(),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 9,
                            width: 100,
                            decoration: _bone(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
