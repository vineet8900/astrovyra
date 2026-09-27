import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/kundalichange/kundalibasic.dart';
import 'package:astrokavach/model/kundalimodel/kundalicreate.dart';
import 'package:astrokavach/screen/astrologer/dashatab.dart';
import 'package:astrokavach/screen/astrologer/kundaliashtakavtab.dart';
import 'package:astrokavach/screen/astrologer/kundalibasicnew.dart';
import 'package:astrokavach/screen/astrologer/kundalierrorview.dart';
import 'package:astrokavach/screen/astrologer/kundalishimmer.dart';
import 'package:astrokavach/screen/astrologer/kundlidivisonalchart.dart';
import 'package:astrokavach/screen/astrologer/kundlidoshatab.dart';
import 'package:astrokavach/screen/astrologer/kundligemstone.dart';
import 'package:astrokavach/screen/astrologer/kundlihh.dart';
import 'package:astrokavach/screen/astrologer/kundlirudkstab.dart';
import 'package:astrokavach/screen/astrologer/kunlitranstab.dart';
import 'package:astrokavach/screen/tabs/astavargatab.dart';
import 'package:astrokavach/screen/tabs/basic_tab.dart';
import 'package:astrokavach/screen/tabs/chartstab.dart';
import 'package:astrokavach/screen/tabs/dashtab.dart';
import 'package:astrokavach/screen/tabs/kp_tab.dart';
import 'package:astrokavach/screen/tabs/kundlitab2.dart';
import 'package:astrokavach/screen/tabs/report_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

class KundliChartScreen extends StatefulWidget {
  final int kundaliId;

  const KundliChartScreen({Key? key, required this.kundaliId})
      : super(key: key);

  @override
  State<KundliChartScreen> createState() => _KundliChartScreenState();
}

class _KundliChartScreenState extends State<KundliChartScreen> {
  late Future<KundaliBasicResponse?> _basicFuture;

  @override
  void initState() {
    super.initState();
    _loadBasic();
  }

  void _loadBasic() {
    _basicFuture = AstroApiService.getKundaliBasic(widget.kundaliId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<KundaliBasicResponse?>(
      future: _basicFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.yellow.shade100,
              title: Text(
                'Loading Kundli...',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const KundliChartShimmerLoading(),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: CustomStyles.pinki,
              title: Text(
                'Error',
                style: TextStyle(color: Colors.black87, fontSize: 18),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: KundliChartErrorView(
              message: 'Network issue:',
              onRetry: () => setState(_loadBasic),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final basic = snapshot.data!;
          final titleName =
              (basic.name?.isNotEmpty == true) ? basic.name! : 'Kundli';

          return DefaultTabController(
            length: 9,
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                backgroundColor: CustomStyles.whiteColor,
                elevation: 1,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  '$titleName\'s Kundli',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.share_outlined, color: Colors.black),
                    onPressed: () {
                      Share.share(
                        '$titleName\'s Kundli Report\nhttps://harekrishnamart.in',
                      );
                    },
                  ),
                ],
                bottom: TabBar(
                  isScrollable: true,
                  indicatorColor: CustomStyles.callActionBlue,
                  labelColor: CustomStyles.callActionBlue,
                  unselectedLabelColor: Colors.grey[700],
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  labelPadding: EdgeInsets.symmetric(horizontal: 12),
                  tabs: const [
                    Tab(text: 'Basic Details'),
                    Tab(text: 'Kundli'),
                    Tab(text: 'Ashtakvarga'),
                    Tab(text: 'Dasha'),
                    Tab(text: 'Dosha'),
                    Tab(text: 'Charts'),
                    Tab(text: 'Transit'),
                    Tab(text: 'Gemstone'),
                    Tab(text: 'Rudraksha'),
                  ],
                ),
              ),
              body: SafeArea(
                child: TabBarView(
                  children: [
                    KundliBasicTab(basic: basic),
                    KundliKundliTab(
                      kundaliId: widget.kundaliId,
                      basic: basic,
                    ),
                    KundliAshtakvargaTab(kundaliId: widget.kundaliId),
                    KundliDashaTab(kundaliId: widget.kundaliId),
                    KundliDoshaTab(kundaliId: widget.kundaliId),
                    KundliDivisionalChartsTab(kundaliId: widget.kundaliId),
                    KundliTransitTab(kundaliId: widget.kundaliId),
                    KundliGemstoneTab(kundaliId: widget.kundaliId),
                    KundliRudrakshaTab(kundaliId: widget.kundaliId),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(body: Center(child: Text('Network issue')));
      },
    );
  }
}
