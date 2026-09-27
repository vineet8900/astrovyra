import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/kundalimahadasha.dart';
import 'package:astrokavach/model/kundalichange/kundalinewmahadasha.dart';
import 'package:astrokavach/model/kundalichange/vims.dart';
import 'package:flutter/material.dart';

class KundliDashaTab extends StatelessWidget {
  final int kundaliId;
  const KundliDashaTab({Key? key, required this.kundaliId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: CustomStyles.callActionBlue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: CustomStyles.callActionBlue,
              tabs: [
                Tab(text: 'Vimshottari'),
                Tab(text: 'Yogini'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _VimshottariView(kundaliId: kundaliId),
                _YoginiView(kundaliId: kundaliId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VimshottariView extends StatefulWidget {
  final int kundaliId;
  const _VimshottariView({required this.kundaliId});

  @override
  State<_VimshottariView> createState() => _VimshottariViewState();
}

class _VimshottariViewState extends State<_VimshottariView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  VimshottariModel? _cachedVimshottari;
  AntarDashaTableModel? _cachedAntarDasha;
  bool _isVimshottariLoaded = false;
  bool _isAntarDashaLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadVimshottariData();
    _loadAntarDashaData();
  }

  Future<void> _loadVimshottariData() async {
    if (_isVimshottariLoaded) return;
    final data = await AstroApiService.getVimshottariDasha(
        widget.kundaliId, 'current-mahadasha');
    if (!mounted) return;
    setState(() {
      _cachedVimshottari = data;
      _isVimshottariLoaded = true;
    });
  }

  Future<void> _loadAntarDashaData() async {
    if (_isAntarDashaLoaded) return;
    final data = await AstroApiService.getAntarDashaTable(widget.kundaliId);
    if (!mounted) return;
    setState(() {
      _cachedAntarDasha = data;
      _isAntarDashaLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isVimshottariLoaded || _cachedVimshottari == null) {
      return const Center(
        child: CircularProgressIndicator(color: CustomStyles.callActionBlue),
      );
    }

    final data = _cachedVimshottari!;
    final dashaItems = [
      {'title': 'Mahadasha', 'data': data.mahadasha},
      {'title': 'Antardasha', 'data': data.antardasha},
      {'title': 'Paryantardasha', 'data': data.paryantardasha},
      {'title': 'Shookshamadasha', 'data': data.shookshamadasha},
      {'title': 'Pranadasha', 'data': data.pranadasha},
    ];

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 16),
              child: Text(
                'Vimshottari Dasha Details',
                style: TextStyle(
                    color: CustomStyles.callActionBlue,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Container(
              width: 180,
              height: 3,
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 20),
              decoration: BoxDecoration(
                color: CustomStyles.callActionBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: dashaItems.map((item) {
                  final detail = item['data'] as DashaDetail;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildCommonDashaCard(
                      title: item['title'] as String,
                      planetName: detail.name?.toString() ?? '',
                      startDate: detail.start?.toString() ?? '',
                      endDate: detail.end?.toString() ?? '',
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildAntarDashaTable(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAntarDashaTable() {
    if (!_isAntarDashaLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: CustomStyles.callActionBlue),
        ),
      );
    }

    if (_cachedAntarDasha == null) {
      return const SizedBox.shrink();
    }

    final antar = _cachedAntarDasha!;
    final mahaTableData = <Map<String, dynamic>>[];
    final antas = antar.antardashas;
    final orders = antar.antardashaOrder;

    for (int i = 0; i < antas.length && i < orders.length; i++) {
      final rowNames = antas[i];
      final rowDates = orders[i];
      if (rowNames.isEmpty) continue;

      final mainPlanet = rowNames.first.split('/').first;
      final subDashas = <Map<String, String>>[];
      for (int j = 0; j < rowNames.length && j < rowDates.length; j++) {
        final parts = rowNames[j].split('/');
        final subName = parts.length > 1 ? parts[1] : rowNames[j];
        subDashas.add({'name': subName, 'date': rowDates[j]});
      }

      mahaTableData.add({'main_planet': mainPlanet, 'sub_dashas': subDashas});
    }

    return VimshottariMahaDashaTable(dashaData: mahaTableData);
  }

  Widget _buildCommonDashaCard({
    required String title,
    required String planetName,
    required String startDate,
    required String endDate,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: CustomStyles.callActionBlue,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    planetName,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startDate.isEmpty ? 'N/A' : startDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        endDate.isEmpty ? 'N/A' : endDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VimshottariMahaDashaTable extends StatelessWidget {
  final List<Map<String, dynamic>> dashaData;
  const VimshottariMahaDashaTable({Key? key, required this.dashaData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Vimshottari Maha Dasha',
            style: TextStyle(
              color: CustomStyles.callActionBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: 240,
          height: 3,
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 20),
          color: CustomStyles.callActionBlue,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dashaData.length,
          itemBuilder: (context, index) {
            final item = dashaData[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item['main_planet'].toString().toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Container(
                    color: Colors.blue.shade50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'PLANET',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: CustomStyles.callActionBlue,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'END DATE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: CustomStyles.callActionBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Column(
                    children: (item['sub_dashas'] as List).map((sub) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    sub['name'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    sub['date'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, indent: 12, endIndent: 12),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _YoginiView extends StatefulWidget {
  final int kundaliId;
  const _YoginiView({required this.kundaliId});

  @override
  State<_YoginiView> createState() => _YoginiViewState();
}

class _YoginiViewState extends State<_YoginiView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  YoginiModel? _cachedYogini;
  bool _isYoginiLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadYoginiData();
  }

  Future<void> _loadYoginiData() async {
    if (_isYoginiLoaded) return;
    final data = await AstroApiService.getYoginiDasha(widget.kundaliId);
    if (!mounted) return;
    setState(() {
      _cachedYogini = data;
      _isYoginiLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_isYoginiLoaded || _cachedYogini == null) {
      return const Center(
        child: CircularProgressIndicator(color: CustomStyles.callActionBlue),
      );
    }

    final data = _cachedYogini!;
    final len = data.dashaList.length;

    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Dasha')),
          DataColumn(label: Text('Lord')),
          DataColumn(label: Text('End Date')),
        ],
        rows: List.generate(len, (index) {
          final end = (index < data.endDates.length)
              ? data.endDates[index].toString()
              : '';
          return DataRow(cells: [
            DataCell(Text(
              data.dashaList[index].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Text(
              (index < data.lords.length) ? data.lords[index].toString() : '',
            )),
            DataCell(Text(end.split(' ').take(4).join(' '))),
          ]);
        }),
      ),
    );
  }
}
