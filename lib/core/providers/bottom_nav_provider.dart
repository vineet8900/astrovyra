import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavState {
  final int selectedIndex;
  final bool isDrawerOpen;
  final bool showTabTransitionShimmer;

  BottomNavState({
    this.selectedIndex = 0,
    this.isDrawerOpen = false,
    this.showTabTransitionShimmer = false,
  });

  BottomNavState copyWith({
    int? selectedIndex,
    bool? isDrawerOpen,
    bool? showTabTransitionShimmer,
  }) {
    return BottomNavState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      showTabTransitionShimmer: showTabTransitionShimmer ?? this.showTabTransitionShimmer,
    );
  }
}

class BottomNavNotifier extends Notifier<BottomNavState> {
  @override
  BottomNavState build() => BottomNavState();

  Timer? _tabShimmerTimer;
  DateTime? lastBackPressed;

  void setDrawerOpen(bool value) {
    state = state.copyWith(isDrawerOpen: value);
  }

  void changeIndex(int index) {
    if (state.selectedIndex != index) {
      state = state.copyWith(selectedIndex: index);
      _runTabTransitionShimmer();
    }
  }

  void _runTabTransitionShimmer() {
    _tabShimmerTimer?.cancel();
    state = state.copyWith(showTabTransitionShimmer: true);
    _tabShimmerTimer = Timer(const Duration(milliseconds: 520), () {
      state = state.copyWith(showTabTransitionShimmer: false);
    });
  }

  bool onWillPop() {
    if (state.selectedIndex != 0) {
      changeIndex(0);
      return false;
    }

    DateTime now = DateTime.now();
    if (lastBackPressed == null || now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;
      return false; // Let the UI show toast
    }
    return true; // Exit app
  }
}

final bottomNavProvider = NotifierProvider<BottomNavNotifier, BottomNavState>(() {
  return BottomNavNotifier();
});
