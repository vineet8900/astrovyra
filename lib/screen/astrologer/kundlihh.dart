import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/jaiminkarasmodel.dart';
import 'package:astrokavach/model/kundalichange/kundalibasic.dart';
import 'package:astrokavach/model/kundalichange/kundalimahadash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class KundliKundliTab extends StatefulWidget {
  final int kundaliId;
  final KundaliBasicResponse basic;

  const KundliKundliTab({
    Key? key,
    required this.kundaliId,
    required this.basic,
  }) : super(key: key);

  @override
  State<KundliKundliTab> createState() => _KundliKundliTabState();
}

class _KundliKundliTabState extends State<KundliKundliTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String selectedDiv = 'D1';
  String selectedChartType = 'north';

  Future<String?>? _chartFuture;
  Future<MahadashaModel?>? _mahadashaFuture;
  Future<JaiminiKarakasModel?>? _karakasFuture;

  @override
  void initState() {
    super.initState();
    _loadStaticData();
    _loadChart();
  }

  void _loadStaticData() {
    _mahadashaFuture = AstroApiService.getMahadasha(widget.kundaliId);
    _karakasFuture = AstroApiService.getJaiminiKarakas(widget.kundaliId);
  }

  void _loadChart() {
    setState(() {
      _chartFuture = AstroApiService.getChartSvg(
        kundaliId: widget.kundaliId,
        div: selectedDiv,
        chartType: selectedChartType,
      );
    });
  }

  String _cleanSvg(String rawData) {
    if (rawData.isEmpty) return '';
    String svg = rawData.trim();
    svg = svg.replaceAll(RegExp(r'display:\s?flex;?'), '');
    svg = svg.replaceAll(RegExp(r'justify-content:\s?center;?'), '');
    svg = svg.replaceAll(RegExp(r'align-items:\s?center;?'), '');
    svg = svg.replaceAll("font-family: '',", 'font-family: sans-serif,');
    if (!svg.contains('xmlns="http://www.w3.org/2000/svg"')) {
      svg = svg.replaceFirst('<svg', '<svg xmlns="http://www.w3.org/2000/svg"');
    }
    return svg;
  }

  List<MapEntry<String, dynamic>> _planetRows() {
    final out = <MapEntry<String, dynamic>>[];
    const skip = {'panchang', 'extended', 'panchang_data', 'response'};
    widget.basic.response.forEach((k, v) {
      if (v is! Map) return;
      if (skip.contains(k.toString().toLowerCase())) return;
      final m = v as Map;
      final hasPlanet = m['full_name'] != null ||
          m['name'] != null ||
          m['zodiac'] != null ||
          m['house'] != null;
      if (!hasPlanet) return;
      if (int.tryParse(k.toString()) != null) {
        out.add(MapEntry(k.toString(), v));
      }
    });
    out.sort((a, b) => int.parse(a.key).compareTo(int.parse(b.key)));
    if (out.isNotEmpty) return out;
    widget.basic.response.forEach((k, v) {
      if (v is! Map) return;
      if (skip.contains(k.toString().toLowerCase())) return;
      final m = v as Map;
      if (m['full_name'] != null || m['zodiac'] != null) {
        out.add(MapEntry(k.toString(), v));
      }
    });
    return out;
  }

  String _planetDegreeTwoDecimals(dynamic degRaw) {
    if (degRaw == null) return '—';
    final n = double.tryParse(degRaw.toString().replaceAll(',', '.'));
    if (n == null) return '—';
    return n.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ColoredBox(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Divisional Charts',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CustomStyles.callActionBlue,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 3,
                width: 60,
                color: CustomStyles.callActionBlue,
              ),
            ),
            const Divider(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedDiv,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    items: _kundliDivisionalCharts.map((chart) {
                      return DropdownMenuItem(
                        value: chart.div,
                        child: Text(
                          chart.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        selectedDiv = val;
                        _loadChart();
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeButton(
                    'North India Chart',
                    'north',
                    const Color(0xFFFFB300),
                  ),
                  const SizedBox(width: 10),
                  _buildTypeButton(
                    'South India Chart',
                    'south',
                    const Color(0xFFC62828),
                  ),
                ],
              ),
            ),
            FutureBuilder<String?>(
              future: _chartFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text('Chart Load Failed')),
                  );
                }

                final cleanedSvg = _cleanSvg(snapshot.data!);

                return Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ],
                    ),
                    child: SvgPicture.string(
                      cleanedSvg,
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 350,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            _buildPlanetPositionsSection(),
            const SizedBox(height: 10),
            FutureBuilder<MahadashaModel?>(
              future: _mahadashaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SizedBox(
                        height: 120,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: CustomStyles.callActionBlue,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            'Error loading Mahadasha',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return _MahadashaBlock(data: snapshot.data!);
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<JaiminiKarakasModel?>(
              future: _karakasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return _JaiminiKarakasBlock(data: snapshot.data!);
                }
                return const SizedBox();
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _planetCell(
    String text, {
    bool bold = false,
    bool center = false,
    bool numeric = false,
    bool header = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: numeric
            ? TextAlign.right
            : (center ? TextAlign.center : TextAlign.start),
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
          height: 1.35,
          color: header ? CustomStyles.callActionBlue : null,
        ),
      ),
    );
  }

  Widget _buildPlanetPositionsSection() {
    final rows = _planetRows();
    final borderColor = Colors.grey.shade300;
    if (rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'No planet positions found',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Planet Positions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomStyles.callActionBlue,
                ),
              ),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(color: borderColor, width: 1),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(36),
                  1: FlexColumnWidth(1.1),
                  2: FlexColumnWidth(1.1),
                  3: FixedColumnWidth(44),
                  4: FixedColumnWidth(56),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    children: [
                      _planetCell('#', bold: true, center: true, header: true),
                      _planetCell('Planet', bold: true, header: true),
                      _planetCell('Zodiac', bold: true, header: true),
                      _planetCell('H', bold: true, center: true, header: true),
                      _planetCell('Deg.', bold: true, numeric: true, header: true),
                    ],
                  ),
                  ...rows.asMap().entries.map((entry) {
                    final m = Map<dynamic, dynamic>.from(entry.value.value as Map);
                    final name =
                        m['full_name']?.toString() ?? m['name']?.toString() ?? '—';
                    final zodiac = m['zodiac']?.toString() ?? '—';
                    final house = m['house']?.toString() ?? '—';
                    final degRaw =
                        m['local_degree'] ?? m['degree'] ?? m['global_degree'];
                    final deg = _planetDegreeTwoDecimals(degRaw);
                    return TableRow(
                      children: [
                        _planetCell(
                          '${entry.key + 1}',
                          center: true,
                        ),
                        _planetCell(name),
                        _planetCell(zodiac),
                        _planetCell(house, center: true),
                        _planetCell(deg, numeric: true),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String title, String type, Color activeColor) {
    final isSelected = selectedChartType == type;
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          selectedChartType = type;
          _loadChart();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _KundliChartSelection {
  final String div;
  final String name;
  const _KundliChartSelection({required this.div, required this.name});
}

const List<_KundliChartSelection> _kundliDivisionalCharts = [
  _KundliChartSelection(
    div: 'D1',
    name: 'Lagna/Ascendant/Basic Birth Chart',
  ),
  _KundliChartSelection(div: 'D9', name: 'D9 Navamsa'),
];

class _MahadashaBlock extends StatelessWidget {
  final MahadashaModel data;
  const _MahadashaBlock({required this.data});

  static String _formatDashaLine(dynamic e) {
    if (e is Map) {
      final m = Map<dynamic, dynamic>.from(e);
      return m.entries.map((x) => '${x.key}: ${x.value}').join(' ');
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = Colors.grey.shade300;
    final rows = data.mahadasha.take(20).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mahadasha',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomStyles.callActionBlue,
                ),
              ),
              const SizedBox(height: 10),
              if (data.dashaStartDate != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'Start: ${data.dashaStartDate}',
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                ),
              if (data.dashaRemainingAtBirth != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Remaining at birth: ${data.dashaRemainingAtBirth}',
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                ),
              Table(
                border: TableBorder.all(color: borderColor, width: 1),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FixedColumnWidth(40),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    children: [
                      _mahadashaCell('#', bold: true, center: true, header: true),
                      _mahadashaCell('Mahadasha', bold: true, header: true),
                    ],
                  ),
                  ...rows.asMap().entries.map((entry) {
                    return TableRow(
                      children: [
                        _mahadashaCell(
                          '${entry.key + 1}',
                          center: true,
                        ),
                        _mahadashaCell(
                          _formatDashaLine(entry.value),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _mahadashaCell(
    String text, {
    bool bold = false,
    bool center = false,
    bool header = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
          height: 1.35,
          color: header ? CustomStyles.callActionBlue : null,
        ),
      ),
    );
  }
}

class _JaiminiKarakasBlock extends StatelessWidget {
  final JaiminiKarakasModel data;
  const _JaiminiKarakasBlock({required this.data});

  @override
  Widget build(BuildContext context) {
    final mapped = <MapEntry<String, JaiminiKaraka?>>[
      MapEntry('Atma', data.atma),
      MapEntry('Amatya', data.amatya),
      MapEntry('Bhratru', data.bhratru),
      MapEntry('Matri', data.matri),
      MapEntry('Putra', data.putra),
      MapEntry('Gnati', data.gnati),
      MapEntry('Dara', data.dara),
    ];
    final filled = mapped.where((e) => e.value != null).toList();
    final borderColor = Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jaimini Karakas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CustomStyles.callActionBlue,
                ),
              ),
              const SizedBox(height: 10),
              if (filled.isEmpty)
                Text(
                  'No data',
                  style: TextStyle(color: Colors.grey[700]),
                )
              else
                Table(
                  border: TableBorder.all(color: borderColor, width: 1),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(0.9),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.1),
                    3: FixedColumnWidth(44),
                    4: FixedColumnWidth(52),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade50),
                      children: [
                        _jaiminiCell('Karaka', bold: true, lead: true, header: true),
                        _jaiminiCell('Planet', bold: true, header: true),
                        _jaiminiCell('Zodiac', bold: true, header: true),
                        _jaiminiCell('H', bold: true, numeric: true, header: true),
                        _jaiminiCell('Deg.', bold: true, numeric: true, header: true),
                      ],
                    ),
                    ...filled.map((e) {
                      final v = e.value!;
                      return TableRow(
                        children: [
                          _jaiminiCell(e.key, lead: true),
                          _jaiminiCell(
                            (v.planet ?? v.name)?.toString() ?? '—',
                          ),
                          _jaiminiCell(v.zodiac?.toString() ?? '—'),
                          _jaiminiCell(
                            v.house?.toString() ?? '—',
                            numeric: true,
                          ),
                          _jaiminiCell(
                            v.localDegree != null
                                ? v.localDegree!.toStringAsFixed(2)
                                : '—',
                            numeric: true,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _jaiminiCell(
    String text, {
    bool bold = false,
    bool numeric = false,
    bool lead = false,
    bool header = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: numeric
            ? TextAlign.right
            : (lead ? TextAlign.start : TextAlign.center),
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
          height: 1.35,
          color: header ? CustomStyles.callActionBlue : null,
        ),
      ),
    );
  }
}
