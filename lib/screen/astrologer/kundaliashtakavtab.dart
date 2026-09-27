import 'dart:math' as math;

import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/ashtavar.dart';
import 'package:flutter/material.dart';

class KundliAshtakvargaTab extends StatefulWidget {
  final int kundaliId;
  final String planet;

  const KundliAshtakvargaTab({
    Key? key,
    required this.kundaliId,
    this.planet = 'Sun',
  }) : super(key: key);

  @override
  State<KundliAshtakvargaTab> createState() => _KundliAshtakvargaTabState();
}

class _KundliAshtakvargaTabState extends State<KundliAshtakvargaTab> {
  late Future<AshtakvargaApiResponse?> _future;

  static const _zodiacSigns = <String>[
    'ARIES',
    'TAURUS',
    'GEMINI',
    'CANCER',
    'LEO',
    'VIRGO',
    'LIBRA',
    'SCORPIO',
    'SAGITTARIUS',
    'CAPRICORN',
    'AQUARIUS',
    'PISCES',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = AstroApiService.getAshtakvarga(
      kundaliId: widget.kundaliId,
      planet: widget.planet,
    );
  }

  void _retry() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AshtakvargaApiResponse?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 44, color: Colors.red[400]),
                  const SizedBox(height: 12),
                  const Text('Failed to load Ashtakvarga'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _retry,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        if (data.ashtakvargaPoints.isEmpty || data.ashtakvargaTotal.isEmpty) {
          return const Center(child: Text('No Ashtakvarga data'));
        }

        final rowCount = data.ashtakvargaPoints.length;
        final planetCount = data.ashtakvargaOrder.length;
        final safeRows = math.min(rowCount, planetCount);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Ashtakvarga - Sarvashtakvarga',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: CustomStyles.callActionBlue,
                  ),
                ),
              ),
              Divider(thickness: 2, color: CustomStyles.callActionBlue.withOpacity(0.25)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                    columnSpacing: 25,
                    dataRowHeight: 45,
                    headingRowHeight: 50,
                    border: TableBorder.all(color: Colors.grey[200]!),
                    columns: [
                      const DataColumn(
                        label: Text(
                          'PLANETS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ..._zodiacSigns.map(
                        (sign) => DataColumn(
                          label: Text(
                            sign,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: [
                      ...List.generate(safeRows, (index) {
                        final pointsRow = data.ashtakvargaPoints[index];
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                data.ashtakvargaOrder[index],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            ...List.generate(
                              12,
                              (i) => DataCell(
                                Center(
                                  child: Text(
                                    (i < pointsRow.length)
                                        ? pointsRow[i].toString()
                                        : '-',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      DataRow(
                        color: WidgetStateProperty.all(Colors.grey[50]),
                        cells: [
                          const DataCell(
                            Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...List.generate(
                            12,
                            (i) => DataCell(
                              Center(
                                child: Text(
                                  (i < data.ashtakvargaTotal.length)
                                      ? data.ashtakvargaTotal[i].toString()
                                      : '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
