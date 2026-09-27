import 'package:get/get.dart';

class TransactionController extends GetxController {
  var transactionList = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
  
    transactionList.addAll([
      TransactionModel(
        title: 'Chat with Astrologer for 25 Minutes',
        subtitle1: 'Oct 14, 10:24 AM',
        subtitle2: '#CHAT_NS8988383',
        amount: 1699.00,
      ),
      TransactionModel(
        title: 'Chat with Astrologer for 15 Minutes',
        subtitle1: 'Oct 13, 10:14 AM',
        subtitle2: '#CHAT_NS8988383',
        amount: 1400.00,
      ),
      TransactionModel(
        title: 'Chat with Astrologer for 50 Minutes',
        subtitle1: 'Oct 11, 10:29 AM',
        subtitle2: '#CHAT_NS8988383',
        amount: 1489.00,
      ),
      TransactionModel(
        title: 'Chat with Astrologer for 5 Minutes',
        subtitle1: 'Oct 17, 11:24 AM',
        subtitle2: '#CHAT_NS8988383',
        amount: 56.00,
      ),
      TransactionModel(
        title: 'Chat with Astrologer for 25 Minutes',
        subtitle1: 'Oct 12, 9:24 AM',
        subtitle2: '#CHAT_NS8988383',
        amount: 40.00,
      ),
    ]);
  }
}
class TransactionModel {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final double amount;

  TransactionModel({
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.amount,
  });
}
