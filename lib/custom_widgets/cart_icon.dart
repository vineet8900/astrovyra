import 'package:astrokavach/api/product_api/AddToCartApi.dart/cart_list_api.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/screen/product/cart_screen.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


ValueNotifier<String> cartQuantityNotifier = ValueNotifier<String>("0");


class CartIcon extends StatefulWidget {
  const CartIcon({Key? key}) : super(key: key);

  static Widget appBarAction() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: CartIcon(),
    );
  }

  @override
  _CartIconState createState() => _CartIconState();
}

class _CartIconState extends State<CartIcon> {
  VoidCallback? _refreshCartListener;

  @override
  void initState() {
    super.initState();
    getInitialCartList();
    _refreshCartListener = () {
      if (mounted) getInitialCartList();
    };
    refreshHomeAfterLoginNotifier.addListener(_refreshCartListener!);
  }

  @override
  void dispose() {
    if (_refreshCartListener != null) {
      refreshHomeAfterLoginNotifier.removeListener(_refreshCartListener!);
    }
    super.dispose();
  }

  Future<void> getInitialCartList() async {
    try {
      await ensureGuestToken();
      final prefs = await SharedPreferences.getInstance();
      final String? apiToken = prefs.getString('api_token');

      if (apiToken == null || apiToken.isEmpty) {
        cartQuantityNotifier.value = "0";
        return;
      }

      final cartListModel =
          await CartListApiService().getCartlistapi(apiToken, 0);

      if (mounted) {
        final newQuantity = cartListModel?.totalQuantity?.toString() ?? '0';
        // Actualiza el notificador global con el valor inicial.
        cartQuantityNotifier.value = newQuantity;
      }
    } catch (e) {
      if (mounted) {
        cartQuantityNotifier.value = "0";
      }
      debugPrint("Error fetching initial cart list: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navega a la pantalla del carrito y, cuando regreses,
        // actualiza el conteo por si hubo cambios.
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CartScreen()),
        );
        getInitialCartList();
      },
      child: SizedBox(
        width: 30,
        child: Stack(
          children: [
            Image.asset(
              "assets/cart.png",
              scale: 3.5,
              color: Colors.black,
            ),
       
            ValueListenableBuilder<String>(
              valueListenable: cartQuantityNotifier,
              builder: (context, currentQuantity, child) {
      
                return (currentQuantity != "0" && currentQuantity.isNotEmpty)
                    ? Positioned(
                        right: 0,
                        top: 0,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Colors.red,
                          child: Text(
                            currentQuantity,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      )
                    : const SizedBox
                        .shrink(); // Usa SizedBox.shrink() para no renderizar nada.
              },
            ),
          ],
        ),
      ),
    );
  }
}
