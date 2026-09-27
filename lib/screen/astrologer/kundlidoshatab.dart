import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/kundalichange/doshanew.dart';
import 'package:flutter/material.dart';

class KundliDoshaTab extends StatelessWidget {
  final int kundaliId;
  const KundliDoshaTab({Key? key, required this.kundaliId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelColor: Colors.redAccent,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.redAccent,
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Manglik'),
                Tab(text: 'Mangal Analysis'),
                Tab(text: 'Kaal Sarp'),
                Tab(text: 'Sade Sati'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DoshaDetailView(id: kundaliId, type: 'manglik'),
                _MangalAnalysisView(id: kundaliId),
                _DoshaDetailView(id: kundaliId, type: 'kalsarpa'),
                _DoshaDetailView(id: kundaliId, type: 'sadesati'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MangalAnalysisView extends StatefulWidget {
  final int id;
  const _MangalAnalysisView({required this.id});

  @override
  State<_MangalAnalysisView> createState() => _MangalAnalysisViewState();
}

class _MangalAnalysisViewState extends State<_MangalAnalysisView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<MangalAnalysisResponse?>? _mangalFuture;

  @override
  void initState() {
    super.initState();
    _mangalFuture = AstroApiService.getMangalAnalysis(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<MangalAnalysisResponse?>(
      future: _mangalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Data loading error...'));
        }

        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              color: data.isDoshaPresent
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: data.isDoshaPresent
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      data.isDoshaPresent
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_outlined,
                      size: 60,
                      color: data.isDoshaPresent ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      data.botResponse,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: data.isDoshaPresent
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                      ),
                    ),
                    if (data.score > 0) ...[
                      const SizedBox(height: 10),
                      Chip(
                        label: Text('Dosha Score: ${data.score}%'),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (data.isAnshik)
              _buildInfoTile(
                'Anshik Manglik',
                'Partial manglik dosha detected.',
                Colors.orange,
              ),
            if (data.isDoshaPresentMarsFromLagna)
              _buildInfoTile(
                'Mars from Lagna',
                'Mangal dosha present from Lagna.',
                Colors.red,
              ),
            if (data.isDoshaPresentMarsFromMoon)
              _buildInfoTile(
                'Mars from Moon',
                'Mangal dosha present from Moon.',
                Colors.red,
              ),
            if (data.factors.isNotEmpty) ...[
              const SizedBox(height: 25),
              const Text('Mangal Analysis Factors',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (data.factors.containsKey('moon'))
                _buildFactorCard('Moon', '${data.factors['moon']}'),
              if (data.factors.containsKey('venus'))
                _buildFactorCard('Venus', '${data.factors['venus']}'),
              if (data.factors.containsKey('saturn'))
                _buildFactorCard('Saturn', '${data.factors['saturn']}'),
            ],
            if (data.cancellation != null) ...[
              const SizedBox(height: 25),
              const Text('Dosha Cancellation',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 10),
              _buildBulletPoint(
                'Cancellation Score: ${(data.cancellation!.cancellationScore * 100).toStringAsFixed(0)}%',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
              ...data.cancellation!.cancellationReason.map(
                (reason) => _buildBulletPoint(
                  reason,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }

  Widget _buildFactorCard(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.star, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900),
            )
          ]),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
                fontSize: 14, color: Colors.red.shade800, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text,
      {IconData icon = Icons.info_outline, Color color = Colors.redAccent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 10),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color)),
              Text(sub, style: TextStyle(fontSize: 12, color: color)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DoshaDetailView extends StatefulWidget {
  final int id;
  final String type;
  const _DoshaDetailView({required this.id, required this.type});

  @override
  State<_DoshaDetailView> createState() => _DoshaDetailViewState();
}

class _DoshaDetailViewState extends State<_DoshaDetailView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<DoshaResponse?>? _doshaFuture;

  @override
  void initState() {
    super.initState();
    _doshaFuture = AstroApiService.getDoshaDetails(
      kundaliId: widget.id,
      doshaType: widget.type,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<DoshaResponse?>(
      future: _doshaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.redAccent));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No Data available'));
        }

        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 0,
              color: data.isPresent ? Colors.red.shade50 : Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: data.isPresent
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      data.isPresent
                          ? Icons.warning_amber_rounded
                          : Icons.verified_user_outlined,
                      size: 60,
                      color: data.isPresent ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      data.botResponse,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: data.isPresent
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                      ),
                    ),
                    if (data.score > 0) ...[
                      const SizedBox(height: 10),
                      Chip(
                        label: Text('Dosha Score: ${data.score}%'),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (data.isAnshik == true)
              _buildInfoTile(
                'Anshik Manglik',
                'You have partial manglik dosha.',
                Colors.orange,
              ),
            if (data.description != null && data.description!.isNotEmpty) ...[
              const SizedBox(height: 25),
              const Text('About this Dosha',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                data.description!,
                style: TextStyle(color: Colors.grey[700], height: 1.5),
              ),
            ],
            if (data.factors.isNotEmpty || data.aspects.isNotEmpty) ...[
              const SizedBox(height: 25),
              const Text('Analysis Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...data.factors.map((e) => _buildBulletPoint(e)),
              ...data.aspects.map((e) => _buildBulletPoint(e)),
            ],
            if (data.cancellationReasons.isNotEmpty) ...[
              const SizedBox(height: 25),
              const Text('Dosha Cancellation',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 10),
              ...data.cancellationReasons.map(
                (e) => _buildBulletPoint(e,
                    icon: Icons.check_circle, color: Colors.green),
              ),
            ],
            if (data.remedies.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Row(children: [
                Icon(Icons.auto_awesome, color: Colors.blue),
                SizedBox(width: 8),
                Text('Remedies & Solutions',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue))
              ]),
              const SizedBox(height: 12),
              ...data.remedies.map(
                (remedy) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    remedy,
                    style: TextStyle(
                        fontSize: 14, color: Colors.blue.shade900, height: 1.4),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }

  Widget _buildBulletPoint(String text,
      {IconData icon = Icons.info_outline, Color color = Colors.redAccent}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String sub, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
