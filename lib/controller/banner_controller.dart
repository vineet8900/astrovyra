import 'package:astrokavach/api/auth_api/banner_api.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:get/get.dart';

class BannerController extends GetxController {
  var isLoading = false.obs;
  var bannerList = <BannerDatum>[].obs;

  final BannerApiService bannerapiService = BannerApiService();

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void fetchBanners() async {
    isLoading.value = true;
    final response = await bannerapiService.getbannerApi("home");
    if (response != null && response.data != null) {
      bannerList.value = response.data!;
    } else {
      bannerList.clear();
    }
    isLoading.value = false;
  }
}
