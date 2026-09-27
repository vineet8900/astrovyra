import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalimodel/kundali_generated_list.dart';
import 'package:astrokavach/screen/astrologer/kundlichartscreen.dart';
import 'package:astrokavach/screen/astrologer/kundliscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyKundliListScreen extends StatefulWidget {
  const MyKundliListScreen({super.key});

  @override
  State<MyKundliListScreen> createState() => _MyKundliListScreenState();
}

class _MyKundliListScreenState extends State<MyKundliListScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<KundaliGeneratedItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  int _page = 1;
  int _lastPage = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(initial: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _loading) return;
    if (_page >= _lastPage) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 80) {
      _loadMore();
    }
  }

  Future<void> _load({bool initial = false}) async {
    if (initial) {
      setState(() {
        _loading = true;
        _error = null;
        _items.clear();
        _page = 1;
      });
    }
    final result = await AstroApiService.fetchKundaliGeneratedList(page: 1);
    if (!mounted) return;
    if (result == null) {
      setState(() {
        _loading = false;
        _error = 'my_kundli_list_error'.tr;
      });
      return;
    }
    setState(() {
      _items
        ..clear()
        ..addAll(result.items);
      _lastPage = result.lastPage;
      _page = result.currentPage;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_page >= _lastPage) return;
    setState(() => _loadingMore = true);
    final next = _page + 1;
    final result = await AstroApiService.fetchKundaliGeneratedList(page: next);
    if (!mounted) return;
    if (result == null) {
      setState(() => _loadingMore = false);
      return;
    }
    setState(() {
      _items.addAll(result.items);
      _page = result.currentPage;
      _lastPage = result.lastPage;
      _loadingMore = false;
    });
  }

  static const List<Color> _avatarColors = [
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF009688),
    Color(0xFF5C6BC0),
    Color(0xFFE91E63),
    Color(0xFF7E57C2),
  ];

  String _initialLetter(String name) {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }

  String _formattedDateTime(String birthDate, String birthTime) {
    String datePart = birthDate;
    try {
      if (birthDate.isNotEmpty) {
        final d = DateFormat('yyyy-MM-dd').parseStrict(birthDate);
        datePart = DateFormat('d MMMM yyyy').format(d);
      }
    } catch (_) {}
    String timePart = '';
    if (birthTime.isNotEmpty) {
      final parts = birthTime.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0].trim()) ?? 0;
        final m = int.tryParse(parts[1].trim()) ?? 0;
        final dt = DateTime(2000, 1, 1, h, m);
        timePart = DateFormat('hh:mm a').format(dt);
      }
    }
    if (datePart.isEmpty && timePart.isEmpty) return '';
    if (datePart.isEmpty) return timePart;
    if (timePart.isEmpty) return datePart;
    return '$datePart, $timePart';
  }

  Widget _buildCreateButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => NewKundliScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomStyles.pinki,
            foregroundColor: CustomStyles.whiteColor,
            elevation: 2,
            shadowColor: CustomStyles.pinki,
            shape: const StadiumBorder(),
          ),
          child: Text(
            'create_new_kundli'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'my_kundli'.tr),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: CustomStyles.black14600,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => _load(initial: true),
                                child: Text('retry'.tr),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _load(initial: true),
                        child: _items.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.45,
                                    child: Center(
                                      child: Text(
                                        'my_kundli_list_empty'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  16,
                                ),
                                itemCount:
                                    _items.length + (_loadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= _items.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final item = _items[index];
                                  final avatarColor = _avatarColors[
                                      index % _avatarColors.length];
                                  final dateTimeLine = _formattedDateTime(
                                    item.birthDate,
                                    item.birthTime,
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Material(
                                      color: Colors.white,
                                      elevation: 0,
                                      shadowColor: Colors.black26,
                                      borderRadius: BorderRadius.circular(14),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<void>(
                                              builder: (context) =>
                                                  KundliChartScreen(
                                                kundaliId: item.kundaliId,
                                              ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(14),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.06),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 52,
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  color: avatarColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  _initialLetter(item.name),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF212121),
                                                      ),
                                                    ),
                                                    if (dateTimeLine
                                                        .isNotEmpty) ...[
                                                      const SizedBox(
                                                          height: 6),
                                                      Text(
                                                        dateTimeLine,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey.shade600,
                                                          height: 1.25,
                                                        ),
                                                      ),
                                                    ],
                                                    if (item.birthPlace
                                                        .trim()
                                                        .isNotEmpty) ...[
                                                      const SizedBox(
                                                          height: 4),
                                                      Text(
                                                        item.birthPlace,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors
                                                              .grey.shade600,
                                                          height: 1.25,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
          if (!_loading) _buildCreateButton(context),
        ],
      ),
    );
  }
}
