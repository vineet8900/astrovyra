import 'package:astrokavach/api/Address_Api/add_address_Api.dart';
import 'package:astrokavach/api/Address_Api/address_api.dart';
import 'package:astrokavach/api/Address_Api/delete_address_Api.dart';
import 'package:astrokavach/api/auth_api/place_api.dart';
import 'package:astrokavach/custom_widgets/bottam_navigation_bar.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/custom_dropdown.dart';
import 'package:astrokavach/custom_widgets/custom_elevated_btn.dart';
import 'package:astrokavach/custom_widgets/cutsom_textfield.dart';
import 'package:astrokavach/custom_widgets/reusable_function.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:astrokavach/model/AddressModel/address_api_model.dart';
import 'package:astrokavach/model/places_model.dart/city_api_model.dart';
import 'package:astrokavach/model/places_model.dart/country_Api_model.dart';
import 'package:astrokavach/model/places_model.dart/state_api_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageAddressAscreen extends StatefulWidget {
  const ManageAddressAscreen({super.key});

  @override
  State<ManageAddressAscreen> createState() => _ManageAddressAscreenState();
}

class _ManageAddressAscreenState extends State<ManageAddressAscreen> {
  final _formKey = GlobalKey<FormState>();
  ReusableFunction reusableFunction = ReusableFunction();
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController placeofbirthcontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController pincodecontroller = TextEditingController();
  TextEditingController couponcodecontroller = TextEditingController();
  List<CountryDatum> countrydatalist = [];
  List<StateDatum> statedatalist = [];
  List<CityDatum> citydatalist = [];
  CountryModel? countryModel;
  StateModel? stateModel;
  CityModel? cityModel;
  CountryDatum? selectcountry;
  StateDatum? selectstate;
  CityDatum? selectcity;
  CountryApiService countryApiService = CountryApiService();
  StateApiService stateApiService = StateApiService();
  CityApiService cityApiService = CityApiService();
  AddressApiService addressApiService = AddressApiService();
  AddressApiModel? addressApiModel;
  List<AddressDatum> addresslist = [];

  SubmitAddressApiService submitAddressApiService = SubmitAddressApiService();
  dynamic stateid;
  dynamic countryid;
  dynamic cityid;
  int addreesid = 0;
  bool isloading = false;
  String? apiToken;
  getuserdata() async {
    setState(() {
      isloading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('api_token');

    addressApiModel =
        await addressApiService.getaddressapidata(apiToken.toString());
    addresslist = addressApiModel?.data ?? [];
    // addressid = addresslist.first.addressId;

    stateModel = await stateApiService.fetchstatedata("101");
    statedatalist = stateModel?.data ?? [];

    try {
      selectstate = statedatalist.isNotEmpty
          ? statedatalist.firstWhere((state) => state.id == stateid)
          : null;
    } catch (e) {
      selectstate = null;
    }

    if (selectstate != null) {
      cityModel =
          await cityApiService.fetchcitydata(selectstate!.id.toString());
      citydatalist = cityModel?.data ?? [];

      try {
        selectcity = citydatalist.isNotEmpty
            ? citydatalist.firstWhere((city) => city.id == cityid)
            : null;
      } catch (e) {
        selectcity = null;
      }
    }
    setState(() {
      isloading = false;
    });
  }

  Future<void> submitaddressform(int addressId) async {
    setState(() {
      isloading = true;
    });

    try {
      await submitAddressApiService.submitAddress(
        token: apiToken.toString(),
        fullName: usernamecontroller.text,
        phone: phonecontroller.text,
        email: emailcontroller.text,
        countryId: 101,
        stateId: selectstate!.id,
        cityId: selectcity!.id,
        zipcode: pincodecontroller.text,
        address: placeofbirthcontroller.text,
        addressId: addressId,
      );

      await getuserdata();

      usernamecontroller.clear();
      phonecontroller.clear();
      emailcontroller.clear();

      selectcity = null;
      selectstate = null;
      pincodecontroller.clear();
      placeofbirthcontroller.clear();

      Navigator.pop(context);
    } catch (e) {
       
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  DeleteAddressApiService deleteAddressApiService = DeleteAddressApiService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getuserdata();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => BottomAppBarScreen()));
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
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
          title: 'address_book'.tr,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: Colors.grey.shade300,
              height: 1.0,
            ),
          ),
        ),
        body: isloading
            ? reusableFunction.loadingRow()
            : SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('deliveryAddress'.tr,
                              style: CustomStyles.black16600),
                          Container(
                            height: 40,
                            width: 70,
                            decoration: BoxDecoration(
                              color: CustomStyles.pinki,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                showAddressFormPopup(context, 0);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // addresslist.isEmpty?Center(child: Text("Add The Delivery Address")):
                      Expanded(
                        child: ListView.builder(
                          itemCount: addresslist.length,
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.black38)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(addresslist[index].name ?? '',
                                            style: CustomStyles.black14400),
                                        Text(
                                          " ${addresslist[index].address},${addresslist[index].city}, ${addresslist[index].state} - ${addresslist[index].zipcode}",
                                          overflow: TextOverflow.ellipsis,
                                          style: CustomStyles.black14400,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text(
                                                  'Delete Address'),
                                              content: const Text(
                                                  'Do you want to delete this address?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text('No'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text('Yes'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm != true || !mounted) return;
                                          await deleteAddressApiService
                                              .deleteaddressapi(
                                            token: apiToken.toString(),
                                            addressId:
                                                addresslist[index].addressId!,
                                          );
                                          if (!mounted) return;
                                          addressApiModel =
                                              await addressApiService
                                                  .getaddressapidata(apiToken!);
                                          addresslist =
                                              addressApiModel!.data ?? [];
                                          setState(() {});
                                        },
                                        child: Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            showAddressFormPopup(context,
                                                addresslist[index].addressId!);
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                            size: 20,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void showAddressFormPopup(BuildContext context, int addressId) {
    bool isLoading = true;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future loadData() async {
              if (addressId != 0) {
                var selectedAddress = addressApiModel!.data!
                    .firstWhere((item) => item.addressId == addressId);

                usernamecontroller.text = selectedAddress.name ?? '';
                phonecontroller.text = selectedAddress.phone ?? '';
                emailcontroller.text = selectedAddress.email ?? '';
                placeofbirthcontroller.text = selectedAddress.address ?? '';
                pincodecontroller.text = selectedAddress.zipcode.toString();
                stateModel = await stateApiService.fetchstatedata("101");
                statedatalist = stateModel?.data ?? [];

                try {
                  selectstate = statedatalist
                      .firstWhere((item) => item.id == selectedAddress.stateId);
                } catch (e) {
                  selectstate = null;
                }

                if (selectstate != null) {
                  cityModel = await cityApiService
                      .fetchcitydata(selectstate!.id.toString());
                  citydatalist = cityModel?.data ?? [];

                  try {
                    selectcity = citydatalist.firstWhere(
                        (item) => item.id == selectedAddress.cityId);
                  } catch (e) {
                    selectcity = null;
                  }
                }
              } else {
                usernamecontroller.clear();
                phonecontroller.clear();
                emailcontroller.clear();
                placeofbirthcontroller.clear();
                pincodecontroller.clear();
                selectcountry = null;
                selectstate = null;
                selectcity = null;

                stateModel = await stateApiService.fetchstatedata("101");
                statedatalist = stateModel?.data ?? [];
                citydatalist = [];
              }

              setState(() {
                isLoading = false;
              });
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (isLoading) loadData();
            });

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          addressId == 0
                                              ? "Add Address"
                                              : "Edit Address",
                                          style: CustomStyles.black16600,
                                        )),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomTextField(
                                            outlineBorderRadius: 8,
                                            starsign: "*",
                                            title: "Name",
                                            label: "Enter Name",
                                            controller: usernamecontroller,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Name is Required';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: CustomTextField(
                                            outlineBorderRadius: 8,
                                            starsign: "*",
                                            title: "Phone",
                                            label: "Enter Phone",
                                            controller: phonecontroller,
                                            maxLength: 10,
                                            textInputType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Phone is Required';
                                              } else if (value.length != 10) {
                                                return 'Phone number should be 10 digits';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
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

                                    CustomDropdownField<StateDatum>(
                                      outlineBorderRadius: 8,
                                      hintText: "Select State",
                                      title: "State",
                                      starsign: '*',
                                      value: selectstate,
                                      items: statedatalist
                                          .map((StateDatum values) {
                                        return DropdownMenuItem<StateDatum>(
                                          value: values,
                                          child: Text(values.name.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (value) async {
                                        setState(() {
                                          selectstate = value;
                                          selectcity = null;
                                        });

                                        if (value != null) {
                                          cityModel = await cityApiService
                                              .fetchcitydata(
                                                  selectstate!.id.toString());
                                          citydatalist = cityModel?.data ?? [];

                                          setState(() {});
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select a state';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomDropdownField<CityDatum>(
                                      outlineBorderRadius: 8,
                                      hintText: "Select City",
                                      title: "City",
                                      starsign: '*',
                                      value: selectcity,
                                      items:
                                          citydatalist.map((CityDatum values) {
                                        return DropdownMenuItem<CityDatum>(
                                          value: values,
                                          child: Text(values.name.toString()),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectcity = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Please select city';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
                                      label: "Zip Code",
                                      maxLength: 6,
                                      controller: pincodecontroller,
                                      title: "Zip Code",
                                      starsign: "*",
                                      textInputType: TextInputType.number,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Zip Code is Required';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                    CustomTextField(
                                      outlineBorderRadius: 8,
                                      height: 60,
                                      label: "Address",
                                      controller: placeofbirthcontroller,
                                      title: "Address",
                                      starsign: "*",
                                      maxline: 3,
                                      textInputType:
                                          TextInputType.streetAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Address is Required';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: CustomElevatedButton(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            backgroundColor: CustomStyles.pinki,
                                            text: "Close",
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: CustomElevatedButton(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            backgroundColor: CustomStyles.pinki,
                                            text: "Submit",
                                            onPressed: () async {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                await submitaddressform(
                                                    addressId);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
}
