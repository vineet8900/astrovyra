import 'package:astrokavach/api/dashboard/user_consultation_api.dart';
import 'package:astrokavach/api/dashboard/user_wallet_history_api.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/orderdetail.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AddressModel/ordermodel.dart';
import 'package:astrokavach/model/supportlistmodel/supportlistmodel.dart';
import 'package:astrokavach/model/user_dashboard_model/user_consultation_model.dart';
import 'package:astrokavach/model/user_dashboard_model/user_wallet_history_model.dart';
import 'package:astrokavach/screen/supportscreen.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_consulting_screen.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_wallet_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astrokavach/custom_widgets/orderscreen.dart';

class _DashboardScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _DashboardSnapshot {
  final List<UserOrder>? orders;
  final List<UserConsultingList> consultations;
  final List<WalletHistoryList> wallet;
  final List<SupportTicket> support;

  _DashboardSnapshot({
    required this.orders,
    required this.consultations,
    required this.wallet,
    required this.support,
  });
}

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final ReusableFunction _reusableFunction = ReusableFunction();
  late Future<_DashboardSnapshot> _dashboardFuture;
  String? _apiToken;
  VoidCallback? _refreshAfterLoginListener;

  static const Color _primaryBlue = Color(0xFF004080);
  static const Color _amountGreen = Color(0xFF28A745);
  static const Color _badgeYellow = Color(0xFFFFC107);
  static const Color _cyanBadge = Color(0xFF00BCD4);
  static const Color _walletGreen = Color(0xFF2E7D32);
  static const Color _consultPurple = Color(0xFF7B1FA2);
  static const Color _supportGold = Color(0xFFE6A000);
  static const Color _walletBadgeBlue = Color(0xFF1976D2);
  static const Color _screenBg = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
    _loadToken();
    _refreshAfterLoginListener = () {
      _loadToken();
      setState(() {
        _dashboardFuture = _loadDashboard();
      });
    };
    refreshHomeAfterLoginNotifier.addListener(_refreshAfterLoginListener!);
  }

  @override
  void dispose() {
    if (_refreshAfterLoginListener != null) {
      refreshHomeAfterLoginNotifier.removeListener(_refreshAfterLoginListener!);
    }
    super.dispose();
  }

  Future<void> _loadToken() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _apiToken = p.getString('api_token'));
  }

  Future<_DashboardSnapshot> _loadDashboard() async {
    final orders = await AstroApiService.fetchUserOrders();
    var consult = <UserConsultingList>[];
    var wallet = <WalletHistoryList>[];
    var support = <SupportTicket>[];
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');
      if (token != null && token.length > 12) {
        final c = await UserConsultingApiService()
            .getuserconsultingapidata(token, 'chat');
        consult = c?.data?.list ?? [];
        final w = await WalletHistoryApiService()
            .fetchwallethistryapidata(null, token, 1);
        wallet = w?.data?.list ?? [];
        final t = await AstroApiService.fetchSupportTickets();
        support = t ?? [];
      }
    } catch (_) {}
    return _DashboardSnapshot(
      orders: orders,
      consultations: consult,
      wallet: wallet,
      support: support,
    );
  }

  Future<void> _refreshAll() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  void _navLoggedIn(BuildContext context, Widget screen) {
    _reusableFunction.navigateIfNotLoggedIn(context, screen, _apiToken, null);
  }

  String _categoryLabel(UserOrder o) {
    final slug = (o.item?.slug ?? '').toLowerCase();
    final name = (o.item?.name ?? '').toLowerCase();
    final s = '$slug $name';
    if (s.contains('pooja')) return 'Pooja';
    if (s.contains('service')) return 'Service';
    return 'Product';
  }

  String _modeLabel(String? action) {
    if (action == null || action.isEmpty) return '—';
    final a = action.toLowerCase();
    if (a.contains('chat')) return 'Chat';
    if (a.contains('video')) return 'Video';
    if (a.contains('call')) return 'Call';
    return action;
  }

  String _walletAmountLine(WalletHistoryList w) {
    if (w.debit != null && w.debit! > 0) {
      return '- ₹${w.debit!.toStringAsFixed(2)}';
    }
    if (w.credit != null && w.credit! > 0) {
      return '+ ₹${w.credit}';
    }
    return '₹0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'Dashboard',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: ColoredBox(
        color: _screenBg,
        child: SafeArea(
          child: ScrollConfiguration(
            behavior: _DashboardScrollBehavior(),
            child: FutureBuilder<_DashboardSnapshot>(
              future: _dashboardFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Something went wrong. Pull to retry.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }
                final data = snap.data;
                return RefreshIndicator(
                  onRefresh: _refreshAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.78,
                              children: [
                                _actionCard(
                                  label: 'Order',
                                  imageAsset: 'assets/newcheckout.png',
                                  circleColor: _primaryBlue,
                                  onTap: () => _navLoggedIn(
                                      context, const Orderscreen()),
                                ),
                                _actionCard(
                                  label: 'Wallet History',
                                  imageAsset: 'assets/newredeem.png',
                                  circleColor: _walletGreen,
                                  onTap: () => _navLoggedIn(
                                    context,
                                    const WalletHistoryScreen(),
                                  ),
                                ),
                                _actionCard(
                                  label: 'Consultation',
                                  imageAsset: 'assets/newtalk.png',
                                  circleColor: _consultPurple,
                                  onTap: () => _navLoggedIn(
                                    context,
                                    UserConsultingListScreen(),
                                  ),
                                ),
                                _actionCard(
                                  circleColor: _supportGold,
                                  icon: Icons.headset_mic,
                                  label: 'Support',
                                  onTap: () => _navLoggedIn(
                                      context, const SupportScreen()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _ordersSection(context, data),
                        const SizedBox(height: 18),
                        _consultationSection(context, data),
                        const SizedBox(height: 18),
                        _walletSection(context, data),
                        const SizedBox(height: 18),
                        _supportSection(context, data),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _ordersSection(BuildContext context, _DashboardSnapshot? data) {
    return _sectionShell(
      title: 'Orders',
      child: data == null
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('Loading…')),
            )
          : _ordersBody(context, data),
    );
  }

  Widget _ordersBody(BuildContext context, _DashboardSnapshot data) {
    final list = data.orders;
    if (list == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Could not load orders.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            "You haven't placed any orders yet.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    final preview = list.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _orderPreviewCard(context, preview[i], i + 1),
        ],
        const SizedBox(height: 14),
        _viewAllButton(
          onPressed: () => _navLoggedIn(context, const Orderscreen()),
        ),
      ],
    );
  }

  Widget _consultationSection(BuildContext context, _DashboardSnapshot? data) {
    return _sectionShell(
      title: 'Consultation',
      child: data == null
          ? const SizedBox.shrink()
          : _consultGridBody(context, data),
    );
  }

  Widget _consultGridBody(BuildContext context, _DashboardSnapshot data) {
    final list = data.consultations.take(5).toList();
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'No consultations yet.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < list.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _consultationPreviewCard(list[i], i + 1),
        ],
        const SizedBox(height: 14),
        _viewAllButton(
          onPressed: () => _navLoggedIn(context, UserConsultingListScreen()),
        ),
      ],
    );
  }

  Widget _walletSection(BuildContext context, _DashboardSnapshot? data) {
    return _sectionShell(
      title: 'Wallet History',
      child: data == null
          ? const SizedBox.shrink()
          : _walletGridBody(context, data),
    );
  }

  Widget _walletGridBody(BuildContext context, _DashboardSnapshot data) {
    final list = data.wallet.take(5).toList();
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'No wallet transactions yet.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < list.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _walletPreviewCard(list[i], i + 1),
        ],
        const SizedBox(height: 14),
        _viewAllButton(
          onPressed: () => _navLoggedIn(context, const WalletHistoryScreen()),
        ),
      ],
    );
  }

  Widget _supportSection(BuildContext context, _DashboardSnapshot? data) {
    return _sectionShell(
      title: 'Support Tickets',
      child: data == null
          ? const SizedBox.shrink()
          : _supportGridBody(context, data),
    );
  }

  Widget _supportGridBody(BuildContext context, _DashboardSnapshot data) {
    final list = data.support.take(5).toList();
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            'No support tickets yet.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < list.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _supportPreviewCard(list[i], i + 1),
        ],
        const SizedBox(height: 14),
        _viewAllButton(
          onPressed: () => _navLoggedIn(context, const SupportScreen()),
        ),
      ],
    );
  }

  Widget _sectionShell({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _viewAllButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          'View All',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
    );
  }

  Widget _actionCard({
    required String label,
    required VoidCallback onTap,
    required Color circleColor,
    String? imageAsset,
    IconData? icon,
  }) {
    assert(imageAsset != null || icon != null);

    final Widget leading = imageAsset != null
        ? CircleAvatar(
            radius: 34,
            backgroundColor: circleColor,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image_outlined,
                    size: 30,
                    color: Colors.white70,
                  );
                },
              ),
            ),
          )
        : CircleAvatar(
            radius: 34,
            backgroundColor: circleColor,
            child: Icon(icon!, color: Colors.white, size: 30),
          );

    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderPreviewCard(
    BuildContext context,
    UserOrder order,
    int indexLabel,
  ) {
    final cat = _categoryLabel(order);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          if (order.item != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailScreen(
                  orderId: order.orderId,
                  itemId: order.item!.itemId,
                  parentId: order.item!.parentId,
                  shipping: order.showShippingAddress,
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _cyanBadge,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#$indexLabel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _badgeYellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$cat  ${order.date}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description_outlined,
                      size: 17, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Order ID',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      order.orderNumber,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 18, thickness: 0.7),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.currency_rupee,
                      size: 14, color: Colors.grey.shade700),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '₹ ${order.totalPrice}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _amountGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consultationPreviewCard(UserConsultingList c, int indexLabel) {
    final mode = _modeLabel(c.action?.toString());
    final modeColor =
        mode.toLowerCase() == 'chat' ? _primaryBlue : const Color(0xFF212121);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _cyanBadge,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$indexLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  c.date ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person_outline, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Astrologer',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  c.name ?? '—',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.videocam_outlined,
                  size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Mode',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  mode,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: modeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(height: 14, thickness: 0.7),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.currency_rupee,
                  size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  '₹ ${c.amount ?? c.charges ?? '0'}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _amountGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletPreviewCard(WalletHistoryList w, int indexLabel) {
    final remark = (w.package ?? w.mode ?? '').trim();
    final amountStr = _walletAmountLine(w);
    final isDebit = w.debit != null && w.debit! > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _walletBadgeBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$indexLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  w.dateTime ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Remark',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  remark.isEmpty ? '—' : remark,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.currency_rupee, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Amount',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  amountStr,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDebit ? Colors.red.shade700 : _amountGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _supportPreviewCard(SupportTicket t, int indexLabel) {
    final open = t.status.toLowerCase() == 'open';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _walletBadgeBlue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#$indexLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  t.createdAt,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Subject',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  t.subject,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                ),
              ),
              Flexible(
                child: Text(
                  t.status,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: open ? _amountGreen : Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
