import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import 'package:astrokavach/core/providers/bottom_nav_provider.dart';
import 'package:astrokavach/core/providers/auth_provider.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/custom_widgets/tab_transition_shimmer_overlay.dart';

import 'package:astrokavach/screen/astrologer/astrologer_list_screen.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:astrokavach/screen/livestreamscreen.dart';
import 'package:astrokavach/screen/product/product_category_screen.dart';

class BottomAppBarScreen extends ConsumerStatefulWidget {
  const BottomAppBarScreen({super.key});

  @override
  ConsumerState<BottomAppBarScreen> createState() => _BottomAppBarScreenState();
}

class _BottomAppBarScreenState extends ConsumerState<BottomAppBarScreen> {
  final List<Widget> screens = [
    HomeScreen(),
    const AstrologerListScreen(mode: "chat"),
    const AstrologerListScreen(mode: "call"),
    const LiveAstrologerListScreen(),
    const ProductCategoryScreen(),
  ];

  Future<void> _handleTabChange(int index) async {
    // Check auth for protected tabs
    if (index == 1 || index == 2 || index == 3) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.value ?? false;
      if (!isLoggedIn) {
        context.push('/login');
        return;
      }
    }
    
    // Change tab
    ref.read(bottomNavProvider.notifier).changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(bottomNavProvider);
    final navNotifier = ref.read(bottomNavProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        
        final shouldExit = navNotifier.onWillPop();
        if (!shouldExit) {
          if (navState.selectedIndex == 0) {
            Fluttertoast.showToast(
              msg: "Press back again to exit",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.black87,
              textColor: Colors.white,
            );
          }
        } else {
          // Force exit app (this is standard in flutter when physical back is pressed twice)
          Navigator.of(context).pop(); 
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            screens[navState.selectedIndex],
            
            if (navState.showTabTransitionShimmer)
              const Positioned.fill(
                child: IgnorePointer(
                  child: TabTransitionShimmerOverlay(),
                ),
              ),
          ],
        ),
        bottomNavigationBar: navState.isDrawerOpen 
          ? const SizedBox.shrink()
          : BottomNavigationBar(
              currentIndex: navState.selectedIndex,
              backgroundColor: CustomStyles.whiteColor,
              elevation: 10,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black,
              selectedLabelStyle: CustomStyles.black13600,
              unselectedLabelStyle: CustomStyles.black12500,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              onTap: _handleTabChange,
              items: const [
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/homepart2.png")),
                  label: 'Home', // Hardcoded english to remove GetX translation dependency
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/ChatDots.png")),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/CALL2.png")),
                  label: 'Call',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/livecall.png")),
                  label: 'Live',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage("assets/shop2.png")),
                  label: 'Shop',
                ),
              ],
            ),
      ),
    );
  }
}
