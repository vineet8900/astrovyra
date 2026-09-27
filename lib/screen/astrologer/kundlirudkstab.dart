import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/rudramide.dart';
import 'package:flutter/material.dart';

class KundliRudrakshaTab extends StatefulWidget {
  final int kundaliId;
  const KundliRudrakshaTab({Key? key, required this.kundaliId})
      : super(key: key);

  @override
  State<KundliRudrakshaTab> createState() => _KundliRudrakshaTabState();
}

class _KundliRudrakshaTabState extends State<KundliRudrakshaTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  RudrakshModel? _cachedRudraksh;
  bool _isLoaded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOnce();
  }

  Future<void> _loadOnce() async {
    if (_isLoaded || _isLoading) return;
    setState(() => _isLoading = true);

    try {
      final data =
          await AstroApiService.getRudrakshSuggestion(widget.kundaliId);
      if (!mounted) return;
      setState(() {
        _cachedRudraksh = data;
        _isLoaded = true;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading || !_isLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: CustomStyles.callActionBlue),
      );
    }

    if (_cachedRudraksh == null) {
      return const Center(child: Text('No Rudraksha Suggestion Found'));
    }

    final data = _cachedRudraksh!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Rudraksha Recommendation',
          textAlign: TextAlign.center,
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
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 30),
        _infoCard(
          icon: Icons.bolt,
          iconColor: CustomStyles.callActionBlue,
          borderColor: CustomStyles.callActionBlue,
          title: 'Name',
          content: data.name,
        ),
        const SizedBox(height: 16),
        _infoCard(
          icon: Icons.add_circle_outline,
          iconColor: Colors.green,
          borderColor: Colors.green,
          title: 'For Disease Cure',
          content:
              data.diseaseCure.map((m) => '$m Mukhi Rudraksha').join(' , '),
        ),
        const SizedBox(height: 16),
        _infoCard(
          icon: Icons.diamond_outlined,
          iconColor: Colors.orange,
          borderColor: Colors.orange,
          title: 'For Money',
          content: data.forMoney.map((m) => '$m Mukhi Rudraksha').join(' , '),
        ),
        const SizedBox(height: 20),
        _descCard(
          icon: Icons.description,
          iconColor: CustomStyles.callActionBlue,
          borderColor: Colors.blue.shade200,
          title: 'Mukhi Description',
          content: data.description,
        ),
        const SizedBox(height: 20),
        _descCard(
          icon: Icons.bolt,
          iconColor: CustomStyles.callActionBlue,
          borderColor: Colors.blue.shade200,
          title: 'Bot Response',
          content: data.botResponse,
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _descCard({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String title,
    required String content,
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
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
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
}
