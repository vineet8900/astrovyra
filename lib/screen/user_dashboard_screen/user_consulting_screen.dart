import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:astrokavach/api/dashboard/user_consultation_api.dart';
import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/astro_detail_model.dart';
import 'package:astrokavach/model/user_dashboard_model/user_consultation_model.dart';
import 'package:astrokavach/screen/astrologer/consultation/chat_screen.dart';
import 'package:astrokavach/screen/astrologer/home_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConsultingListScreen extends StatefulWidget {
  String? consultationtype;
  int? selectindex;
  UserConsultingListScreen(
      {super.key, this.consultationtype, this.selectindex});
  @override
  State<UserConsultingListScreen> createState() =>
      _UserConsultingListScreenState();
}

class _UserConsultingListScreenState extends State<UserConsultingListScreen> {
  String? selectedConsultType;
  ReusableFunction reusableFunction = ReusableFunction();
  final List<String> _actionIcons = const [
    'assets/callring.png',
    'assets/camera-video-fill.png',
    'assets/chat-dots-fill.png',
  ];
  final List<Color> _actionColors = const [
    CustomStyles.callActionBlue,
    // `videoActionBackground` is a getter, so use its backing const here.
    Color(0xffFA3E3E),
    CustomStyles.chatActionGreen,
  ];
  List<String> tabbtn = ["Call", "Video Call", "Chat"];
  List<String> textgrid = ["Call", "Video Call", "Chat"];
  UserConsultingApiService userConsultingApiService =
      UserConsultingApiService();
  UserConsultationModel? userConsultationModel;
  String? apiToken;
  bool isloading = false;
  List<UserConsultingList> userconsultationgList = [];
  // ADD THESE VARIABLES for the Review Dialog
  final _reviewFormKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();
  double _currentRating = 0.0;

  getuserconsultationdata(String consultationtype) async {
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    if (apiToken == null) {
      print("API token is null. Cannot make API call.");
      setState(() {
        isloading = false;
      });
      return;
    }

    try {
      userConsultationModel = await userConsultingApiService
          .getuserconsultingapidata(apiToken!, consultationtype);
      print(userConsultationModel!.data);
      if (userConsultationModel != null &&
          userConsultationModel!.data != null) {
        userconsultationgList = userConsultationModel!.data!.list ?? [];
      } else {
        userconsultationgList = [];
      }
    } catch (e) {
      print("Error in API call: $e");
    }

    setState(() {
      isloading = false;
    });
  }

  int selectedindex = 0;
  // ADD THIS ENTIRE METHOD
  void _showReviewDialog(UserConsultingList consultation) {
    _reviewController.clear();
    _currentRating = 0.0;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _reviewFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with icon
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.rate_review,
                            size: 40,
                            color: Colors.orange.shade700,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Title
                        Text(
                          "Rate Your Experience",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "How was your consultation?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Rating Bar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              RatingBar.builder(
                                initialRating: 0,
                                minRating: 1,
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemSize: 40,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  setDialogState(() {
                                    _currentRating = rating;
                                  });
                                },
                              ),
                              const SizedBox(height: 8),
                              if (_currentRating > 0)
                                Text(
                                  _currentRating == 1
                                      ? "Poor"
                                      : _currentRating == 2
                                          ? "Fair"
                                          : _currentRating == 3
                                              ? "Good"
                                              : _currentRating == 4
                                                  ? "Very Good"
                                                  : "Excellent",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Review TextField
                        TextFormField(
                          controller: _reviewController,
                          decoration: InputDecoration(
                            hintText: "Share your experience...",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.orange.shade400, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.all(15),
                          ),
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your review.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("Cancel"), // Simplified
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () async {
                                        final isFormValid = _reviewFormKey
                                            .currentState!
                                            .validate();
                                        if (_currentRating == 0.0) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Please provide a star rating.");
                                          return;
                                        }
                                        if (!isFormValid) return;

                                        setDialogState(
                                            () => isSubmitting = true);

                                        // Assumes your UserConsultingList model has 'astrologerId'
                                        final response =
                                            await AstroApiService.submitReview(
                                          page: 'astrologer',
                                          id: consultation.astrologerId,
                                          rating: _currentRating.toInt(),
                                          review: _reviewController.text,
                                          appointment:
                                              consultation.consultationId,
                                        );

                                        setDialogState(
                                            () => isSubmitting = false);

                                        if (response != null &&
                                            response.success) {
                                          Navigator.pop(context);
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Review submitted successfully!");
                                          // Refresh the list to hide the review button
                                          getuserconsultationdata(
                                              selectedConsultType!);
                                        } else {
                                          Fluttertoast.showToast(
                                              msg: "Failed to submit review.");
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  backgroundColor: CustomStyles
                                      .pinki, // Or any color you prefer
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: isSubmitting
                                    ? CircularProgressIndicator(
                                        color: Colors.black)
                                    : Text("Submit"),
                                // Simplified
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    String consultationType = widget.consultationtype ?? "call";
    selectedConsultType = consultationType;
    selectedindex = widget.selectindex ?? 0;
    getuserconsultationdata(consultationType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "consultationListing".tr,
            style: CustomStyles.black14600,
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          backgroundColor: CustomStyles.whiteColor,
        ),
        body:
            //  isloading
            //     ? reusableFunction.loadingRow()
            //     :
            SafeArea(
                child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                itemCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 80,
                ),
                itemBuilder: (context, index) {
                  // if (userConsultationModel == null ||
                  //     userConsultationModel!.data == null) {
                  //   return SizedBox.shrink();
                  // }
                  var data = userConsultationModel?.data;

                  List iconTextlist = [
                    data?.callCount,
                    data?.videoCount,
                    data?.chatCount,
                  ];

                  return Container(
                    decoration: BoxDecoration(
                      color: _actionColors[index],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          _actionIcons[index],
                          height: 22,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "${iconTextlist[index] ?? 0} ${textgrid[index]}",
                          style: CustomStyles.white13600,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabbtn.length, (index) {
                  bool isSelected = selectedindex == index;
                  return SizedBox(
                    width: 100,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isSelected
                            ? CustomStyles.detailsOrange
                            : Colors.white,
                        //backgroundColor: Colors.white,
                        foregroundColor:
                            isSelected ? Colors.white : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: CustomStyles.detailsOrange,
                            width: 1,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedindex = index;
                          if (selectedindex == 0) {
                            selectedConsultType = "call";
                          } else if (selectedindex == 1) {
                            selectedConsultType = "video";
                          } else {
                            selectedConsultType = "chat";
                          }
                          getuserconsultationdata(selectedConsultType!);
                        });
                      },
                      child: Text(
                        tabbtn[index],
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            isloading
                ? reusableFunction.loadingRow()
                : userconsultationgList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Text(
                          "No Data Found!",
                          style: CustomStyles.black14500,
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: userconsultationgList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: 'Name: ',
                                          style: CustomStyles.black13600,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: userconsultationgList[index]
                                                  .name,
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Date & Time: ',
                                          style: CustomStyles.black13600,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: userconsultationgList[index]
                                                  .date,
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Charges per min: ',
                                          style: CustomStyles.black13600,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  " ₹ ${userconsultationgList[index].charges.toString()}",
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Duration: ',
                                          style: CustomStyles.black13600,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  "${userconsultationgList[index].duration.toString()} min",
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          text: 'Amount: ',
                                          style: CustomStyles.black13600,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text:
                                                  " ₹ ${userconsultationgList[index].amount.toString()}",
                                              style: CustomStyles.black14400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                              onTap: () {
                                                if (userconsultationgList[index]
                                                        .status ==
                                                    0) {
                                                } else {
                                                  if (selectedConsultType ==
                                                          "chat" &&
                                                      userconsultationgList[
                                                                  index]
                                                              .status ==
                                                          1) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => ChatScreen(
                                                              leadingbtn: true,
                                                              consultationid:
                                                                  userconsultationgList[
                                                                          index]
                                                                      .consultationId)),
                                                    );
                                                  } else if (selectedConsultType ==
                                                          "video" &&
                                                      userconsultationgList[
                                                                  index]
                                                              .status ==
                                                          1) {
                                                    // Navigator.push(
                                                    //   context,
                                                    //   MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           VideoWebviewScreen(
                                                    //               consultationid:
                                                    //                   userconsultationgList[
                                                    //                           index]
                                                    //                       .consultationId)),
                                                    // );
                                                  }
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                    color: CustomStyles.pinki,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Text(
                                                  userconsultationgList[index]
                                                      .action
                                                      .toString(),
                                                  style: CustomStyles.white,
                                                ),
                                              )),
                                          if (userconsultationgList[index]
                                                      .action
                                                      ?.toLowerCase() ==
                                                  'completed' &&
                                              userconsultationgList[index]
                                                      .review ==
                                                  true)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left:
                                                      10.0), // Adds space between buttons
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _showReviewDialog(
                                                      userconsultationgList[
                                                          index]);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 10),
                                                  backgroundColor: CustomStyles
                                                      .pinki, // Or any color you prefer
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                                child: Text("Review"),
                                              ),
                                            ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
          ],
        ),
      ),
    );
  }
}
