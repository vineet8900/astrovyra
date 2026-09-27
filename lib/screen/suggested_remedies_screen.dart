import 'package:astrokavach/api/suggested_remedies_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/suggested_remedies_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SuggestedRemediesScreen extends StatefulWidget {
  const SuggestedRemediesScreen({super.key});

  @override
  State<SuggestedRemediesScreen> createState() =>
      _SuggestedRemediesScreenState();
}

class _SuggestedRemediesScreenState extends State<SuggestedRemediesScreen> {
  static const Color _pageBg = Color(0xFFF5F5F5);
  static const Color _priceBlue = Color(0xFF1976D2);

  List<SuggestedRemedyEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await SuggestedRemediesApi.fetchList();
    if (!mounted) return;
    if (res == null) {
      setState(() {
        _loading = false;
        _error = 'Could not load suggested remedies.';
      });
      return;
    }
    if (!res.status) {
      setState(() {
        _loading = false;
        _error = res.message.isNotEmpty
            ? res.message
            : 'Could not load suggested remedies.';
      });
      return;
    }
    setState(() {
      _entries = res.data;
      _loading = false;
      _error = null;
    });
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final normalized = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
      final dt = DateTime.parse(normalized);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'Suggested Remedies',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_entries.isEmpty) {
      return Center(
        child: Text(
          'No suggested remedies yet.',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: _entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return _remedyCard(_entries[index]);
        },
      ),
    );
  }

  Widget _remedyCard(SuggestedRemedyEntry entry) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    entry.astrologerName.isNotEmpty
                        ? entry.astrologerName
                        : 'Astrologer',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _statusChip(entry.isUsed),
              ],
            ),
            if (entry.createdAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _formatDate(entry.createdAt),
                style: TextStyle(
                  fontSize: 13,
                  color: CustomStyles.detailsOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1, color: Colors.grey.shade300),
            ),
            if (!entry.hasAnyItems)
              Text(
                'No items listed.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              )
            else ...[
              if (entry.products.isNotEmpty)
                _section(
                  label: 'Products',
                  color: CustomStyles.green,
                  items: entry.products,
                ),
              if (entry.products.isNotEmpty &&
                  (entry.reports.isNotEmpty || entry.pujas.isNotEmpty))
                const SizedBox(height: 14),
              if (entry.reports.isNotEmpty)
                _section(
                  label: 'Reports',
                  color: const Color(0xFF1565C0),
                  items: entry.reports,
                ),
              if (entry.reports.isNotEmpty && entry.pujas.isNotEmpty)
                const SizedBox(height: 14),
              if (entry.pujas.isNotEmpty)
                _section(
                  label: 'Pujas',
                  color: const Color(0xFF6A1B9A),
                  items: entry.pujas,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statusChip(int isUsed) {
    final used = isUsed == 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: used ? Colors.grey.shade300 : CustomStyles.detailsOrange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: used ? Colors.grey.shade500 : CustomStyles.detailsOrange,
        ),
      ),
      child: Text(
        used ? 'Ordered' : 'Suggested',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: used ? Colors.grey.shade800 : CustomStyles.detailsOrange,
        ),
      ),
    );
  }

  Widget _section({
    required String label,
    required Color color,
    required List<SuggestedRemedyLineItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _productTile(items[i]),
        ],
      ],
    );
  }

  Widget _productTile(SuggestedRemedyLineItem p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              p.title,
              softWrap: true,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            p.displayPrice,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _priceBlue,
            ),
          ),
        ],
      ),
    );
  }
}
