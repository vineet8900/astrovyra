import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:astrokavach/api/astro_listing_api.dart';
import 'package:astrokavach/model/astrologer/astro_list_model.dart';

/// Provider for the Astrologer API Service
final astrologerApiServiceProvider = Provider((ref) => AstrologerApiService());

/// FutureProvider to fetch the list of Astrologers for the Home Screen.
/// Caches the result using keepAlive.
final homeAstrologersProvider = FutureProvider<List<AstroDataList>>((ref) async {
  ref.keepAlive();
  
  final api = ref.read(astrologerApiServiceProvider);
  final model = await api.fetchAstrologers(
    "", "", '', [], [], [], [], [], [], '', 1,
    sortBy: '',
  );
  
  return model?.data?.list ?? [];
});

/// We can derive Live Astrologers from the main list.
final liveAstrologersProvider = Provider<List<AstroDataList>>((ref) {
  final asyncList = ref.watch(homeAstrologersProvider);
  return asyncList.maybeWhen(
    data: (list) {
      return list.where((a) => a.isLive == 1 || (a.status?.toLowerCase() == 'scheduled')).toList();
    },
    orElse: () => [],
  );
});

/// We can derive AI Astrologers from the main list.
final aiAstrologersProvider = Provider<List<AstroDataList>>((ref) {
  final asyncList = ref.watch(homeAstrologersProvider);
  return asyncList.maybeWhen(
    data: (list) {
      return list.where((a) => a.isAi == 1).toList();
    },
    orElse: () => [],
  );
});
