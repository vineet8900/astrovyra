import 'package:astrokavach/custom_widgets/orderscreen.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/Transactionhistory.dart';
import 'package:astrokavach/screen/Wishlistr/wishlistr.dart';
import 'package:astrokavach/screen/address/manage_screen.dart';
import 'package:astrokavach/screen/auth/intro_screen.dart';
import 'package:astrokavach/screen/auth/login_screen.dart';
import 'package:astrokavach/screen/auth/profile_screen.dart';
import 'package:astrokavach/screen/supportscreen.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_consulting_screen.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_dashboard_screen.dart';
import 'package:astrokavach/screen/user_dashboard_screen/user_wallet_history_screen.dart';
import 'package:astrokavach/screen/suggested_remedies_screen.dart';
import 'package:astrokavach/screen/bookpooja/pooja_list_screen.dart';
import 'package:astrokavach/screen/notificationscreen.dart';
import 'package:astrokavach/screen/newsletter_screen.dart';
import 'package:astrokavach/screen/legal_policies_screen.dart';
import 'package:astrokavach/screen/my_kundli_list_screen.dart';
import 'package:astrokavach/screen/refer_earn_screen.dart';
import 'package:astrokavach/screen/earnings_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchSocialUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _shareAppText() {
  Share.share('${'drawer_share_app'.tr}\n${CustomStyles.webBaseUrl}');
}

void _shareOnWhatsApp() {
  final text = Uri.encodeComponent(
    '${'drawer_share_app'.tr}\n${CustomStyles.webBaseUrl}',
  );
  _launchSocialUrl('https://wa.me/?text=$text');
}

class CustomDrawer extends StatelessWidget {
  final Map<String, dynamic>? user;
  final String? apiToken;
  final Function(Map<String, dynamic>) onUserDataUpdate;

  const CustomDrawer({
    super.key,
    required this.user,
    required this.apiToken,
    required this.onUserDataUpdate,
  });

  Future<void> logoutUser(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    onUserDataUpdate({});
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const IntroScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ReusableFunction reusableFunction = ReusableFunction();

    final double screenW = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: screenW * 0.7,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, reusableFunction),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.grid_view_outlined,
                    title: 'Dashboard',
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const UserDashboardScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline,
                    title: 'my_profile'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        ProfileScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: 'address_book'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        ManageAddressAscreen(),
                        apiToken.toString(),
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/mic.png",
                    title: 'consultation'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        UserConsultingListScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/wallet.png",
                    title: 'wallet'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const WalletHistoryScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/supportremove.png",
                    title: 'support'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        SupportScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/ONLINE-PAYMENT.png",
                    title: 'transaction_history'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        Transactionhistory(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/ordeera.png",
                    title: 'my_order'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        Orderscreen(),
                        apiToken.toString(),
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    leading: Image.asset(
                      "assets/akash12.png",
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      color: Colors.black,
                    ),
                    title: 'my_kundli'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const MyKundliListScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/wishlistpage.png",
                    title: 'wishlist'.tr,
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        Wishlistr(),
                        apiToken.toString(),
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/heart-pulse.png",
                    title: 'Suggested Remedies',
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const SuggestedRemediesScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.event_available_outlined,
                    title: 'Booked Puja',
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        PoojaListScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.notifications_outlined,
                    title: 'Notification',
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const NotificationListScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    iconPath: "assets/newspaper.png",
                    title: 'Newsletter',
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const NewsletterScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    leading: Icon(
                      Icons.card_giftcard_outlined,
                      color: CustomStyles.callActionBlue,
                      size: 22,
                    ),
                    title: 'Refer & Earn',
                    onTap: () {
                      reusableFunction.navigateIfNotLoggedIn(
                        context,
                        const ReferEarnScreen(),
                        apiToken,
                        onUserDataUpdate,
                      );
                    },
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    leading: const Icon(
                      Icons.share_rounded,
                      color: Colors.orange,
                      size: 22,
                    ),
                    title: 'drawer_share_app'.tr,
                    onTap: _shareAppText,
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    leading: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Color(0xFF25D366),
                      size: 22,
                    ),
                    title: 'drawer_share_whatsapp'.tr,
                    onTap: _shareOnWhatsApp,
                  ),
                  _divider(),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'drawer_privacy_policy'.tr,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const LegalPoliciesScreen(
                            initialSelectedIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  _divider(fullWidth: true),
                  apiToken == null ||
                          apiToken!.isEmpty ||
                          apiToken!.length == 12
                      ? _buildDrawerItem(
                          context: context,
                          icon: Icons.login,
                          title: 'login'.tr,
                          color: Colors.green,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(
                                  redirectScreen: null,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildDrawerItem(
                          context: context,
                          icon: Icons.logout,
                          title: 'logout'.tr,
                          color: Colors.red,
                          onTap: () {
                            showLogoutDialog(context);
                          },
                        ),
                ],
              ),
            ),
            _buildFollowUsFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUsFooter(BuildContext context) {
    const double socialDiameter = 26;
    const double innerIcon = 12;
    const double iconGap = 2;
    final String base = CustomStyles.webBaseUrl;
    final double bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 4, 12, 34 + bottomSafe),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'drawer_follow_us'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _socialCircle(
                        diameter: socialDiameter,
                        background: const Color(0xFF1877F2),
                        child: FaIcon(
                          FontAwesomeIcons.facebookF,
                          color: Colors.white,
                          size: innerIcon,
                        ),
                        onTap: () => _launchSocialUrl('$base'),
                      ),
                      SizedBox(width: iconGap),
                      _instagramCircle(
                        diameter: socialDiameter,
                        iconSize: innerIcon,
                        onTap: () => _launchSocialUrl('$base'),
                      ),
                      SizedBox(width: iconGap),
                      _socialCircle(
                        diameter: socialDiameter,
                        background: const Color(0xFFFF0000),
                        child: FaIcon(
                          FontAwesomeIcons.youtube,
                          color: Colors.white,
                          size: innerIcon,
                        ),
                        onTap: () => _launchSocialUrl('$base'),
                      ),
                      SizedBox(width: iconGap),
                      _socialCircle(
                        diameter: socialDiameter,
                        background: const Color(0xFF0A66C2),
                        child: FaIcon(
                          FontAwesomeIcons.linkedinIn,
                          color: Colors.white,
                          size: innerIcon,
                        ),
                        onTap: () => _launchSocialUrl('$base'),
                      ),
                      SizedBox(width: iconGap),
                      _socialCircle(
                        diameter: socialDiameter,
                        background: const Color(0xFF25D366),
                        child: FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: innerIcon,
                        ),
                        onTap: () => _launchSocialUrl('$base'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'V1.0.14',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialCircle({
    required double diameter,
    required Color background,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _instagramCircle({
    required double diameter,
    required double iconSize,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: diameter,
      height: diameter,
      child: Material(
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF833AB4),
                  Color(0xFFE1306C),
                  Color(0xFFF77737),
                ],
              ),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.instagram,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const Color _drawerIconTint = Color(0xFF212121);
  static const Color _drawerTitleTint = Color(0xFF263238);
  static const Color _drawerDividerColor = Color(0xFFB0BEC5);
  static const double _drawerHorizontalPadding = 8;
  static const double _drawerDividerLeading = 18;

  Widget _divider({bool fullWidth = false}) {
    return Padding(
      padding: EdgeInsets.only(left: fullWidth ? 0 : _drawerDividerLeading),
      child: SizedBox(
        height: 1,
        width: double.infinity,
        child: const ColoredBox(color: _drawerDividerColor),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReusableFunction reusableFunction) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey.shade300,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Astrokavach",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    image: user != null &&
                            user!['image'] != null &&
                            user!['image'].toString().isNotEmpty &&
                            user!['image'] != 'null'
                        ? DecorationImage(
                            image: NetworkImage(user!['image'].toString()),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: user == null ||
                            user!['image'] == null ||
                            user!['image'].toString().isEmpty ||
                            user!['image'] == 'null'
                        ? Colors.grey.shade200
                        : null,
                  ),
                  child: user == null ||
                          user!['image'] == null ||
                          user!['image'].toString().isEmpty ||
                          user!['image'] == 'null'
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade700,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${user != null && user!.isNotEmpty && user!['name'] != null ? user!['name'] : 'Welcome Guest!'}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              reusableFunction.navigateIfNotLoggedIn(
                                context,
                                ProfileScreen(),
                                apiToken,
                                onUserDataUpdate,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (user != null && user!['phone'] != null)
                        Text(
                          user!['phone'].toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerStaticRow({
    required Widget leading,
    required String title,
    FontWeight titleFontWeight = FontWeight.w500,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _drawerHorizontalPadding,
        vertical: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            child: Center(child: leading),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: titleFontWeight,
                  color: _drawerTitleTint,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    IconData? icon,
    String? iconPath,
    Widget? leading,
    required String title,
    required VoidCallback onTap,
    Color? color,
    FontWeight titleFontWeight = FontWeight.w500,
  }) {
    assert(
      leading != null || icon != null || iconPath != null,
      'Provide leading, icon, or iconPath',
    );
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _drawerHorizontalPadding,
          vertical: 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              child: leading != null
                  ? Center(child: leading)
                  : icon != null
                      ? Icon(icon, color: color ?? _drawerIconTint, size: 22)
                      : Image.asset(
                          iconPath!,
                          color: color ?? _drawerIconTint,
                          width: 22,
                          height: 22,
                        ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: titleFontWeight,
                    color: color ?? _drawerTitleTint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'logout'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'logout_confirm'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        side: BorderSide(color: Colors.grey.shade500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await logoutUser(context);
                        try {
                          final sharedPreferences =
                              await SharedPreferences.getInstance();
                          await sharedPreferences.remove("api_token");
                          await sharedPreferences.remove("user");
                          await sharedPreferences.remove("wallet");
                          await sharedPreferences.clear();
                          onUserDataUpdate({});
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const IntroScreen()),
                            (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const IntroScreen()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'logout'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
