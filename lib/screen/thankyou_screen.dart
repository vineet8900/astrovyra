import 'package:flutter/material.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThankyouScreen extends StatefulWidget {
  String? msg;
  ThankyouScreen({super.key, this.msg});

  @override
  State<ThankyouScreen> createState() => _ThankyouScreenState();
}

class _ThankyouScreenState extends State<ThankyouScreen> {
  ReusableFunction reusableFunction = ReusableFunction();
  bool _isRefreshing = false;
  void initState() {
    super.initState();
    // ✅ Jab screen load ho, wallet refresh kar do
    _refreshWallet();
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? apiToken = prefs.getString('api_token');

      if (apiToken != null) {
        await reusableFunction.refreshUserDataFromServer(apiToken);
        
      }
    } catch (e) {
     
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.asset("assets/thankyou.png"),
            ),
            Text(
              "Thankyou",
              style: CustomStyles.black25600,
            ),
            Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                widget.msg ?? '',
                style: CustomStyles.black14600,
                textAlign: TextAlign.center,
              ),
            )),
            SizedBox(
              height: 20,
            ),
            CustomElevatedButton(
                text: "Back to Home",
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomAppBarScreen()));
                })
          ],
        ),
      ),
    );
  }
}
