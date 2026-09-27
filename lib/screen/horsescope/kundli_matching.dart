// lib/screen/kundli_matching_screen.dart

import 'package:flutter/material.dart';

class KundliMatchingScreen extends StatefulWidget {
  const KundliMatchingScreen({super.key});

  @override
  State<KundliMatchingScreen> createState() => _KundliMatchingScreenState();
}

class _KundliMatchingScreenState extends State<KundliMatchingScreen> {
  // Controllers for Boy's details
  final _boyNameController = TextEditingController(text: 'Rohit');
  final _boyDayController = TextEditingController(text: '03');
  final _boyMonthController = TextEditingController(text: '12');
  final _boyYearController = TextEditingController(text: '2001');
  final _boyHourController = TextEditingController(text: '09');
  final _boyMinuteController = TextEditingController(text: '30');
  final _boySecondController = TextEditingController(text: '30');
  final _boyPlaceController = TextEditingController(text: 'Faridabad (Haryana)');

  // Controllers for Girl's details
  final _girlNameController = TextEditingController(text: 'XXXX');
  final _girlDayController = TextEditingController(text: '03');
  final _girlMonthController = TextEditingController(text: '12');
  final _girlYearController = TextEditingController(text: '2001');
  final _girlHourController = TextEditingController(text: '09');
  final _girlMinuteController = TextEditingController(text: '30');
  final _girlSecondController = TextEditingController(text: '30');
  final _girlPlaceController = TextEditingController(text: 'Faridabad (Haryana)');

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed.
    _boyNameController.dispose();
    _boyDayController.dispose();
    _boyMonthController.dispose();
    _boyYearController.dispose();
    _boyHourController.dispose();
    _boyMinuteController.dispose();
    _boySecondController.dispose();
    _boyPlaceController.dispose();

    _girlNameController.dispose();
    _girlDayController.dispose();
    _girlMonthController.dispose();
    _girlYearController.dispose();
    _girlHourController.dispose();
    _girlMinuteController.dispose();
    _girlSecondController.dispose();
    _girlPlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.black12,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Kundli Matching',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 28),
            onPressed: () {
              // Search functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Boy's Details Section
              _buildDetailsSection(
                title: "Enter Boy's Details",
                iconPath: 'assets/boyshaadi2.jpg', // Apni image ka path yahan daalein
                nameController: _boyNameController,
                dayController: _boyDayController,
                monthController: _boyMonthController,
                yearController: _boyYearController,
                hourController: _boyHourController,
                minuteController: _boyMinuteController,
                secondController: _boySecondController,
                placeController: _boyPlaceController,
              ),
              const SizedBox(height: 24),
              // Girl's Details Section
              _buildDetailsSection(
                title: "Enter Girl's Details",
                iconPath: 'assets/girlbribe.jpg', // Apni image ka path yahan daalein
                nameController: _girlNameController,
                dayController: _girlDayController,
                monthController: _girlMonthController,
                yearController: _girlYearController,
                hourController: _girlHourController,
                minuteController: _girlMinuteController,
                secondController: _girlSecondController,
                placeController: _girlPlaceController,
              ),
              const SizedBox(height: 24),

              // Match Your Kundli Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Match Your Kundli',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Information Section
              _buildInformationSection(),

              const SizedBox(height: 32),

              // FAQ Section
              _buildFaqSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable widget for Boy/Girl details form
  Widget _buildDetailsSection({
    required String title,
    required String iconPath,
    required TextEditingController nameController,
    required TextEditingController dayController,
    required TextEditingController monthController,
    required TextEditingController yearController,
    required TextEditingController hourController,
    required TextEditingController minuteController,
    required TextEditingController secondController,
    required TextEditingController placeController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Agar aapke paas image asset hai to Image.asset use karein
             Image.asset(iconPath, height: 40, width: 40, errorBuilder: (context, error, stackTrace) {
               // Agar image load na ho to placeholder icon dikhayega
               return Icon(Icons.person, size: 40, color: Colors.orange.shade800);
             }),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabeledTextField("Name", nameController),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledTextField("Day", dayController)),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledTextField("Month", monthController)),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledTextField("Year", yearController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLabeledTextField("Hours", hourController)),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledTextField("Minutes", minuteController)),
            const SizedBox(width: 16),
            Expanded(child: _buildLabeledTextField("Seconds", secondController)),
          ],
        ),
        const SizedBox(height: 16),
        _buildLabeledTextField("Place of Birth", placeController),
      ],
    );
  }

  // Reusable widget for a label and text field
  Widget _buildLabeledTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          keyboardType: label.contains("Name") || label.contains("Place")
              ? TextInputType.text
              : TextInputType.number,
        ),
      ],
      
    );
    
  }
  
  
  // Widget for "What is Kundali Matching"
  Widget _buildInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is Kundali Matching for Marriage?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          'Marriage marks a turning point in the lives of two people and their families. This beautiful relationship ties two souls together for a lifetime and beyond. It is a new beginning, one for which every individual has waited since they reach an age when they feel ready to commit. We often see various rituals before a Hindu marriage takes place. From quite an early stage, certain rituals are performed. Many families, before deciding to get their children married, match their detailed birth charts to see whether their stars are compatible or not.',
          style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 15),
          textAlign: TextAlign.justify,
        ),
         const SizedBox(height: 24),
         const Text(
          'So what does this Kundli matching mean? What does it say? Is it really',
           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Text(
          "Kundli matching for marriage is an important step in Indian households because people have immense faith in the 'Kundli Milan' ritual of Vedic astrology. Here, Moon's placement plays a very important role. Moon's placement in the horoscope provides the astrologers with the 'Janam Rashi '(Moon Sign) and 'Nakshatra' (Constellation) of the native, which are two key aspects of Vedic Astrology.",
          style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 15),
          textAlign: TextAlign.justify,
        )
      ],
    );
  }
  
  // Widget for FAQ section using ExpansionTile
  Widget _buildFaqSection() {
    return Column(
      children: [
        _buildExpansionTile(
          title: 'What is Janam Kundli?',
          content: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvina.',
          isInitiallyExpanded: true, // Pehla item by default khula rahega
        ),
        _buildExpansionTile(
          title: 'Can astrology predict future accurately?',
          content: 'Astrology offers insights and probabilities, not absolute predictions. It acts as a guide to help you make informed decisions.',
        ),
        _buildExpansionTile(
          title: 'Which is the most accurate Kundli software?',
          content: 'The accuracy depends on the underlying astrological algorithms and data. Many professional software options are available, each with its strengths.',
        ),
        _buildExpansionTile(
          title: 'What is Navamsa chart?',
          content: 'The Navamsa chart, or D9 chart, is a divisional chart that provides deep insights into the marriage, spouse, and overall fortune of an individual.',
        ),
        _buildExpansionTile(
          title: 'What is Lagna chart?',
          content: 'The Lagna chart, or D1 chart, is the main birth chart which represents the physical self, personality, and overall life path.',
        ),
        SizedBox(height: 120,)
      ],
    );
  }

  // Reusable widget for a styled ExpansionTile
  Widget _buildExpansionTile({required String title, required String content, bool isInitiallyExpanded = false}) {
     return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: isInitiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: TextStyle(color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}