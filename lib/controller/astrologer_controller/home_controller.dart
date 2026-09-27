import 'package:astrokavach/api/auth_api/banner_api.dart';
import 'package:astrokavach/model/banner_api_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var bannerList = <BannerDatum>[].obs;
  final BannerApiService bannerapiService = BannerApiService();
  void fetchBanners() async {
    final response = await bannerapiService.getbannerApi("home");
    if (response != null && response.data != null) {
      bannerList.value = response.data!;
    } else {
      bannerList.clear();
    }
  }

  var blogList = <Map<String, String>>[].obs;
  void loadBlogs() {
    blogList.value = [
      {
        "title": "Astro Remedies for Success",
        "desc": "Explore powerful remedies based on astrology...",
        "image":
            "https://images.pexels.com/photos/5904933/pexels-photo-5904933.jpeg"
      },
      {
        "title": "Kundli Dosha Explained",
        "desc": "Understand Mangal Dosha and other key defects...",
        "image":
            "https://images.pexels.com/photos/3648220/pexels-photo-3648220.jpeg"
      },
      {
        "title": "Gemstone Power",
        "desc": "How gemstones affect your chakras and life...",
        "image":
            "https://images.pexels.com/photos/6765631/pexels-photo-6765631.jpeg"
      },
    ];
  }

  var kundliList = <KundliItem>[
    KundliItem(name: "Kundli", iconPath: "assets/horoscope.png"),
    KundliItem(name: "Match Making", iconPath: "assets/kundli.png"),
    KundliItem(name: "Horoscope", iconPath: "assets/free.png"),
    KundliItem(name: "Palmistry", iconPath: "assets/kundli.png"),
  ].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    fetchBanners();
    loadBlogs();
    super.onInit();
  }
}

class KundliItem {
  final String name;
  final String iconPath;

  KundliItem({required this.name, required this.iconPath});
}
