import 'dart:async';

import 'package:astrokavach/Routes/app_routes.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountDeleteWatcher with WidgetsBindingObserver {
  AccountDeleteWatcher._();

  static final AccountDeleteWatcher instance = AccountDeleteWatcher._();

  Timer? _timer;
  bool _running = false;
  bool _checking = false;
  Duration _interval = const Duration(seconds: 15);

  Future<void> start() async {
    if (_running) return;
    _running = true;
    WidgetsBinding.instance.addObserver(this);
    await _tick(immediate: true);
    _schedule();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void _schedule() {
    _timer?.cancel();
    if (!_running) return;
    _timer = Timer(_interval, () async {
      await _tick();
      _schedule();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_running) return;
    if (state == AppLifecycleState.resumed) {
      _checking = false;
      _timer?.cancel();
      _timer = null;
      Future.microtask(() async {
        await _tick(immediate: true);
        if (_running) _schedule();
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _tick({bool immediate = false}) async {
    if (!_running) return;
    if (_checking) return;
    _checking = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('api_token');
      if (token == null || token.isEmpty) {
        return;
      }

      final accepted = await AstroApiService.fetchDeleteRequestAccepted();
      if ((accepted ?? 0) == 1) {
        debugPrint('[AccountDeleteWatcher] logout delete_request_accepted=1');
        stop();
        await prefs.clear();
        void goIntro() {
          Get.offAllNamed(AppRoutes.intro);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            SchedulerBinding.instance.scheduleFrameCallback((_) {
              goIntro();
            });
          });
        });
        return;
      }

      if (immediate) {
        _interval = const Duration(seconds: 15);
      } else {
        if (_interval < const Duration(minutes: 3)) {
          _interval = Duration(
            seconds: (_interval.inSeconds + 30).clamp(30, 180),
          );
        } else {
          _interval = const Duration(minutes: 3);
        }
      }
    } catch (_) {
      _interval = const Duration(minutes: 3);
    } finally {
      _checking = false;
    }
  }
}
