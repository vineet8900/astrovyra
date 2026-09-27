import 'package:astrokavach/controller/wallet_constroller/transaction_controller.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/screen/wallet/payment_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';

class TransactionScreen extends StatelessWidget {
  final TransactionController controller = Get.put(TransactionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Transactions"),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5)),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  title: Text(
                    'Available Balance',
                    style: CustomStyles.black14400,
                  ),
                  subtitle: Text('₹ 120', style: CustomStyles.black18600),
                  trailing: FittedBox(
                    child: GFButton(
                      onPressed: () {
                        Get.to(() => PaymentInformationScreen());
                      },
                      text: "Recharge",
                      color: CustomStyles.bgcolor,
                      textStyle: CustomStyles.black14600,
                      shape: GFButtonShape.standard,
                      fullWidthButton: false,
                      size: 36.8,
                    ),
                  ),
                )),
            SizedBox(
              height: 5,
            ),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: controller.transactionList.length,
                    itemBuilder: (context, index) {
                      final txn = controller.transactionList[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsetsDirectional.zero,
                            titleAlignment: ListTileTitleAlignment.titleHeight,
                            minVerticalPadding: 5,
                            title: Text(
                              txn.title,
                              style: CustomStyles.black14500,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  txn.subtitle1,
                                  style: CustomStyles.grey12400,
                                ),
                                Text(
                                  txn.subtitle2,
                                  style: CustomStyles.grey12400,
                                ),
                              ],
                            ),
                            trailing: Text(
                              '₹${txn.amount.toStringAsFixed(2)}',
                              style: CustomStyles.green14600,
                            ),
                            isThreeLine: true,
                          ),
                          Divider(
                            height: .1,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
