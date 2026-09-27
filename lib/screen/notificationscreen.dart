import 'package:flutter/material.dart';
import 'package:astrokavach/Services/notifationmodel.dart';
import 'package:astrokavach/api/notificationfile.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/orderscreen.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/astrologer/astrologer_detail_screen.dart';
import 'package:intl/intl.dart'; 


class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;
  int currentPage = 1;
  bool hasMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        _fetchNotifications(loadMore: true);
      }
    });
  }

  Future<void> _fetchNotifications({bool loadMore = false}) async {
    if (loadMore) {
      currentPage++;
    } else {
      setState(() => isLoading = true);
    }

    NotificationResponse? response =
        await NotificationApiService.fetchNotifications(page: currentPage);

    if (mounted) {
      setState(() {
        if (response != null && response.data != null) {
          if (loadMore) {
            notifications.addAll(response.data!.list);
          } else {
            notifications = response.data!.list;
          }
          hasMore = response.data!.hasMorePages;
        }
        isLoading = false;
      });
    }
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  String? _astrologerSlugFromLink(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;
    if (uri.pathSegments.isEmpty) return null;
    return uri.pathSegments.last.trim().isEmpty ? null : uri.pathSegments.last;
  }

  int? _orderIdFromLink(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;
    final segs = uri.pathSegments;
    for (var i = 0; i < segs.length; i++) {
      if (segs[i] == 'order' && i + 1 < segs.length) {
        final v = int.tryParse(segs[i + 1]);
        if (v != null) return v;
      }
    }
    if (segs.length >= 2 && segs.last == 'detail') {
      return int.tryParse(segs[segs.length - 2]);
    }
    return null;
  }

  void _handleNotificationTap(NotificationItem item) {
    final appLink = (item.appLink ?? '').trim();
    if (appLink.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Not available'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (appLink == 'astrologer_detail') {
      final slug = _astrologerSlugFromLink(item.link);
      if (slug == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not available'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AstrologerDetailScreen(slug: slug),
        ),
      );
      return;
    }

    if (appLink == 'order_history') {
      final orderId = _orderIdFromLink(item.link);
      if (orderId == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Not available'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const Orderscreen(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Not available'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        title: 'Notifications',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade300,
            height: 1.0,
          ),
        ),
      ),
      body: isLoading && notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    "No notifications found",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: notifications.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == notifications.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final item = notifications[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.grey.shade500,
                            width: 1,
                          )),
                      child: ListTile(
                        onTap: () => _handleNotificationTap(item),
                        leading: CircleAvatar(
                          backgroundColor: CustomStyles.callActionBlue,
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          item.message,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            formatDateTime(item.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: CustomStyles.detailsOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
