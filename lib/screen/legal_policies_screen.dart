import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/model/pages/pages_list_model.dart';
import 'package:astrokavach/screen/astrologer_privacy_policy_screen.dart';
import 'package:astrokavach/screen/dynamic_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LegalPoliciesScreen extends StatefulWidget {
  const LegalPoliciesScreen({super.key, this.initialSelectedIndex = 0});

  final int initialSelectedIndex;

  @override
  State<LegalPoliciesScreen> createState() => _LegalPoliciesScreenState();
}

class _LegalPoliciesScreenState extends State<LegalPoliciesScreen> {
  static const Color _iconColor = Colors.black87;

  late Future<List<PageItem>> _pagesFuture;

  @override
  void initState() {
    super.initState();
    _pagesFuture = _loadPages();
  }

  Future<List<PageItem>> _loadPages() async {
    final res = await AstroApiService.fetchPagesList(appType: 'customer');
    final items = res?.data ?? <PageItem>[];
    return items.where((e) {
      final s = e.slug.trim().toLowerCase();
      if (s == 'privacy-policy') return false;
      if (s == 'terms-condition') return false;
      return e.title.trim().isNotEmpty;
    }).toList();
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade700,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'policy_delete_account_message'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'cancel'.tr,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await AstroApiService.requestAccountDelete();
              },
              child: Text('yes'.tr),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final staticItems = <_PolicyItem>[
      _PolicyItem(title: 'drawer_privacy_policy'.tr, icon: _shieldLockIcon()),
      _PolicyItem(
        title: 'policy_terms_conditions'.tr,
        icon: const Icon(Icons.article_outlined, color: _iconColor, size: 22),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'policy_menu_title'.tr,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: FutureBuilder<List<PageItem>>(
        future: _pagesFuture,
        builder: (context, snap) {
          final dynamicItems = snap.data ?? const <PageItem>[];
          final total = staticItems.length + dynamicItems.length + 1;
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: total,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade300,
              ),
            ),
            itemBuilder: (context, index) {
              if (index == total - 1) {
                return Material(
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _showDeleteAccountDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red.shade700,
                                    width: 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'policy_delete_my_account'.tr,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (index < staticItems.length) {
                final item = staticItems[index];
                return _PolicyTile(
                  title: item.title,
                  icon: item.icon,
                  selected: false,
                  onTap: () {
                    if (index == 0) {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const AstrologerPrivacyPolicyScreen(),
                        ),
                      );
                    } else {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DynamicPageScreen(
                            title: item.title,
                            slug: 'terms-condition',
                          ),
                        ),
                      );
                    }
                  },
                );
              }

              final page = dynamicItems[index - staticItems.length];
              return _PolicyTile(
                title: page.title,
                icon:
                    Icon(_iconForSlug(page.slug), color: _iconColor, size: 22),
                selected: false,
                onTap: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DynamicPageScreen(
                        title: page.title,
                        slug: page.slug,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  static Widget _shieldLockIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_outlined, color: _iconColor, size: 26),
          Icon(Icons.lock_outline, color: _iconColor, size: 11),
        ],
      ),
    );
  }

  static IconData _iconForSlug(String slug) {
    final s = slug.trim().toLowerCase();
    if (s == 'about-us' || s == 'about' || s == 'aboutus') {
      return Icons.info_outline;
    }
    if (s == 'privacy-policy') return Icons.privacy_tip_outlined;
    if (s == 'terms-condition' || s == 'terms-and-conditions') {
      return Icons.article_outlined;
    }
    if (s.contains('refund') && s.contains('store')) {
      return Icons.store_outlined;
    }
    if (s.contains('refund') ||
        s.contains('cancellation') ||
        s.contains('cancel')) {
      return Icons.currency_rupee_outlined;
    }
    if (s.contains('shipping') || s.contains('delivery')) {
      return Icons.local_shipping_outlined;
    }
    if (s.contains('disclaimer')) return Icons.gavel_outlined;
    if (s.contains('contact')) return Icons.support_agent_outlined;
    if (s.contains('faq')) return Icons.help_outline;
    return Icons.description_outlined;
  }
}

class _PolicyItem {
  _PolicyItem({
    required this.title,
    required this.icon,
  });

  final String title;
  final Widget icon;
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.grey.shade200,
                      Colors.white,
                    ],
                  )
                : null,
            color: selected ? null : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
