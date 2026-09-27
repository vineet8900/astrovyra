import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/earnings/user_earnings_model.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EarningsDashboardScreen extends StatefulWidget {
  const EarningsDashboardScreen({
    super.key,
    this.initialWalletType,
  });

  final String? initialWalletType;

  @override
  State<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends State<EarningsDashboardScreen> {
  bool _loading = true;
  String? _walletType;
  UserEarningsData? _data;

  @override
  void initState() {
    super.initState();
    _walletType = widget.initialWalletType;
    _load(walletType: _walletType);
  }

  Future<void> _load({String? walletType}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _walletType = walletType;
    });
    final d = await AstroApiService.fetchUserEarnings(walletType: walletType);
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  String _money(num? v) => '₹${(v ?? 0).toDouble().toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final summary = _data?.summary;
    final tx = _data?.transactions ?? const <EarningsTransaction>[];
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'Earnings Dashboard',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: RefreshIndicator(
          onRefresh: () => _load(walletType: _walletType),
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
                Icon(
                  Icons.show_chart_rounded,
                  size: 26,
                  color: Colors.grey.shade900,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earnings Dashboard',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your referral earnings and commissions',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(builder: (context, c) {
              final w = c.maxWidth;
              final columns = w >= 900 ? 3 : (w >= 620 ? 2 : 1);
              final cards = <Widget>[
                _SummaryCard(
                  title: 'Total Earnings',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: CustomStyles.callActionBlue,
                  value: _money(summary?.totalEarnings),
                  subtitle: 'Lifetime earnings (referral + commission)',
                  loading: _loading,
                ),
                _SummaryCard(
                  title: 'Referral Wallet',
                  icon: Icons.redeem_outlined,
                  iconColor: CustomStyles.callActionBlue,
                  value: _money(summary?.referralWallet?.balance),
                  subtitle:
                      'Lifetime: ${_money(summary?.referralWallet?.lifetime)}',
                  loading: _loading,
                ),
                _SummaryCard(
                  title: 'Commission Wallet',
                  icon: Icons.currency_rupee_outlined,
                  iconColor: Colors.green.shade700,
                  value: _money(summary?.commissionWallet?.balance),
                  subtitle:
                      'Lifetime: ${_money(summary?.commissionWallet?.lifetime)}',
                  loading: _loading,
                ),
              ];

              if (columns == 1) {
                return Column(
                  children: [
                    for (var i = 0; i < cards.length; i++) ...[
                      cards[i],
                      if (i != cards.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                );
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.55,
                children: cards,
              );
            }),
            const SizedBox(height: 16),
            _TransactionsCard(
              loading: _loading,
              selectedWalletType: _walletType,
              transactions: tx,
              onSelectAll: () => _load(walletType: null),
              onSelectReferral: () => _load(walletType: 'referral'),
              onSelectCommission: () => _load(walletType: 'commission'),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.subtitle,
    required this.loading,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final String subtitle;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: iconColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

class _TransactionsCard extends StatefulWidget {
  const _TransactionsCard({
    required this.loading,
    required this.selectedWalletType,
    required this.transactions,
    required this.onSelectAll,
    required this.onSelectReferral,
    required this.onSelectCommission,
  });

  final bool loading;
  final String? selectedWalletType;
  final List<EarningsTransaction> transactions;
  final VoidCallback onSelectAll;
  final VoidCallback onSelectReferral;
  final VoidCallback onSelectCommission;

  @override
  State<_TransactionsCard> createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<_TransactionsCard> {
  final ScrollController _h = ScrollController();
  bool _canLeft = false;
  bool _canRight = false;

  @override
  void initState() {
    super.initState();
    _h.addListener(_syncArrows);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncArrows());
  }

  @override
  void dispose() {
    _h.removeListener(_syncArrows);
    _h.dispose();
    super.dispose();
  }

  void _syncArrows() {
    if (!_h.hasClients) return;
    final pos = _h.position;
    final left = pos.pixels > 1;
    final right = pos.pixels < (pos.maxScrollExtent - 1);
    if (left != _canLeft || right != _canRight) {
      setState(() {
        _canLeft = left;
        _canRight = right;
      });
    }
  }

  Future<void> _scrollBy(double dx) async {
    if (!_h.hasClients) return;
    final target = (_h.offset + dx).clamp(0.0, _h.position.maxScrollExtent);
    await _h.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = widget.selectedWalletType == 'referral'
        ? 1
        : widget.selectedWalletType == 'commission'
            ? 2
            : 0;

    Widget body;
    if (widget.loading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 36),
        child: Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 220,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      );
    } else if (widget.transactions.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off, size: 42, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No transactions found.',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              'Transactions will appear here after you receive a referral reward or commission credit.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.35),
            ),
          ],
        ),
      );
    } else {
      body = LayoutBuilder(
        builder: (context, c) {
          final tableW = c.maxWidth < 920 ? 920.0 : c.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                controller: _h,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableW,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      _TableHeader(),
                      const SizedBox(height: 8),
                      ...widget.transactions.map((t) => _TableRowTx(tx: t)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: _canLeft
                            ? Colors.grey.shade800
                            : Colors.grey.shade400,
                      ),
                      onPressed: _canLeft ? () => _scrollBy(-320) : null,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: _canRight
                            ? Colors.grey.shade800
                            : Colors.grey.shade400,
                      ),
                      onPressed: _canRight ? () => _scrollBy(320) : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    }

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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 520;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 18, color: Colors.grey.shade800),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Transactions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: narrow ? 10 : 0),
                    Align(
                      alignment:
                          narrow ? Alignment.centerLeft : Alignment.centerRight,
                      child: _WalletSegmented(
                        selectedIndex: idx,
                        onSelectIndex: (i) {
                          if (i == 0) widget.onSelectAll();
                          if (i == 1) widget.onSelectReferral();
                          if (i == 2) widget.onSelectCommission();
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) => _syncArrows());
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: body,
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Colors.grey.shade600,
      letterSpacing: 0.3,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 190, child: Text('DATE', style: style)),
        Expanded(child: Text('DESCRIPTION', style: style)),
        SizedBox(width: 140, child: Text('WALLET', style: style)),
        SizedBox(width: 120, child: Text('TYPE', style: style)),
        SizedBox(
          width: 140,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('AMOUNT', style: style),
          ),
        ),
      ],
    );
  }
}

class _TableRowTx extends StatelessWidget {
  const _TableRowTx({required this.tx});

  final EarningsTransaction tx;

  String _money(num? v) => '₹${(v ?? 0).toDouble().toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final dateText = (tx.dateDisplay ?? tx.createdAt ?? '').trim();
    final bal = tx.balanceAfter;
    final desc = (tx.description ?? tx.title ?? '').trim();
    final ref = (tx.referenceLine ?? '').trim();
    final wallet = (tx.walletLabel ?? tx.walletType ?? '').trim();
    final type = (tx.typeLabel ?? tx.transactionType ?? '').trim();
    final viewUrl = (tx.viewUrl ?? '').trim();
    final isCredit = type.toLowerCase().contains('credit') ||
        (tx.transactionType ?? '').toLowerCase().contains('credit');
    final color = isCredit ? Colors.green.shade700 : Colors.red.shade700;
    final signed = tx.amountSigned ?? tx.amount;
    final amountText = isCredit ? '+${_money(signed)}' : '-${_money(signed)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (bal != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Balance: ${_money(bal)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                if (ref.isNotEmpty || viewUrl.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        if (ref.isNotEmpty)
                          TextSpan(
                            text: ref,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        if (ref.isNotEmpty && viewUrl.isNotEmpty)
                          TextSpan(
                            text: ' · ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (viewUrl.isNotEmpty)
                          TextSpan(
                            text: 'View',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: CustomStyles.callActionBlue,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.topLeft,
              child: _Pill(text: wallet, color: Colors.green.shade700),
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.topLeft,
              child: _Pill(text: type, color: Colors.green.shade700),
            ),
          ),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                amountText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WalletSegmented extends StatelessWidget {
  const _WalletSegmented({
    required this.selectedIndex,
    required this.onSelectIndex,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  @override
  Widget build(BuildContext context) {
    final selected = List<bool>.generate(3, (i) => i == selectedIndex);
    const baseStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ToggleButtons(
        isSelected: selected,
        onPressed: onSelectIndex,
        borderRadius: BorderRadius.circular(8),
        borderColor: Colors.blue.shade300,
        selectedBorderColor: Colors.blue.shade700,
        fillColor: CustomStyles.callActionBlue,
        selectedColor: Colors.white,
        color: CustomStyles.callActionBlue,
        constraints: const BoxConstraints(minHeight: 34),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('All', style: baseStyle),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Referral Wallet', style: baseStyle),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Commission Wallet', style: baseStyle),
          ),
        ],
      ),
    );
  }
}

