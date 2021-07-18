import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:tenancy/get_functions.dart';
import 'package:tenancy/screens/general/add_tenant.dart';
import 'package:tenancy/screens/general/tenant_detail.dart';
import 'package:tenancy/screens/general/tenants_page.dart';
import 'package:tenancy/screens/my_colors.dart';
import 'package:tenancy/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class HouseDetail extends StatefulWidget {
  const HouseDetail({Key? key, this.init_data, required this.image,required this.url}) : super(key: key);
  final Map? init_data;
  final String image;
  final String url;

  @override
  State<HouseDetail> createState() => _HouseDetailState();
}

class _HouseDetailState extends State<HouseDetail> {
  final TextEditingController _rooms = TextEditingController();
  bool showSpinner = false;
  Map data = {};

  void updateRooms() async {
    Navigator.pop(context);
    setState(() {
      showSpinner = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getStringList("data")![0];
    final userId = sharedPreferences.getStringList("data")![1];
    Map _data = {
      "user_id": userId,
      "id": data['id'].toString(),
      "value": _rooms.text
    };
    try {
      http.Response response = await http.post(
          Uri.parse(base_url + "landlord/update-occupied"),
          body: _data,
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

      if (response.statusCode < 206) {
        getIt();
        Future.delayed(
          Duration(
            seconds: 2,
          ),
        );
        setState(() {
          showSpinner = false;
        });

        Toast.show(
          '${json.decode(response.body)['message']}',
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      } else {
        setState(() {
          showSpinner = false;
        });

        Toast.show(
          '${json.decode(response.body)['message']}',
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      }
    } on SocketException {
      setState(() {
        showSpinner = false;
      });
      Toast.show(
        'No internet connection',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  void updateRoomNumber() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Update Number of rooms occupied."),
              content: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
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
                        return "Please enter number of rooms occupied";
                      } else {
                        return null;
                      }
                    },
                    style: const TextStyle(fontSize: 14),
                    decoration: kMainTextFieldDecoration.copyWith(
                        labelText: "Enter number of rooms occupied*"),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => updateRooms(),
                  child: const Text('Submit'),
                ),
              ],
            ));
  }

  void getIt() async {
    Map _houseDetail = await MyFunc.getHouseDetails(context, data['id']);
    if (_houseDetail.isNotEmpty) {
      setState(() {
        data = _houseDetail;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = widget.init_data!;
    getIt();
  }

  var _random = Random();

  @override
  Widget build(BuildContext context) {
    getIt();
    print("------------------");
    print(widget.image);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0Xf4f6faFF),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: spinkit,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      color: app_color,
                      height: size.height * 0.4,
                      child: Image.network(widget.image, fit: BoxFit.cover,),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.only(left: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black.withOpacity(0.15)),
                              child: const Center(
                                  child: Icon(Icons.arrow_back_ios,
                                      color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                _createRoute(
                                  AddTenant(
                                    houseId: data['id'],

                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.only(left: 7),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black.withOpacity(0.15)),
                              child: const Center(
                                  child: Icon(Icons.person_add_alt_1_outlined,
                                      color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 70,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              updateRoomNumber();
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black.withOpacity(0.15)),
                              child: const Center(
                                  child: Icon(Icons.bed, color: Colors.white)),
                            ),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        left: size.width * 0.05,
                        bottom: -50,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          child: Container(
                            height: 100,
                            width: size.width * 0.9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () => const TenantsPage(),
                                  child: HouseDetailWidget(
                                    icon: Icons.people,
                                    text: "Tenants",
                                    number: data['tenants'] != null
                                        ? data['tenants'].length
                                        : widget.init_data!['tenants'].length,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => updateRoomNumber(),
                                  child: HouseDetailWidget(
                                    icon: Icons.bed,
                                    text: "Rooms",
                                    number: int.parse(data['rooms']),
                                  ),
                                ),
                                HouseDetailWidget(
                                  icon: Icons.bedroom_parent,
                                  text: "Available rooms",
                                  number: int.parse(data['rooms']) -
                                      int.parse(data['occupied']),
                                ),
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: size.height * 0.06,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['district'] != false && data['city'] != false
                            ? "${data['region']['name']},  ${data['district']['name']},  ${data['city']['name']},  ${data['area']}"
                            : "${data['region']['name']},  ${data['area']}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 30,
                            color: app_color,
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Text("${data['gps']}")
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.house,
                            size: 30,
                            color: app_color,
                          ),
                          SizedBox(
                            width: size.width * 0.05,
                          ),
                          Text("${data['h_no']}")
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.035,
                      ),
                      const Text(
                        "Tenants",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (data['tenants'] != null &&
                              data['tenants'].length > 3)
                            for (var i in data['tenants'].sublist(0, 3))
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  _createRoute(
                                    TenantDetail(
                                      data: i,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: all_colors[
                                          _random.nextInt(all_colors.length)],
                                      child: Text(
                                        "${i['surname'][0]}${i['fname'][0]}",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text("${i['name']}"),
                                    subtitle: Text("${i['occupation']}"),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                  ),
                                ),
                              )
                          else if (data['tenants'] != null &&
                              data['tenants'].length < 4)
                            for (var i in data['tenants'])
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  _createRoute(
                                    TenantDetail(
                                      data: i,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: all_colors[
                                          _random.nextInt(all_colors.length)],
                                      child: const Text(
                                        "FE",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    title: Text("${i['name']}"),
                                    subtitle: Text("${i['occupation']}"),
                                    trailing:
                                        const Icon(Icons.arrow_forward_ios),
                                  ),
                                ),
                              ),
                          if (data['tenants'] != null &&
                              data['tenants'].length > 3)
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TenantsPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "See all >>",
                                  style: TextStyle(color: app_color),
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
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

class HouseDetailWidget extends StatelessWidget {
  final IconData? icon;
  final String? text;
  final int? number;

  HouseDetailWidget({this.icon, this.text, this.number});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color.fromRGBO(230, 230, 230, 1)),
            child: Icon(
              icon,
              size: 26,
            ),
          ),
          Text(
            text.toString(),
            style: const TextStyle(fontSize: 12),
          ),
          Text(number.toString())
        ],
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.easeInBack;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
