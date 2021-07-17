import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tenancy/constant.dart';
import 'package:intl/intl.dart';
import 'package:tenancy/get_functions.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:toast/toast.dart';

class SignUpPage extends StatefulWidget {
  final int pass;

  const SignUpPage({Key? key, required this.pass}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _othernames = TextEditingController();
  final TextEditingController _phone1 = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password2 = TextEditingController();
  final TextEditingController _phone2 = TextEditingController();
  final TextEditingController _gender = TextEditingController();
  DateTime? _dob;
  String? idtypeValue;
  String? regionId;
  String? district;
  int _index_ = 0;
  String mycoordinates="";
  String? _city;
  final TextEditingController _idtype = TextEditingController();
  final TextEditingController _idnumber = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  final TextEditingController _hometown = TextEditingController();
  final TextEditingController _housenumber = TextEditingController();
  String dropdownValue = "Select gender*";
  final int lastyear = DateTime.now().year;
  DateTime selectedDate = DateTime.now();
  final int initialyear = DateTime.now().year - 18;
  List _data = [];
  List _regions = [];
  List _cities = [];
  List _districts = [];
  PickedFile? _image;
  final ImagePicker _picker = ImagePicker();
  String _gps = "";
  bool showProgress = false;

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(initialyear, 1, 1), // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2021),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dob = picked;
      });
    }
  }

  void showImagePickerModal() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            height: 160,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Image Pick Options",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickImageFromCamera(),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: app_color,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                "Open camera",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Icon(
                                Icons.camera,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: app_color,
                            borderRadius: BorderRadius.circular(10)),
                        child: GestureDetector(
                          onTap: () => pickImageFromGallery(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                "Open Gallery",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              Icon(
                                Icons.image,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void pickImageFromCamera() async {
    final PickedFile? pickedFile =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = pickedFile!;
    });
    Navigator.pop(context);
  }

  void pickImageFromGallery() async {
    final PickedFile? pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = pickedFile!;
    });

    Navigator.pop(context);
  }

  void getInitData() async {
    setState(() {
      showProgress = true;
    });
    _data = await MyFunc.getIDTypes(context);
    _regions = await MyFunc.getRegions(context);
    setState(() {
      _data = _data;
      _regions = _regions;
      showProgress = false;
    });
  }

  getLocationData() async {
    setState(() {
      showProgress=true;
    });
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    final coordinates =
        Coordinates(_locationData.latitude, _locationData.longitude);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;
    setState(() {
      _gps = first.addressLine;
      mycoordinates = "${_locationData.latitude} ${_locationData.longitude}";
      showProgress=false;
    });

  }

  void signup(String? filepath) async {
    setState(() {
      showProgress = true;
    });
    final Map<String, String> data = {
      "first_name": _firstname.text,
      "other_names": _othernames.text,
      "phone_number": _phone1.text,
      "email_address": _email.text,
      "phone2": _phone2.text,
      "gender": dropdownValue,
      "nationality": _nationality.text,
      "hometown": _hometown.text,
      "region": regionId!,
      "city": _city!,
      "district": district!,
      "gps": mycoordinates,
      "id_type": idtypeValue!,
      "id_number": _idnumber.text,
      "dob": DateFormat('yyyy-MM-dd').format(_dob!).toString(),
      "house_number": _housenumber.text,
      "password":_password.text
    };
    final response =
        http.MultipartRequest('POST', Uri.parse("${base_url}landlord/signup"));

    response.files
        .add(await http.MultipartFile.fromPath("id_image", filepath!));
    response.fields.addAll(data);

    var streamedResponse = await response.send();
    var res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode < 206) {
      print(json.decode(res.body));
      Toast.show(
        "Account has been created.",
        context,
        gravity: Toast.BOTTOM,
        duration: Toast.LENGTH_LONG,
      );
      Future.delayed(
        const Duration(
          seconds: 1,
        ),
      );
      Navigator.pop(context);
    } else {}
    setState(() {
      showProgress = false;
    });
  }

  @override
  void initState() {
    super.initState();

    getInitData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _idtype.dispose();
    _idnumber.dispose();
    _nationality.dispose();
    _hometown.dispose();
    _housenumber.dispose();
    _firstname.dispose();
    _othernames.dispose();
    _phone2.dispose();
    _phone1.dispose();
    _email.dispose();
    _password.dispose();
    _gender.dispose();
    _password2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0Xf4f6faFF),
      body: ModalProgressHUD(
        inAsyncCall: showProgress,
        progressIndicator: spinkit,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox()
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Expanded(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:  [
                                  Hero(
                                    tag: "logo",
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      child: Image.asset("assets/images/logo.png"),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  const Text(
                                    "Tenancy",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: app_color),
                                  )
                                ],
                              ),
                            ],
                          ),
                          // const SizedBox(
                          //   height: 30,
                          // ),

                          //ADD OTHER FIELDS HERS


                          const SizedBox(
                            height: 30,
                          ),
                          Stepper(
                            physics: ClampingScrollPhysics(),
                            type: StepperType.vertical,
                            currentStep: _index_,
                            onStepCancel: () {
                              if (_index_ > 0) {
                                setState(() {
                                  _index_ -= 1;
                                });
                              }
                            },
                            onStepContinue: () {
                              if (_index_ >= 0 && widget.pass == 1 && _index_ < 3) {
                                setState(() {
                                  _index_ += 1;
                                });
                              }
                              else if (_index_ >= 0 && widget.pass == 0 && _index_ < 2) {
                                setState(() {
                                  _index_ += 1;
                                });
                              }
                              else if (widget.pass == 1 && _index_ == 3) {
                                if (_formKey.currentState!.validate()) {
                                  if (dropdownValue == "Select gender*") {
                                    const snackBar = SnackBar(
                                      content: Text("Gender field is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_dob == null) {
                                    const snackBar = SnackBar(
                                      content: Text("Date of birth is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (idtypeValue == null) {
                                    const snackBar = SnackBar(
                                      content: Text("ID type is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (regionId == null ||
                                      district == null ||
                                      _city == null) {
                                    const snackBar = SnackBar(
                                      content: Text(
                                          "Region, City and District are required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_image == null) {
                                    const snackBar = SnackBar(
                                      content: Text("Image of ID is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_gps.isEmpty) {
                                    const snackBar = SnackBar(
                                      content: Text("GPS address is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    signup(_image!.path);
                                  }
                                }
                              }
                              else if (widget.pass == 0 &&_index_ == 2) {
                                if (_formKey.currentState!.validate()) {
                                  if (dropdownValue == "Select gender*") {
                                    const snackBar = SnackBar(
                                      content: Text("Gender field is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_dob == null) {
                                    const snackBar = SnackBar(
                                      content: Text("Date of birth is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (idtypeValue == null) {
                                    const snackBar = SnackBar(
                                      content: Text("ID type is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (regionId == null ||
                                      district == null ||
                                      _city == null) {
                                    const snackBar = SnackBar(
                                      content: Text(
                                          "Region, City and District are required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_image == null) {
                                    const snackBar = SnackBar(
                                      content: Text("Image of ID is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_gps.isEmpty) {
                                    const snackBar = SnackBar(
                                      content: Text("GPS address is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    signup(_image!.path);
                                  }
                                }
                              }

                              print(_index_);

                            },
                            onStepTapped: (int v) {
                              setState(() {
                                _index_ = v;
                              });
                            },
                            steps: <Step>[
                              Step(
                                title: const Text('Personal Info'),
                                content: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: TextFormField(
                                                  controller: _firstname,
                                                  validator: (e) {
                                                    if (_firstname
                                                        .text.isEmpty) {
                                                      return "Please enter your first name";
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  decoration:
                                                      kMainTextFieldDecoration
                                                          .copyWith(
                                                              labelText:
                                                                  "Enter Your first name *"),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: TextFormField(
                                                  controller: _othernames,
                                                  validator: (e) {
                                                    if (_othernames
                                                        .text.isEmpty) {
                                                      return "Please enter your other names";
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  decoration:
                                                      kMainTextFieldDecoration
                                                          .copyWith(
                                                              labelText:
                                                                  "Enter your other names *"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Card(
                                      color: Colors.white,
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 1,
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: TextFormField(
                                          controller: _email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (e) {
                                            if (_email.text.isEmpty) {
                                              return "Please enter email";
                                            } else if (!_email.text
                                                .contains("@")) {
                                              return "Please enter a valid email";
                                            } else if (!_email.text
                                                .contains(".com")) {
                                              return "Please enter a valid email";
                                            } else {
                                              return null;
                                            }
                                          },
                                          style: const TextStyle(fontSize: 14),
                                          decoration:
                                              kMainTextFieldDecoration.copyWith(
                                                  labelText:
                                                      "Enter your email *"),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: _phone1,
                                                  validator: (e) {
                                                    if (_phone1.text.isEmpty) {
                                                      return "Please enter phone number ";
                                                    } else {
                                                      return null;
                                                    }
                                                  },
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  decoration:
                                                      kMainTextFieldDecoration
                                                          .copyWith(
                                                              labelText:
                                                                  "Enter Your phone number *"),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1,
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: _phone2,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                  decoration:
                                                      kMainTextFieldDecoration
                                                          .copyWith(
                                                              labelText:
                                                                  "Enter your phone 2"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: DropdownButton<String>(
                                                    value: dropdownValue,
                                                    icon: const Icon(
                                                        Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    elevation: 16,
                                                    style: const TextStyle(
                                                        color: Colors.black54),
                                                    underline: Container(
                                                      height: 2,
                                                      color: Colors.transparent,
                                                    ),
                                                    onChanged:
                                                        (String? newValue) {
                                                      setState(() {
                                                        dropdownValue =
                                                            newValue!;
                                                      });
                                                    },
                                                    items: [
                                                      "Male",
                                                      "Female",
                                                      "Select gender*"
                                                    ].map<
                                                            DropdownMenuItem<
                                                                String>>(
                                                        (String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(value),
                                                      );
                                                    }).toList(),
                                                  )),
                                            ),
                                          ),
                                          Flexible(
                                            child: Card(
                                              color: Colors.white,
                                              elevation: 5,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: Container(
                                                  height: 50,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      _dob == null
                                                          ? const Text(
                                                              "date of birth *",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                            )
                                                          : Text(
                                                              DateFormat(
                                                                      'yyyy-MM-dd')
                                                                  .format(_dob!)
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                            ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          _selectDate(context);
                                                        },
                                                        child: const Icon(Icons
                                                            .calendar_today_rounded),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Step(
                                title: Text("Identifications"),
                                content: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 0),
                                      child: Row(
                                        textBaseline: TextBaseline.ideographic,
                                        children: [
                                          Expanded(
                                              child: Column(
                                            children: [
                                              const Text(
                                                "ID Type*",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Card(
                                                color: Colors.white,
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Container(
                                                  height: 55,
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: DropdownButton<String>(
                                                      value: idtypeValue,
                                                      icon: const Icon(Icons
                                                          .arrow_drop_down),
                                                      iconSize: 24,
                                                      elevation: 16,
                                                      style: const TextStyle(
                                                          color: Color(
                                                              0xFF2C3335)),
                                                      underline: Container(
                                                        height: 1,
                                                        color:
                                                            Colors.transparent,
                                                      ),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          idtypeValue = newValue
                                                              .toString();
                                                        });
                                                      },
                                                      items: _data.map(
                                                        (item) {
                                                          return DropdownMenuItem(
                                                            child: Text(
                                                              "${item['name']}*",
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                            ),
                                                            value: item['id']
                                                                .toString(),
                                                          );
                                                        },
                                                      ).toList()),
                                                ),
                                              ),
                                            ],
                                          )),
                                          Flexible(
                                            child: Column(
                                              children: [
                                                const Text(""),
                                                Card(
                                                  color: Colors.white,
                                                  elevation: 5,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Colors.grey
                                                              .withOpacity(0.3),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(7)),
                                                    child: TextFormField(
                                                      validator: (e) {
                                                        if (_idnumber
                                                            .text.isEmpty) {
                                                          return "Please enter ID number";
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                      controller: _idnumber,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                      decoration:
                                                          kMainTextFieldDecoration
                                                              .copyWith(
                                                                  labelText:
                                                                      "Enter your ID number"),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Card(
                                      elevation: 6,
                                      child: Container(
                                        height: 180,
                                        color: Colors.white,
                                        child: Stack(
                                          children: [
                                            _image == null
                                                ? const Center(
                                                    child: Text(
                                                      "Image of ID*\nNo image selected.",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black54),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )
                                                : Container(
                                                    width: double.infinity,
                                                    child: Image.file(
                                                      File(_image!.path),
                                                      fit: BoxFit.cover,
                                                    )),
                                            Positioned(
                                                right: 10,
                                                top: 10,
                                                child: GestureDetector(
                                                  onTap: () =>
                                                      showImagePickerModal(),
                                                  child: Card(
                                                    color: app_color,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        7)),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Step(
                                  title: Text("Addresses And Location"),
                                  content: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Card(
                                                color: Colors.white,
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: TextFormField(
                                                    controller: _nationality,
                                                    validator: (e) {
                                                      if (_nationality
                                                          .text.isEmpty) {
                                                        return "Please enter nationality ";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                    decoration:
                                                        kMainTextFieldDecoration
                                                            .copyWith(
                                                                labelText:
                                                                    "Enter Your nationality *"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Flexible(
                                              child: Card(
                                                color: Colors.white,
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7)),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: 1,
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              7)),
                                                  child: TextFormField(
                                                    validator: (e) {
                                                      if (_hometown
                                                          .text.isEmpty) {
                                                        return "Please enter hometown ";
                                                      } else {
                                                        return null;
                                                      }
                                                    },
                                                    controller: _hometown,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                    decoration:
                                                        kMainTextFieldDecoration
                                                            .copyWith(
                                                                labelText:
                                                                    "Enter your hometown"),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "Regions*",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Card(
                                            color: Colors.white,
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Container(
                                              height: 55,
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: DropdownButton<String>(
                                                  value: regionId,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: const TextStyle(
                                                      color: Color(0xFF2C3335)),
                                                  underline: Container(
                                                    height: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                  onChanged: (newValue) async {
                                                    setState(() {
                                                      _cities = [];
                                                      _districts = [];
                                                      _city = null;
                                                      district = null;
                                                      regionId =
                                                          newValue.toString();
                                                      _cities = _regions
                                                          .where((id) =>
                                                              id['id']
                                                                  .toString() ==
                                                              newValue
                                                                  .toString())
                                                          .toList()[0]['cities'];
                                                    });
                                                  },
                                                  items: _regions.map(
                                                    (item) {
                                                      return DropdownMenuItem(
                                                        child: Text(
                                                          "${item['name']}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                        ),
                                                        value: item['id']
                                                            .toString(),
                                                      );
                                                    },
                                                  ).toList()),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "City*",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Card(
                                            color: Colors.white,
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Container(
                                              height: 55,
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: DropdownButton<String?>(
                                                  value: _city,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: const TextStyle(
                                                      color: Color(0xFF2C3335)),
                                                  underline: Container(
                                                    height: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                  onChanged: (newValue) async {
                                                    setState(() {
                                                      _districts = [];
                                                      district = null;
                                                      _city =
                                                          newValue.toString();
                                                      _districts = _cities
                                                          .where((id) =>
                                                              id['id']
                                                                  .toString() ==
                                                              newValue
                                                                  .toString())
                                                          .toList()[0]['districts'];
                                                    });
                                                  },
                                                  items: _cities.map(
                                                    (item) {
                                                      return DropdownMenuItem(
                                                        child: Text(
                                                          "${item['name']}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                        ),
                                                        value: item['id']
                                                            .toString(),
                                                      );
                                                    },
                                                  ).toList()),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Column(
                                        children: [
                                          const Text(
                                            "District*",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Card(
                                            color: Colors.white,
                                            elevation: 5,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Container(
                                              height: 55,
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey
                                                        .withOpacity(0.3),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(7)),
                                              child: DropdownButton<String?>(
                                                  value: district,
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down),
                                                  iconSize: 24,
                                                  elevation: 16,
                                                  style: const TextStyle(
                                                      color: Color(0xFF2C3335)),
                                                  underline: Container(
                                                    height: 1,
                                                    color: Colors.transparent,
                                                  ),
                                                  onChanged: (newValue) async {
                                                    setState(() {
                                                      district =
                                                          newValue.toString();
                                                    });
                                                  },
                                                  items: _districts.map(
                                                    (item) {
                                                      return DropdownMenuItem(
                                                        child: Text(
                                                          "${item['name']}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                        ),
                                                        value: item['id']
                                                            .toString(),
                                                      );
                                                    },
                                                  ).toList()),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(7)),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  flex: 4,
                                                  child: Container(
                                                    padding: const EdgeInsets.only(
                                                        left: 5),
                                                    width: double.infinity,
                                                    child: Text(
                                                      _gps.isNotEmpty
                                                          ? _gps
                                                          : "Tap on the icon to get your gps address.",
                                                      style: const TextStyle(
                                                          fontSize: 13,
                                                          color:
                                                              Colors.black54),
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                    flex: 1,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        getLocationData();
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: app_color,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5)),
                                                        width: double.infinity,
                                                        height: 50,
                                                        child: const Icon(
                                                          Icons.location_on,
                                                          color: Colors.white,
                                                          size: 27,
                                                        ),
                                                      ),
                                                    ))
                                              ],
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextFormField(
                                            validator: (e) {
                                              if (_housenumber.text.isEmpty) {
                                                return "Please enter house number";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller: _housenumber,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                    labelText:
                                                        "Enter your house number"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              if(widget.pass == 1)
                              Step(
                                  title: Text("Passwords"),
                                  content: Column(
                                    children: [

                                      Card(
                                        color: Colors.white,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextFormField(
                                            obscureText: true,
                                            validator: (e) {
                                              if (_password.text.isEmpty) {
                                                return "Enter password";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller: _password,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                    labelText:
                                                        "Enter password"),
                                          ),
                                        ),
                                      ),
                                      Card(
                                        color: Colors.white,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(0.3),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(7)),
                                          child: TextFormField(
                                            obscureText: true,
                                            validator: (e) {
                                              if (_password2.text.isEmpty) {
                                                return "enter password";
                                              }else if (_password2.text ==  _password.text) {
                                                return "Passwords do not match";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller: _password2,
                                            style:
                                                const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                    labelText:
                                                        "confirm password"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
