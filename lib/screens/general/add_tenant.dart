import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tenancy/constant.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:tenancy/get_functions.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTenant extends StatefulWidget {
  final int? houseId;

  AddTenant({this.houseId});

  @override
  _AddTenantState createState() => _AddTenantState();
}

class _AddTenantState extends State<AddTenant> {
  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();
  final int lastyear = DateTime
      .now()
      .year;
  DateTime selectedDate = DateTime.now();
  final int initialyear = DateTime
      .now()
      .year - 18;
  DateTime? _dob;
  String dropdownValue = "Select gender*";
  String? idtypeValue;
  List _data = [];
  PickedFile? _image;
  final ImagePicker _picker = ImagePicker();
  int _index = 0;

  final TextEditingController _firstname = TextEditingController();
  final TextEditingController _surname = TextEditingController();
  final TextEditingController _othernames = TextEditingController();
  final TextEditingController _pob = TextEditingController();
  final TextEditingController _hometown = TextEditingController();
  final TextEditingController _nationality = TextEditingController();
  final TextEditingController _religion = TextEditingController();
  final TextEditingController _idnumber = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone1 = TextEditingController();
  final TextEditingController _phone2 = TextEditingController();
  final TextEditingController _lastresidence = TextEditingController();
  final TextEditingController _occupation = TextEditingController();
  final TextEditingController _nof_employer = TextEditingController();
  final TextEditingController _cof_employer = TextEditingController();
  final TextEditingController _workAddress = TextEditingController();
  final TextEditingController _fathern = TextEditingController();
  final TextEditingController _fatherc = TextEditingController();
  final TextEditingController _fatherhm = TextEditingController();
  final TextEditingController _mothern = TextEditingController();
  final TextEditingController _motherc = TextEditingController();
  final TextEditingController _motherhm = TextEditingController();
  final TextEditingController _social_platform = TextEditingController();
  final TextEditingController _social_name = TextEditingController();

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
                          padding: EdgeInsets.all(15),
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
                        padding: const EdgeInsets.all(15),
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

  void createTenant(String? filepath) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getStringList("data")![0];
    final userId = sharedPreferences.getStringList("data")![1];
    setState(() {
      showSpinner = true;
    });

    final Map<String, String> data = {
      "landlord_id": userId,
      "house_id": widget.houseId.toString(),
      "first_name": _firstname.text,
      "surname": _surname.text,
      "middle_name": _othernames.text,
      "dob": DateFormat('yyyy-MM-dd').format(_dob!).toString(),
      "place_of_birth": _pob.text,
      "hometown": _hometown.text,
      "gender": dropdownValue,
      "nationality": _nationality.text,
      "religion": _religion.text,
      "id_type": idtypeValue!,
      "id_number": _idnumber.text,
      "phone_number": _phone1.text,
      "email_address": _email.text,
      "phone2": _phone2.text,
      "last_residence": _lastresidence.text,
      "occupation": _occupation.text,
      "nof_employer": _nof_employer.text,
      "cof_employer": _cof_employer.text,
      "work_place": _workAddress.text,
      "father_name": _fathern.text,
      "mother_name": _mothern.text,
      "mother_contact": _mothern.text,
      "mother_hometown": _motherhm.text,
      "father_hometown": _fatherhm.text,
      "social_platform": _social_platform.text,
      "social_name": _social_name.text
    };
    final response =
    http.MultipartRequest('POST', Uri.parse("${base_url}landlord/add-tenant"));

    response.files
        .add(await http.MultipartFile.fromPath("id_image", filepath!));
    response.fields.addAll(data);
    response.headers['authorization'] = "Bearer $token";

    var streamedResponse = await response.send();
    var res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode < 206) {
      Toast.show(
        "${json.decode(res.body)['message']}",
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
    } else {
      print(res.body);
    }
    setState(() {
      showSpinner = false;
    });
  }

  getIdTypes() async {
    setState(() {
      showSpinner = true;
    });
    _data = await MyFunc.getIDTypes(context);
    setState(() {
      showSpinner = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fatherhm.dispose();
    _fatherc.dispose();
    _fathern.dispose();
    _social_name.dispose();
    _social_platform.dispose();
    _motherhm.dispose();
    _motherc.dispose();
    _mothern.dispose();
    _email.dispose();
    _phone2.dispose();
    _phone1.dispose();
    _lastresidence.dispose();
    _occupation.dispose();
    _nof_employer.dispose();
    _cof_employer.dispose();
    _workAddress.dispose();
    _firstname.dispose();
    _surname.dispose();
    _othernames.dispose();
    _pob.dispose();
    _hometown.dispose();
    _nationality.dispose();
    _religion.dispose();
    _idnumber.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIdTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0Xf4f6faFF),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: spinkit,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 5, bottom: 20),
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
                          "Add Tenant",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 25),
                        ),
                        const SizedBox()
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    //   child: Column(
                    //     children: [
                    //       const SizedBox(
                    //         height: 7,
                    //       ),
                    //
                    //       const SizedBox(
                    //         height: 7,
                    //       ),
                    //
                    //     ],
                    //   ),
                    // ),
                    child: Stepper(
                      physics: ClampingScrollPhysics(),
                      type: StepperType.vertical,
                      currentStep: _index,
                      onStepCancel: () {
                        if (_index > 0) {
                          setState(() {
                            _index -= 1;
                          });
                        }
                      },
                      onStepContinue: () {
                        if (_index >= 0 && _index < 4) {
                          setState(() {
                            _index += 1;
                          });
                        } else if (_index == 4) {
                          createTenant(_image!.path);
                        }
                        print(_index);
                      },
                      onStepTapped: (int v) {
                        setState(() {
                          _index = v;
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
                                            controller: _firstname,
                                            validator: (e) {
                                              if (_firstname.text.isEmpty) {
                                                return "Please enter first name";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  first name *"),
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
                                            controller: _surname,
                                            validator: (e) {
                                              if (_surname.text.isEmpty) {
                                                return "Please enter  surname name";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  surname name *"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextFormField(
                                    controller: _othernames,
                                    validator: (e) {
                                      if (_othernames.text.isEmpty) {
                                        return "Please enter  other names";
                                      } else {
                                        return null;
                                      }
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration:
                                    kMainTextFieldDecoration.copyWith(
                                        labelText: "Enter  other names *"),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
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
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  dropdownValue = newValue!;
                                                });
                                              },
                                              items: [
                                                "Male",
                                                "Female",
                                                "Select gender*"
                                              ].map<DropdownMenuItem<String>>(
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
                                    Expanded(
                                      child: Card(
                                        color: Colors.white,
                                        elevation: 5,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(7)),
                                        child: Container(
                                            height: 50,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                                      .withOpacity(0.3),
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(7)),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                _dob == null
                                                    ? const Text(
                                                  "date of birth *",
                                                  style: TextStyle(
                                                      color:
                                                      Colors.black54),
                                                )
                                                    : Text(
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(_dob!)
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color:
                                                      Colors.black54),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _selectDate(context);
                                                  },
                                                  child: const Icon(
                                                    Icons
                                                        .calendar_today_rounded,
                                                    color: app_color,
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
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
                                            controller: _pob,
                                            validator: (e) {
                                              if (_pob.text.isEmpty) {
                                                return "Please enter  place of birth";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  place of birth *"),
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
                                            controller: _hometown,
                                            validator: (e) {
                                              if (_hometown.text.isEmpty) {
                                                return "Please enter  hometown";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  hometown *"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
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
                                            controller: _nationality,
                                            validator: (e) {
                                              if (_nationality.text.isEmpty) {
                                                return "Please enter  nationality";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter nationality *"),
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
                                            controller: _religion,
                                            validator: (e) {
                                              if (_religion.text.isEmpty) {
                                                return "Please enter religion";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter religion *"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Step(
                          title: const Text('Identifications and Contacts'),
                          content: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: Row(
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
                                                  BorderRadius.circular(7)),
                                              child: Container(
                                                height: 55,
                                                width: double.infinity,
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
                                                    BorderRadius.circular(7)),
                                                child: DropdownButton<String>(
                                                    value: idtypeValue,
                                                    icon: const Icon(
                                                        Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    elevation: 16,
                                                    style: const TextStyle(
                                                        color: Color(
                                                            0xFF2C3335)),
                                                    underline: Container(
                                                      height: 1,
                                                      color: Colors.transparent,
                                                    ),
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        idtypeValue =
                                                            newValue.toString();
                                                      });
                                                    },
                                                    items: _data.map(
                                                          (item) {
                                                        return DropdownMenuItem(
                                                          child: Text(
                                                            "${item['name']}*",
                                                            style: const TextStyle(
                                                                color:
                                                                Colors.black54),
                                                          ),
                                                          value:
                                                          item['id'].toString(),
                                                        );
                                                      },
                                                    ).toList()),
                                              ),
                                            ),
                                          ],
                                        )),
                                    Flexible(
                                      child: Card(
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
                                              if (_idnumber.text.isEmpty) {
                                                return "Please enter ID number";
                                              } else {
                                                return null;
                                              }
                                            },
                                            controller: _idnumber,
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  ID number"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
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
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
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
                                            onTap: () => showImagePickerModal(),
                                            child: Card(
                                              color: app_color,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(7)),
                                              child: const Padding(
                                                padding: EdgeInsets.all(10),
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
                                height: 7,
                              ),
                              Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (e) {
                                      if (_email.text.isEmpty) {
                                        return "Please enter email";
                                      } else if (!_email.text.contains("@")) {
                                        return "Please enter a valid email";
                                      } else if (!_email.text
                                          .contains(".com")) {
                                        return "Please enter a valid email";
                                      } else {
                                        return null;
                                      }
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration: kMainTextFieldDecoration
                                        .copyWith(labelText: "Enter email *"),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
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
                                            keyboardType: TextInputType.number,
                                            controller: _phone1,
                                            validator: (e) {
                                              if (_phone1.text.isEmpty) {
                                                return "Please enter phone number ";
                                              } else {
                                                return null;
                                              }
                                            },
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  phone number *"),
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
                                            keyboardType: TextInputType.number,
                                            controller: _phone2,
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter  phone 2(optional)"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextFormField(
                                    controller: _lastresidence,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: kMainTextFieldDecoration
                                        .copyWith(
                                        labelText:
                                        "Enter  address of last residence(optional)"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Step(
                          title: const Text("Occupational Info"),
                          content: Column(
                            children: [
                              Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextFormField(
                                    controller: _occupation,
                                    validator: (v) {
                                      if (_occupation.text.isEmpty) {
                                        return "Please enter occupation";
                                      } else {
                                        return null;
                                      }
                                    },
                                    style: const TextStyle(fontSize: 14),
                                    decoration:
                                    kMainTextFieldDecoration.copyWith(
                                        labelText: "Enter  occupation*"),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
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
                                            controller: _nof_employer,
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter name of employer(optional)"),
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
                                            controller: _cof_employer,
                                            keyboardType: TextInputType.number,
                                            style:
                                            const TextStyle(fontSize: 14),
                                            decoration: kMainTextFieldDecoration
                                                .copyWith(
                                                labelText:
                                                "Enter contact of employer(optional)"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Card(
                                color: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(7)),
                                  child: TextFormField(
                                    controller: _workAddress,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: kMainTextFieldDecoration
                                        .copyWith(
                                        labelText:
                                        "Enter address of work place(optional)"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Step(
                            title: const Text("Parents Info"),
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
                                              controller: _fathern,
                                              validator: (v) {
                                                if (_fathern.text.isEmpty) {
                                                  return "Enter name of father";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style:
                                              const TextStyle(fontSize: 14),
                                              decoration: kMainTextFieldDecoration
                                                  .copyWith(
                                                  labelText:
                                                  "Enter father name*"),
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
                                              controller: _fatherc,
                                              keyboardType:
                                              TextInputType.number,
                                              style:
                                              const TextStyle(fontSize: 14),
                                              decoration: kMainTextFieldDecoration
                                                  .copyWith(
                                                  labelText:
                                                  "Enter father contact(optional)"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: TextFormField(
                                      validator: (v) {
                                        if (_fatherhm.text.isEmpty) {
                                          return "Enter hometown of father";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: _fatherhm,
                                      style: const TextStyle(fontSize: 14),
                                      decoration:
                                      kMainTextFieldDecoration.copyWith(
                                          labelText:
                                          "Enter hometown of father"),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
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
                                              controller: _mothern,
                                              validator: (v) {
                                                if (_mothern.text.isEmpty) {
                                                  return "Enter name of mother";
                                                } else {
                                                  return null;
                                                }
                                              },
                                              style:
                                              const TextStyle(fontSize: 14),
                                              decoration: kMainTextFieldDecoration
                                                  .copyWith(
                                                  labelText:
                                                  "Enter mother name*"),
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
                                              controller: _motherc,
                                              keyboardType:
                                              TextInputType.number,
                                              style:
                                              const TextStyle(fontSize: 14),
                                              decoration: kMainTextFieldDecoration
                                                  .copyWith(
                                                  labelText:
                                                  "Enter mother contact (optional)"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: TextFormField(
                                      validator: (v) {
                                        if (_motherhm.text.isEmpty) {
                                          return "Enter hometown of father";
                                        } else {
                                          return null;
                                        }
                                      },
                                      controller: _motherhm,
                                      style: const TextStyle(fontSize: 14),
                                      decoration:
                                      kMainTextFieldDecoration.copyWith(
                                          labelText:
                                          "Enter hometown of mother"),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Step(
                            title: const Text("Social Media Info (optional)"),
                            content: Column(
                              children: [
                                Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: TextFormField(
                                      controller: _social_platform,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: kMainTextFieldDecoration
                                          .copyWith(
                                          labelText:
                                          "Enter social media platform(optional)"),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Card(
                                  color: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: TextFormField(
                                      controller: _social_name,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: kMainTextFieldDecoration
                                          .copyWith(
                                          labelText:
                                          "Enter social media name(optional)"),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
