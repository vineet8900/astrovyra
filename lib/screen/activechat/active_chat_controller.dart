import 'dart:async';
import 'package:astrokavach/model/AIastrologermodel/aiastrologer.dart';
import 'package:astrokavach/screen/aichatscreen.dart';
import 'package:get/get.dart';

class ActiveChatController extends GetxController {
  // This will hold the astrologer with an active chat.
  // It's reactive, so the UI will update automatically.
  final Rx<AiAstrologer?> activeAstrologer = Rx<AiAstrologer?>(null);

  Timer? _disappearTimer;

  // Call this function to show the banner
  void showBanner(AiAstrologer astrologer) {
    // If a timer is already running, cancel it
    _disappearTimer?.cancel();

    // Set the active astrologer, which will make the banner appear
    activeAstrologer.value = astrologer;

    // Start a 15-second timer to hide the banner automatically
    _disappearTimer = Timer(const Duration(seconds: 15), () {
      hideBanner();
    });
  }

  // Call this function to hide the banner
  void hideBanner() {
    activeAstrologer.value = null;
    _disappearTimer?.cancel();
  }

  // Function to handle the "Join Chat" button press from the banner
  void joinChat() {
    if (activeAstrologer.value != null) {
      final astrologer = activeAstrologer.value!;
      // Hide the banner immediately
      hideBanner();
      // Navigate to the chat screen
      Get.to(() => KundliAIChatScreen(
            consultationId: astrologer.consultation!.id,
            astrologerName: astrologer.name,
          ));
    }
  }

  @override
  void onClose() {
    _disappearTimer?.cancel();
    super.onClose();
  }
}
