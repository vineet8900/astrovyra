import 'package:astrokavach/api/kundalichart/Allapi.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AIastrologermodel/aiconsulationlist.dart';
import 'package:astrokavach/screen/aichatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
// Make sure these import paths are correct for your project
//import 'package:jyotish_setu/api/astro_api_service.dart';

//import 'package:jyotish_setu/screen/kundli_ai_chat_screen.dart'; // Your chat screen

// Define some placeholder styles to match your 'CustomStyles'.
// You can replace these with your actual CustomStyles.
// class CustomStyles {
//   static const Color bgcolor = Color(0xFFF5F5F5); // A light grey background
//   static const TextStyle black14600 = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);
//   static const TextStyle black13600 = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black);
//   static const TextStyle black14500 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black);
//   static const TextStyle black14400 = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black87);
// }

class AiConsultationHistoryScreen extends StatefulWidget {
  const AiConsultationHistoryScreen({super.key});

  @override
  State<AiConsultationHistoryScreen> createState() =>
      _AiConsultationHistoryScreenState();
}

class _AiConsultationHistoryScreenState
    extends State<AiConsultationHistoryScreen> {
  late Future<List<AiConsultation>?> _consultationsFuture;
  bool isloading = false;

  final _reviewFormKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();
  double _currentRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      isloading = true;
    });
    _consultationsFuture = AstroApiService.fetchAiConsultations();
    // Awaiting the future to update loading state correctly
    await _consultationsFuture;
    setState(() {
      isloading = false;
    });
  }

  Future<void> _refreshHistory() async {
    await _fetchData();
  }

  void _showReviewDialog(AiConsultation consultation) {
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
                            color: CustomStyles.pinki,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.rate_review,
                            size: 40,
                            color: Colors.white,
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
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                                                "Please provide a star rating.",
                                            backgroundColor: Colors.red,
                                          );
                                          return;
                                        }
                                        if (!isFormValid) return;

                                        setDialogState(
                                            () => isSubmitting = true);

                                        final response =
                                            await AstroApiService.submitReview(
                                          page: 'astrologer',
                                          id: consultation.astrologerID,
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
                                          _refreshHistory();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CustomStyles.pinki,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Submit",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop:() async => false,
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomAppBarScreen()));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backgroundColor: CustomStyles.whiteColor,
          leading: IconButton(
            onPressed: () async {
              // AppBar back button ke liye bhi same confirmation
              // bool shouldPop = await _onWillPop();
              //if (shouldPop) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BottomAppBarScreen()),
              );
              // }
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: 'aiConsultationHistory'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
          actions: [],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<AiConsultation>?>(
                future: _consultationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox
                        .shrink(); // Don't show header while loading
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // This builds the top info box, similar to your grid
                    return _buildHeader(snapshot.data!.length);
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 20),

              // Main content area
              isloading
                  ? const Expanded(
                      child: Center(child: CircularProgressIndicator()))
                  : FutureBuilder<List<AiConsultation>?>(
                      future: _consultationsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Center(
                              child: Text(
                                "No Data Found!",
                                style: CustomStyles.black14500,
                              ),
                            ),
                          );
                        }

                        final consultations = snapshot.data!;
                        return Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshHistory,
                            child: ListView.builder(
                              itemCount: consultations.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                // This is the new card design
                                return _buildConsultationCard(
                                    consultations[index]);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top header box, styled like your grid items.
  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: CustomStyles.pinki,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              "$count AI Chats",
              style: CustomStyles.black13600,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the new card, styled exactly like your UserConsultingListScreen's card.
  Widget _buildConsultationCard(AiConsultation consultation) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRichText("Name: ", consultation.name),
          const SizedBox(height: 5),
          _buildRichText("Date & Time: ", consultation.dateTime),
          const SizedBox(height: 5),
          _buildRichText("Charges per min: ", "₹ ${consultation.charges}"),
          const SizedBox(height: 5),
          _buildRichText("Duration: ", "${consultation.duration} min"),
          const SizedBox(height: 5),
          _buildRichText("Amount: ", "₹ ${consultation.amount}"),
          const SizedBox(height: 10),

          // --- THIS IS THE CLICKABLE ACTION BUTTON ---
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KundliAIChatScreen(
                        consultationId: consultation.consultationId,
                        astrologerName: consultation.name,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CustomStyles.pinki,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    consultation
                        .action, // This will show "Completed" dynamically
                    style: CustomStyles.black13600,
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              if (consultation.action == "Completed" && consultation.review)
                GestureDetector(
                  onTap: () {
                    _showReviewDialog(consultation);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      //color: Colors.orange.shade100,
                      color: CustomStyles.pinki,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      "Review",
                      style:
                          CustomStyles.black13600.copyWith(color: Colors.black),
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
    );
  }

  /// Helper function to create the styled RichText widgets.
  Widget _buildRichText(String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: CustomStyles.black13600,
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: CustomStyles.black14400,
          ),
        ],
      ),
    );
  }
}
