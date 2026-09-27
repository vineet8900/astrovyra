import 'package:astrokavach/api/consultation/consultation_form_api.dart';
import 'package:astrokavach/api/consultation/consultation_schedule_api.dart';
import 'package:astrokavach/api/consultation/schedule_later_time_slot_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_dropdown.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/astrologer/schedule_later_time_slot_model.dart';
import 'package:astrokavach/model/astrologer/scheduleapimodel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// ignore: must_be_immutable
class ChatConsultScreen extends StatefulWidget {
  String? slug;
  int? id;
  String? name = '';
  bool? consultnow;
  bool? schedulelater;
  dynamic specialPrice;
  String? image;

  ChatConsultScreen(
      {super.key,
      this.slug,
      this.specialPrice,
      this.id,
      this.image,
      this.consultnow,
      this.schedulelater,
      this.name});

  @override
  State<ChatConsultScreen> createState() => _ChatConsultScreenState();
}

class _ChatConsultScreenState extends State<ChatConsultScreen> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontrollercontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  int _selectedGender = 1;
  String? selectedMaritalStatus;
  String? selectedOccupation;
  final Map<String, String> maritalStatusMap = {
    'Single': 'single',
    'Married': 'married',
    'Divorced': 'divorced',
    'Widow': 'widow',
    'Not Specified': '',
  };

  final Map<String, String> occupationMap = {
    'Employed': 'employed',
    'Business Person': 'business_person',
    'Housewife': 'house_wife',
    'Retired': 'retaired',
    'Student': 'student',
    'Not Specified': '',
  };

  double calculatePrice(String specialPrice) {
    double price = double.tryParse(specialPrice) ?? 0.0;
    if (selectedtime == 15) {
      return price * 15;
    } else {
      return price * 30;
    }
  }

  bool? istodayavailable;
  bool isloading = false;

  int selectedtime = 15;
  dynamic selectedslot;
  String? selectedIndex;

  ReusableFunction reusableFunction = ReusableFunction();
  Map<String, dynamic>? user;
  void fetchUserData() async {
    if (!mounted) return;
    setState(() {
      isloading = true;
    });
    var userData = await reusableFunction.getUserDataFromPrefs();
    if (userData != null) {
      setState(() {
        user = userData;
        namecontroller.text = userData['name'] ?? '';
        phonecontrollercontroller.text = userData['phone'] ?? '';
        emailcontroller.text = userData['email'] ?? '';
        _selectedGender = userData['gender_id'];
      });
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    } 
  }

  String? apiToken;

  ConsultationApiService consultationApiService = ConsultationApiService();
  ConsultationScheduleLaterApi consultationScheduleLaterApi =
      ConsultationScheduleLaterApi();
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<DateTime> availableDates = [];
  ScheduleLaterApiModel? scheduleLaterApiModel;
  late DateTime _firstDayOfMonth;
  late DateTime _lastDayOfMonth;

  ScheduleLaterTimeSlotApi scheduleLaterTimeSlotApi =
      ScheduleLaterTimeSlotApi();
  ScheduleLaterTimeSlotApiModel? scheduleLaterTimeSlotApiModel;
  List<String> availaibletimeslot = [];
  String? formattedavailaibledate;

  void loadAvailableDates() async {
    if (!mounted) return;
    setState(() {
      isloading = true;
    });

    try {
      scheduleLaterApiModel =
          await consultationScheduleLaterApi.fetchschedulelaterapi(widget.id!);

      if (scheduleLaterApiModel != null &&
          scheduleLaterApiModel!.data != null &&
          scheduleLaterApiModel!.data!.isNotEmpty) {
        availableDates = scheduleLaterApiModel!.data!;
       
        DateTime firstAvailable = availableDates.first;
        if (!mounted) return;
        setState(() {
          _selectedDay = firstAvailable;
          _focusedDay = firstAvailable;
        });

        formattedavailaibledate =
            "${firstAvailable.year}-${firstAvailable.month.toString().padLeft(2, '0')}-${firstAvailable.day.toString().padLeft(2, '0')}";

        var response =
            await scheduleLaterTimeSlotApi.fetchschedulelatertimeslotapi(
          widget.id!,
          formattedavailaibledate!,
          selectedtime,
        );
        if (!mounted) return;
        if (response != null && response.success == true) {
          setState(() {
            availaibletimeslot = response.timeIntervals ?? [];
          });
        } else {
          setState(() {
            availaibletimeslot = [];
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          availableDates = [];
          availaibletimeslot = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
     
      setState(() {
        availaibletimeslot = [];
      });
    }
    if (!mounted) return;
    setState(() {
      isloading = false;
    });
  }

  bool _isDateAvailable(DateTime day) {
    return availableDates.any((availableDay) =>
        availableDay.year == day.year &&
        availableDay.month == day.month &&
        availableDay.day == day.day);
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    DateTime now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _firstDayOfMonth = DateTime(now.year, now.month, 1);
    _lastDayOfMonth = DateTime(now.year, now.month + 2, 0);
    loadAvailableDates();
    selectedIndex = widget.consultnow == true ? "now" : "later";
  }

  @override
  Widget build(BuildContext context) {
    double finalPrice = calculatePrice(widget.specialPrice.toString());
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Consult on Chat"),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                      child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(
                            widget.image.toString(),
                          ))),
                ),
                Center(
                  child: Text(
                    widget.name.toString(),
                    style: CustomStyles.black16600,
                  ),
                ),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Rate : ",
                          style: CustomStyles.black14600,
                        ),
                        TextSpan(
                          text: "₹ ${widget.specialPrice}/min",
                          style: CustomStyles.red15600,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    widget.consultnow == true
                        ? Expanded(
                            child: CustomOutlinedButton(
                              text: "Consult Now",
                              backgroundColor: selectedIndex == "now"
                                  ? CustomStyles.bgcolor
                                  : Colors.white,
                              textstyle: selectedIndex == "now"
                                  ? CustomStyles.black14600
                                  : CustomStyles.black14400,
                              onPressed: () {
                                setState(() {
                                  selectedIndex = "now";
                                });
                              },
                            ),
                          )
                        : SizedBox.shrink(),
                    widget.schedulelater == true
                        ? SizedBox(
                            width: 10,
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                    widget.schedulelater == true
                        ? Expanded(
                            child: CustomOutlinedButton(
                              text: "Schedule for later",
                              textstyle: selectedIndex == "later"
                                  ? CustomStyles.black14600
                                  : CustomStyles.black14500,
                              backgroundColor: selectedIndex == "later"
                                  ? CustomStyles.bgcolor
                                  : Colors.white,
                              onPressed: () {
                                setState(() {
                                  selectedIndex = "later";
                                });
                              },
                            ),
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 10,
                ),
                if (selectedIndex == "later") ...[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Duration",
                          style: CustomStyles.black14600,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedtime = 15;
                                    loadAvailableDates();
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsetsDirectional.zero,
                                  side: BorderSide(
                                      color: CustomStyles.bgcolor, width: 1),
                                  backgroundColor: selectedtime == 15
                                      ? CustomStyles.bgcolor
                                      : Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/clock.png',
                                        scale: 4, color: Colors.black),
                                    SizedBox(width: 10),
                                    Text(
                                      "15 Min",
                                      style: selectedtime == 15
                                          ? CustomStyles.black14600
                                          : CustomStyles.black14400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedtime = 30;
                                    loadAvailableDates();
                                  });
                                  
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsetsDirectional.zero,
                                  side: BorderSide(
                                      color: CustomStyles.bgcolor, width: 1),
                                  backgroundColor: selectedtime == 30
                                      ? CustomStyles.bgcolor
                                      : Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/clock.png',
                                      color: Colors.black,
                                      scale: 4,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "30 Min",
                                      style: selectedtime == 30
                                          ? CustomStyles.black14600
                                          : CustomStyles.black14400,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Consultation Charges",
                          style: CustomStyles.black14600,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Duration:',
                                    style: CustomStyles.black14500,
                                  ),
                                  TextSpan(
                                    text: selectedtime == 15
                                        ? ' 15 Min'
                                        : " 30 Min",
                                    style: CustomStyles.black14400,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height: 15,
                                child: VerticalDivider(
                                  color: Colors.black,
                                )),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Charges: ',
                                    style: CustomStyles.black14500,
                                  ),
                                  TextSpan(
                                    text: "$finalPrice",
                                    style: CustomStyles.black14400,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: CustomStyles.bgcolor),
                              color: Colors.white),
                          padding: EdgeInsets.zero,
                          child: TableCalendar(
                            firstDay: _firstDayOfMonth,
                            lastDay: _lastDayOfMonth,
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) =>
                                isSameDay(_selectedDay, day),
                            onDaySelected: (selectedDay, focusedDay) async {
                              if (_isDateAvailable(selectedDay)) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                                formattedavailaibledate =
                                    "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                                var response = await scheduleLaterTimeSlotApi
                                    .fetchschedulelatertimeslotapi(
                                        widget.id!,
                                        formattedavailaibledate ?? '',
                                        selectedtime);
                                if (response != null &&
                                    response.success == true) {
                                  setState(() {
                                    availaibletimeslot =
                                        response.timeIntervals ?? [];
                                  });
                                }
                              }
                            },
                            enabledDayPredicate: _isDateAvailable,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            calendarStyle: CalendarStyle(
                              selectedDecoration: BoxDecoration(
                                color: CustomStyles.bgcolor,
                                shape: BoxShape.circle,
                              ),
                              todayDecoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                              disabledDecoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              decoration: BoxDecoration(
                                color: CustomStyles.bgcolor,
                              ),
                              headerPadding: EdgeInsets.all(5),
                              titleTextStyle: TextStyle(color: Colors.white),
                              leftChevronVisible: false,
                              rightChevronVisible: true,
                              // leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                              rightChevronIcon: Icon(Icons.chevron_right,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        availaibletimeslot.isEmpty || availaibletimeslot == null
                            ? Center(child: Text("No Available Time"))
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1,
                                  mainAxisExtent: 40,
                                ),
                                itemCount: availaibletimeslot.length,
                                itemBuilder: (context, index) {
                                  return CustomOutlinedButton(
                                    text: availaibletimeslot[index],
                                    backgroundColor: selectedslot ==
                                            availaibletimeslot[index]
                                        ? CustomStyles.bgcolor
                                        : Colors.white,
                                    textstyle: selectedslot ==
                                            availaibletimeslot[index]
                                        ? CustomStyles.black14400
                                        : CustomStyles.black14400,
                                    onPressed: () {
                                      setState(() {
                                        selectedslot =
                                            availaibletimeslot[index];
                                        // selectslottime= availaibletimeslot[index];
                                      });
                                    },
                                  );
                                },
                              ),
                        SizedBox(
                          height: 20,
                        ),
                      ])
                ],
                Align(
                  alignment: Alignment.center,
                  child: CustomElevatedButton(
                    text: "Next Proceed",
                    backgroundColor: CustomStyles.bgcolor,
                    textStyle: CustomStyles.black14600,
                    onPressed: () {
                      if (selectedIndex == "later") {
                        if (selectedslot != null) {
                          showmodelbottamsheet(context);
                        } else {
                          Fluttertoast.showToast(
                            msg: 'Plase select a time slot',
                            textColor: Colors.white,
                            backgroundColor: Colors.black,
                          );
                        }
                      } else {
                        showmodelbottamsheet(context);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showmodelbottamsheet(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final double scrollControlDisabledMaxHeightRatio = 0.85;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: scrollControlDisabledMaxHeightRatio,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(builder: (BuildContext context, setState) {
                return Form(
                  key: _formKey,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Text('Book Consultation',
                              style: CustomStyles.black16600),
                          SizedBox(height: 3),
                          // Text(
                          //   'To share it with your Lawyer, to save time on Consultation',
                          //   style: CustomStyles.grey12400,textAlign: TextAlign.center,
                          // ),
                          SizedBox(height: 20),
                          CustomTextField(
                            starsign: "*",
                            title: "Name",
                            label: "Enter Name",
                            controller: namecontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is Required';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                              starsign: "*",
                              textInputType: TextInputType.numberWithOptions(
                                  decimal: false, signed: false),
                              maxLength: 10,
                              title: "Phone",
                              label: "Enter Phone",
                              controller: phonecontrollercontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Phone is Required';
                                } else if (value.length != 10) {
                                  return 'Phone number should be 10 digits';
                                }
                                return null;
                              }),

                          CustomTextField(
                            starsign: "*",
                            title: "Email",
                            label: "Enter Email",
                            controller: emailcontroller,
                            textInputType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is Required';
                              }
                              String pattern =
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                              RegExp regex = RegExp(pattern);

                              if (!regex.hasMatch(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    'Gender',
                                    style: CustomStyles.black14500,
                                  )
                                ],
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _selectedGender = 1;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Radio<int>(
                                        activeColor: CustomStyles.bgcolor,
                                        value: 1,
                                        groupValue: _selectedGender,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGender = val!;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Male'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectedGender = 2;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Radio(
                                        activeColor: CustomStyles.bgcolor,
                                        value: 2,
                                        groupValue: _selectedGender,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGender = val!;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Female'),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _selectedGender = 3;
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: Radio(
                                        activeColor: CustomStyles.bgcolor,
                                        value: 3,
                                        groupValue: _selectedGender,
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedGender = val!;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text('Other'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),

                          CustomDropdownField<String>(
                            hintText: "Select Marital Status",
                            title: "Marital Status",
                            value: selectedMaritalStatus,
                            items:
                                maritalStatusMap.keys.map((String displayText) {
                              return DropdownMenuItem<String>(
                                value: displayText,
                                child: Text(displayText),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMaritalStatus = value;
                              });
                            },
                          ),

                          CustomDropdownField<String>(
                            hintText: "Select Occupation",
                            title: "Occupation",
                            value: selectedOccupation,
                            items: occupationMap.keys.map((String displayText) {
                              return DropdownMenuItem<String>(
                                value: displayText,
                                child: Text(displayText),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedOccupation = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          isloading
                              ? CircularProgressIndicator()
                              : CustomElevatedButton(
                                  backgroundColor: CustomStyles.pinki,
                                  text: "Proceed Chat",
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        isloading = true;
                                      });
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      String? apiToken =
                                          prefs.getString('api_token');
                                      var response = await consultationApiService
                                          .callapidata(
                                              context: context,
                                              token: apiToken,
                                              id: widget.id,
                                              mode: "chat",
                                              when: selectedIndex,
                                              timeSlot: selectedtime,
                                              name: namecontroller.text,
                                              email: emailcontroller.text,
                                              mobile: int.parse(
                                                      phonecontrollercontroller
                                                          .text)
                                                  .toInt(),
                                              scheduledDate:
                                                  selectedIndex == "now"
                                                      ? ""
                                                      : formattedavailaibledate,
                                              scheduledTimeSlot:
                                                  selectedIndex == "later"
                                                      ? selectedslot.toString()
                                                      : "",
                                              gender: _selectedGender,
                                              occupation:
                                                  selectedOccupation ?? "",
                                              maritalstatus:
                                                  selectedMaritalStatus ?? "");
                                      if (response != null &&
                                          response["success"] == true) {
                                        // Navigator.pushReplacement(

                                        //                          context,
                                        //                          MaterialPageRoute(builder: (context) => UserConsultingListScreen(consultationtype: "chat",selectindex: 2,)),
                                        //                        );
                                      } else {
//  Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(
//       builder: (context) => ThankyouScreen(
//         msg: response?["message"] ?? "Unknown error occurred.",
//       ),
//     ),
//   );
                                      }
                                      setState(() {
                                        isloading = false;
                                      });
                                    }
                                  }),
                        ],
                      ),
                    ),
                  ),
                );
              });
            });
      },
    );
  }
}
