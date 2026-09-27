import 'package:astrokavach/controller/auth_controller/notification_controller.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Notifications",
        actions: [
          TextButton(
            onPressed: controller.clearAll,
            child: Text("Clear All", style: CustomStyles.black14500),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Obx(() {
          if (controller.notificationList.isEmpty) {
            return Center(
                child:
                    Text("No notifications", style: CustomStyles.black14600));
          }
          return ListView.builder(
            itemCount: controller.notificationList.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                shape: Border(bottom: BorderSide(color: Colors.black26)),
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/person.png'),
                      fit: BoxFit.fill,
                    ),
                    border: Border.all(color: Color(0xffFFAF12), width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  controller.notificationList[index],
                  style: CustomStyles.black12400,
                ),
                subtitle: Text(
                  'Aug 12, 2024 at 12:08 PM',
                  style: CustomStyles.grey12400,
                ),
                trailing: GestureDetector(
                  onTap: () => controller.deleteNotification(index),
                  child: Icon(Icons.delete, color: Colors.red, size: 20),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
