import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/earnings/app_referrals_model.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class AppReferralsScreen extends StatefulWidget {
  const AppReferralsScreen({super.key});

  @override
  State<AppReferralsScreen> createState() => _AppReferralsScreenState();
}

class _AppReferralsScreenState extends State<AppReferralsScreen> {
  bool _loading = true;
  AppReferralsData? _data;

  String? _status;
  String? _rewardTrigger;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final d = await AstroApiService.fetchUserAppReferrals(
      status: _status,
      rewardTrigger: _rewardTrigger,
    );
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  void _reset() {
    setState(() {
      _status = null;
      _rewardTrigger = null;
    });
    _load();
  }

  Future<void> _shareReferral() async {
    final d = await AstroApiService.fetchReferEarn();
    final link = d?.referralLink.isNotEmpty == true
        ? d!.referralLink
        : '${CustomStyles.webBaseUrl}/user/register?ref=${d?.referCode ?? ''}';
    await Share.share(link);
  }

  @override
  Widget build(BuildContext context) {
    final stats = _data?.stats;
    final referrals = _data?.referrals ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'App Referrals',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 26, color: Colors.grey.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App Referrals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Users who signed up using your referral code',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth;
                if (w >= 720) {
                  return Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: '${stats?.total ?? 0}',
                          label: 'Total Referrals',
                          color: CustomStyles.callActionBlue,
                          loading: _loading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${stats?.credited ?? 0}',
                          label: 'Credited',
                          color: Colors.green.shade700,
                          loading: _loading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: '${stats?.pending ?? 0}',
                          label: 'Pending',
                          color: Colors.amber.shade800,
                          loading: _loading,
                        ),
                      ),
                    ],
                  );
                }
                final raw = (w - 12) / 2;
                final half = raw.isFinite ? raw.clamp(140.0, w) : w;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: half,
                      child: _StatCard(
                        value: '${stats?.total ?? 0}',
                        label: 'Total Referrals',
                        color: CustomStyles.callActionBlue,
                        loading: _loading,
                      ),
                    ),
                    SizedBox(
                      width: half,
                      child: _StatCard(
                        value: '${stats?.credited ?? 0}',
                        label: 'Credited',
                        color: Colors.green.shade700,
                        loading: _loading,
                      ),
                    ),
                    SizedBox(
                      width: w,
                      child: _StatCard(
                        value: '${stats?.pending ?? 0}',
                        label: 'Pending',
                        color: Colors.amber.shade800,
                        loading: _loading,
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 14),
              _FilterCard(
                loading: _loading,
                status: _status,
                rewardTrigger: _rewardTrigger,
                onStatus: (v) => setState(() => _status = v),
                onTrigger: (v) => setState(() => _rewardTrigger = v),
                onApply: _load,
                onReset: _reset,
              ),
              const SizedBox(height: 14),
              _ReferralsListCard(
                loading: _loading,
                referrals: referrals,
                onShare: _shareReferral,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.loading,
  });

  final String value;
  final String label;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: 96,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (!loading) return card;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: card,
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.loading,
    required this.status,
    required this.rewardTrigger,
    required this.onStatus,
    required this.onTrigger,
    required this.onApply,
    required this.onReset,
  });

  final bool loading;
  final String? status;
  final String? rewardTrigger;
  final ValueChanged<String?> onStatus;
  final ValueChanged<String?> onTrigger;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final half = ((w - 12) / 2).clamp(140.0, w);
          final wide = w >= 720;

          final statusField = _Labeled(
            label: 'Status',
            child: DropdownButtonFormField<String?>(
              key: ValueKey<String?>('st_$status'),
              initialValue: status,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              hint: const Text('All Status'),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Status'),
                ),
                DropdownMenuItem<String?>(
                  value: 'credited',
                  child: Text('Credited'),
                ),
                DropdownMenuItem<String?>(
                  value: 'pending',
                  child: Text('Pending'),
                ),
              ],
              onChanged: loading ? null : onStatus,
            ),
          );

          final triggerField = _Labeled(
            label: 'Trigger',
            child: DropdownButtonFormField<String?>(
              key: ValueKey<String?>('tr_$rewardTrigger'),
              initialValue: rewardTrigger,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              hint: const Text('All Triggers'),
              items: const [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Triggers'),
                ),
                DropdownMenuItem<String?>(
                  value: 'signup',
                  child: Text('Signup'),
                ),
                DropdownMenuItem<String?>(
                  value: 'first_purchase',
                  child: Text('First purchase'),
                ),
              ],
              onChanged: loading ? null : onTrigger,
            ),
          );

          final applyBtn = SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3C2E8F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          );

          final resetBtn = Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: loading ? null : onReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C2E8F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: statusField),
                    const SizedBox(width: 12),
                    Expanded(child: triggerField),
                  ],
                ),
                const SizedBox(height: 12),
                applyBtn,
                const SizedBox(height: 12),
                resetBtn,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(width: half, child: statusField),
                  const SizedBox(width: 12),
                  SizedBox(width: half, child: triggerField),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : onApply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3C2E8F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              resetBtn,
            ],
          );
        },
      ),
    );
  }
}

class _Labeled extends StatelessWidget {
  const _Labeled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _ReferralsListCard extends StatelessWidget {
  const _ReferralsListCard({
    required this.loading,
    required this.referrals,
    required this.onShare,
  });

  final bool loading;
  final List<Map<String, dynamic>> referrals;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Text(
              'Referrals List',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade900,
              ),
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else if (referrals.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                children: [
                  Icon(Icons.people_outline,
                      size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No referrals found.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: onShare,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C2E8F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text(
                      'Share Your Referral Code',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: referrals.map((r) {
                  final name = (r['name'] ?? r['user_name'] ?? r['email'] ?? '')
                      .toString();
                  final st = (r['status'] ?? '').toString();
                  final trig = (r['reward_trigger'] ?? r['trigger'] ?? '')
                      .toString();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (name.isNotEmpty)
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        if (st.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Status: $st',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (trig.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Trigger: $trig',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
