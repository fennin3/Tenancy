import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:toast/toast.dart';

class AddHouse extends StatefulWidget {
  const AddHouse({Key? key}) : super(key: key);

  @override
  _AddHouseState createState() => _AddHouseState();
}

class _AddHouseState extends State<AddHouse> {
  bool showSpinner = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _housename = TextEditingController();
  final TextEditingController _housenumber = TextEditingController();
  final TextEditingController _area = TextEditingController();
  final TextEditingController _rooms = TextEditingController();
  final TextEditingController _gps = TextEditingController();
  List _regions = [];
  List _cities = [];
  List _districts = [];
  String? regionId;
  List _data = [];
  String? district;
  String? _city;

  // getLocationData() async {
  //   setState(() {
  //     showSpinner = true;
  //   });
  //   Location location = new Location();
  //
  //   bool _serviceEnabled;
  //   PermissionStatus _permissionGranted;
  //   LocationData _locationData;
  //
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       return;
  //     }
  //   }
  //
  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }
  //
  //   _locationData = await location.getLocation();
  //   final coordinates =
  //       Coordinates(_locationData.latitude, _locationData.longitude);
  //   final addresses =
  //       await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //   final first = addresses.first;
  //   setState(() {
  //     _gps = first.addressLine;
  //     showSpinner = false;
  //   });
  // }

  void getInitData() async {
    setState(() {
      showSpinner = true;
    });
    _data = await MyFunc.getIDTypes(context);
    _regions = await MyFunc.getRegions(context);
    setState(() {
      _data = _data;
      _regions = _regions;
      showSpinner = false;
    });
  }

  void _createHouse() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getStringList("data")![0];
    final userId = sharedPreferences.getStringList("data")![1];
    setState(() {
      showSpinner = true;
    });
    Map data = {
      "user_id": userId,
      "name": _housename.text,
      "house_number": _housenumber.text,
      "region": regionId,
      "city": _city,
      "district": district,
      "area": _area.text,
      "gps_address": _gps.text,
      "rooms": _rooms.text
    };

    try {
      http.Response response = await http.post(
          Uri.parse("${base_url}landlord/add-house"),
          body: data,
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

      if (response.statusCode < 206) {
        setState(() {
          showSpinner = false;
        });
        Toast.show(
          "${json.decode(response.body)['message']}",
          context,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
        Future.delayed(const Duration(seconds: 1)).then(
          (value) => Navigator.pop(context),
        );
      } else {
        Toast.show(
          "${json.decode(response.body)['message']}",
          context,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
        setState(() {
          showSpinner = false;
        });
      }
    } on SocketException {
      setState(() {
        showSpinner = false;
      });

      Toast.show(
        "No internet connection.",
        context,
        gravity: Toast.BOTTOM,
        duration: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _housenumber.dispose();
    _housename.dispose();
    _area.dispose();
    _rooms.dispose();
    _gps.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInitData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0Xf4f6faFF),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: spinkit,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, top: 5, bottom: 10),
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
                        "Add House",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      const SizedBox()
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7)),
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextFormField(
                                  controller: _housename,
                                  validator: (e) {
                                    if (_housename.text.isEmpty) {
                                      return "Please enter house name";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(fontSize: 16),
                                  decoration: kMainTextFieldDecoration.copyWith(
                                      labelText: "Enter your house name *"),
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
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextFormField(
                                  controller: _housenumber,
                                  validator: (e) {
                                    if (_housenumber.text.isEmpty) {
                                      return "Please enter house number";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(fontSize: 16),
                                  decoration: kMainTextFieldDecoration.copyWith(
                                      labelText: "Enter your house number *"),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 7,
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
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    height: 55,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: DropdownButton<String>(
                                        value: regionId,
                                        icon: const Icon(Icons.arrow_drop_down),
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
                                            regionId = newValue.toString();
                                            _cities = _regions
                                                .where((id) =>
                                                    id['id'].toString() ==
                                                    newValue.toString())
                                                .toList()[0]['cities'];
                                          });
                                        },
                                        items: _regions.map(
                                          (item) {
                                            return DropdownMenuItem(
                                              child: Text(
                                                "${item['name']}",
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                              ),
                                              value: item['id'].toString(),
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
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    height: 55,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: DropdownButton<String?>(
                                        value: _city,
                                        icon: const Icon(Icons.arrow_drop_down),
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
                                            _city = newValue.toString();
                                            _districts = _cities
                                                .where((id) =>
                                                    id['id'].toString() ==
                                                    newValue.toString())
                                                .toList()[0]['districts'];
                                          });
                                        },
                                        items: _cities.map(
                                          (item) {
                                            return DropdownMenuItem(
                                              child: Text(
                                                "${item['name']}",
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                              ),
                                              value: item['id'].toString(),
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
                                      borderRadius: BorderRadius.circular(7)),
                                  child: Container(
                                    height: 55,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(7)),
                                    child: DropdownButton<String?>(
                                        value: district,
                                        icon: const Icon(Icons.arrow_drop_down),
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
                                            district = newValue.toString();
                                          });
                                        },
                                        items: _districts.map(
                                          (item) {
                                            return DropdownMenuItem(
                                              child: Text(
                                                "${item['name']}",
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                              ),
                                              value: item['id'].toString(),
                                            );
                                          },
                                        ).toList()),
                                  ),
                                )
                              ],
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
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextFormField(
                                  controller: _area,
                                  validator: (e) {
                                    if (_area.text.isEmpty) {
                                      return "Please enter area";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(fontSize: 16),
                                  decoration: kMainTextFieldDecoration.copyWith(
                                      labelText: "Enter your area *"),
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
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextFormField(
                                  controller: _gps,
                                  validator: (e) {
                                    if (_gps.text.isEmpty) {
                                      return "Please enter digital address";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(fontSize: 16),
                                  decoration: kMainTextFieldDecoration.copyWith(
                                      labelText: "Enter your digital address"),
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
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(7)),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _rooms,
                                  validator: (e) {
                                    if (_rooms.text.isEmpty) {
                                      return "Please enter number of rooms";
                                    } else {
                                      return null;
                                    }
                                  },
                                  style: const TextStyle(fontSize: 16),
                                  decoration: kMainTextFieldDecoration.copyWith(
                                      labelText: "Enter number of rooms *"),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  if (regionId!.isEmpty) {
                                    const snackBar = SnackBar(
                                      content:
                                          Text("Region field is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_city!.isEmpty) {
                                    const snackBar = SnackBar(
                                      content: Text("City field is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (district!.isEmpty) {
                                    const snackBar = SnackBar(
                                      content:
                                          Text("District field is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else if (_area.text.isEmpty) {
                                    const snackBar = SnackBar(
                                      content:
                                          Text("District field is required."),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    _createHouse();
                                  }
                                }
                              },
                              child: Card(
                                elevation: 10,
                                color: app_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text(
                                    "Save",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            )
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
      ),
    );
  }
}
