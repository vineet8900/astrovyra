import 'package:get/get.dart';

class AstrologerController extends GetxController {
  var astrologers = <Map<String, dynamic>>[].obs;
   var astrologerscategory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStaticData();
  }

  void loadStaticData() {
    astrologers.value = [
      {
        "name": "Rohit Aggarwal",
        "imageUrl": "https://randomuser.me/api/portraits/men/11.jpg",
        "languages": "English, Hindi, Marathi",
        "experience": "8 Years",
        "rating": 4.9,
        "price": "₹210/Min",
      },
      {
        "name": "Priya Sharma",
        "imageUrl": "https://randomuser.me/api/portraits/women/21.jpg",
        "languages": "Hindi, Tamil",
        "experience": "5 Years",
        "rating": 4.7,
        "price": "₹150/Min",
      },
      {
        "name": "Amit Verma",
        "imageUrl": "https://randomuser.me/api/portraits/men/31.jpg",
        "languages": "English, Hindi",
        "experience": "10 Years",
        "rating": 4.8,
        "price": "₹250/Min",
      },
      {
        "name": "Preeti Sharma",
        "imageUrl": "https://randomuser.me/api/portraits/women/21.jpg",
        "languages": "English, Hindi",
        "experience": "10 Years",
        "rating": 4.8,
        "price": "₹250/Min",
      },
    ];

   astrologerscategory.value = [
  {
    "category": "Love",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/833/833472.png"
  },
  {
    "category": "Career",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
  },
  {
    "category": "Marriage",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/3176/3176297.png"
  },
  {
    "category": "Health",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/3523/3523063.png"
  },
  {
    "category": "Education",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/3595/3595455.png"
  },
  {
    "category": "Finance",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/2620/2620453.png"
  },
  {
    "category": "Business",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/1055/1055644.png"
  },
  {
    "category": "Family",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/1828/1828884.png"
  },
  {
    "category": "Property",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/2329/2329070.png"
  },
  {
    "category": "Legal",
    "imageUrl": "https://cdn-icons-png.flaticon.com/512/944/944810.png"
  },
];

  }
}
