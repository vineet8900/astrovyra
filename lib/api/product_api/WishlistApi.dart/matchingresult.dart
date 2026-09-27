import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalimodelsmatching/kundalimodelmatching.dart';
import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:flutter/material.dart';

class MatchingResultScreen extends StatelessWidget {
  final KundaliMatchingData data;

  const MatchingResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: 'Kundali Matching Report',
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailsCard(),
              const SizedBox(height: 24),
              _buildGunaMillanCard(),
              const SizedBox(height: 24),
              _buildResultSummaryCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    final borderColor = Colors.grey.shade300;
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Details Of Boy and Girl',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.15),
                1: FlexColumnWidth(1.4),
                2: FlexColumnWidth(1.4),
              },
              border: TableBorder.all(color: borderColor, width: 1),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade50),
                  children: [
                    _detailTableCell('', align: TextAlign.start, bold: true),
                    _detailTableCell('Boy', align: TextAlign.center, bold: true),
                    _detailTableCell('Girl', align: TextAlign.center, bold: true),
                  ],
                ),
                _detailDataRow(
                  'Name',
                  data.boy.name.toString(),
                  data.girl.name.toString(),
                ),
                _detailDataRow(
                  'Date/Time',
                  data.boy.datetime.toString(),
                  data.girl.datetime.toString(),
                ),
                _detailDataRow(
                  'Place',
                  data.boy.birthPlace.toString(),
                  data.girl.birthPlace.toString(),
                ),
                _detailDataRow(
                  'Latitude',
                  data.boy.latitude.toString(),
                  data.girl.latitude.toString(),
                ),
                _detailDataRow(
                  'Longitude',
                  data.boy.longitude.toString(),
                  data.girl.longitude.toString(),
                ),
                _detailDataRow(
                  'Time Zone',
                  data.boy.timezone.toString(),
                  data.girl.timezone.toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTableCell(String text,
      {required TextAlign align, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  TableRow _detailDataRow(String label, String boyValue, String girlValue) {
    return TableRow(
      children: [
        _detailTableCell(label, align: TextAlign.start, bold: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            boyValue,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Text(
            girlValue,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.35),
          ),
        ),
      ],
    );
  }

  Widget _buildGunaMillanCard() {
    final borderColor = Colors.grey.shade300;
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Guna Millan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.35),
                        1: FlexColumnWidth(1.35),
                        2: FlexColumnWidth(1.35),
                        3: FixedColumnWidth(48),
                        4: FixedColumnWidth(48),
                      },
                      border: TableBorder.all(color: borderColor, width: 1),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey.shade50),
                          children: [
                            _gunaHeaderCell('Guna'),
                            _gunaHeaderCell('Boy'),
                            _gunaHeaderCell('Girl'),
                            _gunaHeaderCell('Max', numeric: true),
                            _gunaHeaderCell('Obt.', numeric: true),
                          ],
                        ),
                        ...data.gunas.values.map((guna) {
                          return TableRow(
                            children: [
                              _gunaDataCell(guna.guna.toString()),
                              _gunaDataCell(guna.boy.toString()),
                              _gunaDataCell(guna.girl.toString()),
                              _gunaDataCell(guna.maximumObtained.toString(),
                                  numeric: true),
                              _gunaDataCell(guna.obtainedPoints.toString(),
                                  numeric: true),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _gunaHeaderCell(String text, {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: numeric ? TextAlign.right : TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _gunaDataCell(String text, {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: numeric ? TextAlign.right : TextAlign.center,
        style: const TextStyle(fontSize: 13, height: 1.35),
      ),
    );
  }

  Widget _buildResultSummaryCard(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Obtained Point',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${data.score.obtained} / ${data.score.total}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text(
              'Conclusion',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              data.botResponse.toString(),
              style: const TextStyle(fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AstrologerListScreen(
                      popToPreviousOnBack: true,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Talk to Astrologer'),
            ),
          ],
        ),
      ),
    );
  }
}
