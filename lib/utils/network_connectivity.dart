import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Returns true when the device likely has internet access.
/// [Connectivity] is checked first so Wi‑Fi/mobile data is recognized even
/// when DNS to a single host (e.g. google.com) fails or times out.
/// DNS lookups are used only as a fallback when the OS reports no interface.
Future<bool> checkDeviceHasInternet() async {
  try {
    final results = await Connectivity().checkConnectivity();
    if (results.any((r) => r != ConnectivityResult.none)) {
      return true;
    }
  } catch (_) {
    // Fall through to DNS fallback.
  }
  return _dnsLookupReachable();
}

Future<bool> _dnsLookupReachable() async {
  const hosts = ['cloudflare.com', 'google.com', 'dns.google'];
  for (final host in hosts) {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException {
      continue;
    } on TimeoutException {
      continue;
    } catch (_) {
      continue;
    }
  }
  return false;
}
