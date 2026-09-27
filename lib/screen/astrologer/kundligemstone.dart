import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/gemstone.dart';
import 'package:flutter/material.dart';

class KundliGemstoneTab extends StatefulWidget {
  final int kundaliId;
  const KundliGemstoneTab({Key? key, required this.kundaliId})
      : super(key: key);

  @override
  State<KundliGemstoneTab> createState() => _KundliGemstoneTabState();
}

class _KundliGemstoneTabState extends State<KundliGemstoneTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<GemModel?> _gemFuture;

  @override
  void initState() {
    super.initState();
    _gemFuture = AstroApiService.getGemSuggestion(widget.kundaliId);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      color: Colors.grey.shade50,
      child: FutureBuilder<GemModel?>(
        future: _gemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: CustomStyles.callActionBlue),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No Suggestion Found'));
          }

          final gem = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Gem Recommendation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: CustomStyles.callActionBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Personalized Rudraksha suggestions based on your astrological profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTopStonesRow(gem),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        children: [
                          Expanded(child: _buildNameCard(gem)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGemCard(gem)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildPlanetCard(gem)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildNameCard(gem),
                        const SizedBox(height: 16),
                        _buildGemCard(gem),
                        const SizedBox(height: 16),
                        _buildPlanetCard(gem),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildDescriptionCard(gem),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildWrapCard(
                                  'Good Results For:', gem.goodResults)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildWrapCard(
                                  'Diseases Cure:', gem.diseasesCure)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildWrapCard(
                                  'Metal substitute:', gem.substitute)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildWrapCard('Good Results For:', gem.goodResults),
                        const SizedBox(height: 16),
                        _buildWrapCard('Diseases Cure:', gem.diseasesCure),
                        const SizedBox(height: 16),
                        _buildWrapCard('Metal substitute:', gem.substitute),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 1000) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildWrapCard(
                                  'Not wear with:', gem.notToWearWith)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFingerWeightCard(gem)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildFlawResultsCard(gem)),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _buildWrapCard('Not wear with:', gem.notToWearWith),
                        const SizedBox(height: 16),
                        _buildFingerWeightCard(gem),
                        const SizedBox(height: 16),
                        _buildFlawResultsCard(gem),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildTimeToWearCard(gem),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopStonesRow(GemModel gem) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 600;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CustomStyles.callActionBlue.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.stars_rounded,
                      color: CustomStyles.callActionBlue, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Astrological Stones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CustomStyles.callActionBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isMobile) ...[
              _stoneMiniCard(
                'Life Stone',
                gem.lifeStone,
                Colors.orange,
                Icons.favorite_rounded,
                'Vitality & Energy',
              ),
              const SizedBox(height: 12),
              _stoneMiniCard(
                'Lucky Stone',
                gem.luckyStone,
                Colors.redAccent,
                Icons.auto_awesome_rounded,
                'Fortune & Success',
              ),
              const SizedBox(height: 12),
              _stoneMiniCard(
                'Fortune Stone',
                gem.fortuneStone,
                Colors.amber,
                Icons.diamond_rounded,
                'Prosperity & Wealth',
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _stoneMiniCard(
                      'Life Stone',
                      gem.lifeStone,
                      Colors.orange,
                      Icons.favorite_rounded,
                      'Vitality & Energy',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _stoneMiniCard(
                      'Lucky Stone',
                      gem.luckyStone,
                      Colors.redAccent,
                      Icons.auto_awesome_rounded,
                      'Fortune & Success',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _stoneMiniCard(
                      'Fortune Stone',
                      gem.fortuneStone,
                      Colors.amber,
                      Icons.diamond_rounded,
                      'Prosperity & Wealth',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _stoneMiniCard(
    String title,
    String value,
    Color themeColor,
    IconData icon,
    String description,
  ) {
    final displayValue =
        (value.isEmpty || value == 'N/A') ? 'NOT FOUND' : value.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: themeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(GemModel gem) {
    return _buildBasicCard(
      'Name',
      '${gem.name}/${gem.otherName}',
      Icons.bolt,
      CustomStyles.callActionBlue,
      Colors.blue.shade200,
    );
  }

  Widget _buildGemCard(GemModel gem) {
    return _buildBasicCard(
      'Gem',
      gem.name.toLowerCase(),
      Icons.add,
      Colors.green,
      Colors.green.shade200,
      isCircleIcon: true,
    );
  }

  Widget _buildPlanetCard(GemModel gem) {
    return _buildBasicCard(
      'Planet',
      gem.planet,
      Icons.diamond,
      Colors.amber.shade700,
      Colors.amber.shade300,
    );
  }

  Widget _buildBasicCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color borderColor, {
    bool isCircleIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isCircleIcon)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration:
                      BoxDecoration(color: iconColor, shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 16),
                )
              else
                Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(GemModel gem) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                '${gem.gem.isNotEmpty ? gem.gem : 'Gem'} Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            gem.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrapCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerWeightCard(GemModel gem) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Finger and Weight:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _detailRow('Finger', gem.finger),
          const SizedBox(height: 12),
          _detailRow('Weight', gem.weight),
          const SizedBox(height: 12),
          _detailRow('Day', gem.day),
          const SizedBox(height: 12),
          _detailRow('Metal', gem.metal),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }

  Widget _buildFlawResultsCard(GemModel gem) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Flaw Results:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (gem.flawResults.isEmpty)
            const Text('No data')
          else
            Table(
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Effect',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
                ...gem.flawResults.map(
                  (flaw) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(flaw.flawType,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(flaw.flawEffects,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimeToWearCard(GemModel gem) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Time to wear',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
              children: [
                const TextSpan(
                  text: 'Time to wear short: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: gem.timeToWearShort.isNotEmpty
                        ? gem.timeToWearShort
                        : '—'),
                const TextSpan(text: '\n\n'),
                const TextSpan(
                  text: 'Time to wear: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: gem.timeToWear),
                const TextSpan(text: '\n\n'),
                const TextSpan(
                  text: 'Methods: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: gem.methods),
                const TextSpan(text: '\n\n'),
                const TextSpan(
                  text: 'Mantra: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: gem.mantra,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
