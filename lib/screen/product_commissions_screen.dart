import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/earnings/user_commissions_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProductCommissionsScreen extends StatefulWidget {
  const ProductCommissionsScreen({super.key});

  @override
  State<ProductCommissionsScreen> createState() =>
      _ProductCommissionsScreenState();
}

class _ProductCommissionsScreenState extends State<ProductCommissionsScreen> {
  bool _loading = true;
  UserCommissionsData? _data;

  int? _categoryId;
  String? _status;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _money(num? v) => '₹${(v ?? 0).toDouble().toStringAsFixed(2)}';

  String? _fmtDate(DateTime? d) {
    if (d == null) return null;
    return DateFormat('dd-MM-yyyy').format(d);
  }

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() => _dateFrom = picked);
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
    );
    if (picked == null) return;
    setState(() => _dateTo = picked);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final d = await AstroApiService.fetchUserCommissions(
      categoryId: _categoryId,
      status: _status,
      dateFrom: _fmtDate(_dateFrom),
      dateTo: _fmtDate(_dateTo),
    );
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _data?.stats;
    final categories = _data?.categories ?? const <CommissionCategory>[];
    final items = _data?.commissions ?? const <CommissionItem>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'Product Commissions',
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
              Text(
                'Commissions earned from product purchases',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth;
                if (w >= 980) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.8,
                    children: [
                      _MiniStatCard(
                        value: _money(stats?.total),
                        label: 'Total Commissions',
                        color: Colors.green.shade800,
                        loading: _loading,
                      ),
                      _MiniStatCard(
                        value: _money(stats?.credited),
                        label: 'Credited',
                        color: CustomStyles.callActionBlue,
                        loading: _loading,
                      ),
                      _MiniStatCard(
                        value: _money(stats?.pending),
                        label: 'Pending',
                        color: Colors.orange.shade700,
                        loading: _loading,
                      ),
                      _MiniStatCard(
                        value: '${stats?.totalOrders ?? 0}',
                        label: 'Total Orders',
                        color: Colors.cyan.shade700,
                        loading: _loading,
                      ),
                    ],
                  );
                }

                final raw = (w - 12) / 2;
                final cardW = raw.isFinite ? raw.clamp(150.0, w) : w;
                final cards = <Widget>[
                  _MiniStatCard(
                    value: _money(stats?.total),
                    label: 'Total Commissions',
                    color: Colors.green.shade800,
                    loading: _loading,
                  ),
                  _MiniStatCard(
                    value: _money(stats?.credited),
                    label: 'Credited',
                    color: CustomStyles.callActionBlue,
                    loading: _loading,
                  ),
                  _MiniStatCard(
                    value: _money(stats?.pending),
                    label: 'Pending',
                    color: Colors.orange.shade700,
                    loading: _loading,
                  ),
                  _MiniStatCard(
                    value: '${stats?.totalOrders ?? 0}',
                    label: 'Total Orders',
                    color: Colors.cyan.shade700,
                    loading: _loading,
                  ),
                ];

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final c in cards)
                      SizedBox(
                        width: cardW,
                        child: c,
                      ),
                  ],
                );
              }),
              const SizedBox(height: 14),
              _FilterCard(
                loading: _loading,
                categories: categories,
                categoryId: _categoryId,
                status: _status,
                dateFrom: _dateFrom,
                dateTo: _dateTo,
                onCategoryChanged: (v) => setState(() => _categoryId = v),
                onStatusChanged: (v) => setState(() => _status = v),
                onPickFrom: _pickFrom,
                onPickTo: _pickTo,
                onApply: _load,
              ),
              const SizedBox(height: 14),
              _ListCard(
                loading: _loading,
                items: items,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
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
      height: 84,
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
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
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
    required this.categories,
    required this.categoryId,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.onCategoryChanged,
    required this.onStatusChanged,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onApply,
  });

  final bool loading;
  final List<CommissionCategory> categories;
  final int? categoryId;
  final String? status;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final ValueChanged<int?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onApply;

  String _d(DateTime? d) => d == null ? 'dd-mm-yyyy' : DateFormat('dd-MM-yyyy').format(d);

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final wide = w >= 980;
          final rawWide = (w - 48) / 5;
          final rawNarrow = (w - 12) / 2;
          final itemW = wide
              ? (rawWide.isFinite ? rawWide.clamp(160.0, w) : w)
              : (rawNarrow.isFinite ? rawNarrow.clamp(140.0, w) : w);
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: itemW,
                child: _Labeled(
                  label: 'Category',
                  child: DropdownButtonFormField<int?>(
                    initialValue: categoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      ),
                    ],
                    onChanged: loading ? null : onCategoryChanged,
                  ),
                ),
              ),
              SizedBox(
                width: itemW,
                child: _Labeled(
                  label: 'Status',
                  child: DropdownButtonFormField<String?>(
                    initialValue: status,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
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
                    onChanged: loading ? null : onStatusChanged,
                  ),
                ),
              ),
              SizedBox(
                width: itemW,
                child: _Labeled(
                  label: 'Date From',
                  child: InkWell(
                    onTap: loading ? null : onPickFrom,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_month_outlined, size: 18),
                      ),
                      child: Text(_d(dateFrom)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: itemW,
                child: _Labeled(
                  label: 'Date To',
                  child: InkWell(
                    onTap: loading ? null : onPickTo,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_month_outlined, size: 18),
                      ),
                      child: Text(_d(dateTo)),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: wide ? itemW : w,
                child: Align(
                  alignment: wide ? Alignment.bottomRight : Alignment.centerRight,
                  child: SizedBox(
                    height: 44,
                    width: wide ? double.infinity : double.infinity,
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

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.loading,
    required this.items,
  });

  final bool loading;
  final List<CommissionItem> items;

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
              'Commissions List',
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
              padding: const EdgeInsets.all(14),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(18),
              child: Center(
                child: Text(
                  'No commissions found',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: _CommissionRowCard(item: items[i]),
                  ),
                  if (i != items.length - 1)
                    Divider(height: 1, color: Colors.grey.shade200),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _CommissionRowCard extends StatelessWidget {
  const _CommissionRowCard({required this.item});

  final CommissionItem item;

  String _money(num? v) => '₹${(v ?? 0).toDouble().toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final credited = item.status.toLowerCase() == 'credited';
    final statusColor = credited ? Colors.green.shade700 : Colors.orange.shade700;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final narrow = c.maxWidth < 860;
          final left = SizedBox(
            width: narrow ? null : 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${item.orderId ?? item.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.dateDisplay ?? '',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );

          final mid = Expanded(
            child: _CommissionMid(item: item),
          );

          final midChild = _CommissionMid(item: item);

          final right = Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  credited ? 'Credited' : 'Pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );

          final metrics = Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              _Metric(label: 'Order Amount', value: _money(item.orderAmount)),
              _Metric(
                label: 'Commission Rate',
                value: item.commissionRateDisplay ??
                    '${item.commissionRate.toStringAsFixed(2)}%',
              ),
              _Metric(
                label: 'Commission',
                value: _money(item.commissionAmount),
                valueColor: Colors.green.shade800,
              ),
            ],
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: left),
                    right,
                  ],
                ),
                const SizedBox(height: 10),
                midChild,
                const SizedBox(height: 12),
                metrics,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(width: 18),
              mid,
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  right,
                  const SizedBox(height: 12),
                  metrics,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CommissionMid extends StatelessWidget {
  const _CommissionMid({required this.item});

  final CommissionItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.productTitle ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Category: ${item.categoryName ?? ''}',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

