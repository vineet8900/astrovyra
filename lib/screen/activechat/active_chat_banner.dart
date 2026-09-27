import 'package:astrokavach/model/AIastrologermodel/aiastrologer.dart';
import 'package:astrokavach/screen/activechat/active_chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:jyotish_setu/controllers/active_chat_controller.dart';

class ActiveChatBanner extends StatelessWidget {
  final AiAstrologer astrologer;
  final ActiveChatController controller = Get.find();

  ActiveChatBanner({Key? key, required this.astrologer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use Material widget to ensure text and button styles are applied correctly
    return Material(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.yellow.shade600, // Color similar to the screenshot
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(astrologer.image),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    astrologer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    "Your consultation is ongoing",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Call the controller function to join the chat
                controller.joinChat();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Join Chat"),
            ),
          ],
        ),
      ),
    );
  }
}
