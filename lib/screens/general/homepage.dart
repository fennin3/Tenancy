import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:tenancy/screens/auth/loginpage.dart';
import 'package:tenancy/screens/general/create_house.dart';
import 'package:tenancy/screens/general/house_detail.dart';
import 'package:tenancy/screens/general/houses.dart';
import 'package:provider/provider.dart';
import 'package:tenancy/screens/general/requests_page.dart';
import 'package:tenancy/screens/general/support_page.dart';
import 'package:tenancy/screens/general/tenants_page.dart';
import 'package:tenancy/utils/provider_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math';
import 'dart:convert';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _tenants = [];
  Map _config = {};
  String _date = "";

  void getDate() {
    var date = DateTime.now();

    setState(() {
      _date = DateFormat('EEEE, d MMM, yyyy').format(date);
    });
  }

  List getAllTenants(Map data) {
    for (var house in data['houses']) {
      setState(() {});
    }
    return _tenants;
  }

  String countTenants(data) {
    num _totalTenants = 0;
    for (var i in data['houses']) {
      if (i['tenants'] != null) {
        setState(() {
          _totalTenants = _totalTenants + i['tenants'].length;
        });
      }
    }
    return _totalTenants.toString();
  }

  String countTotalRooms(data) {
    int _totalRooms = 0;
    for (var i in data['houses']) {
      setState(() {
        _totalRooms = _totalRooms + int.parse(i['rooms']);
      });
    }
    return _totalRooms.toString();
  }

  String countAvailbleRooms(data) {
    int _totalRooms = 0;
    for (var i in data['houses']) {
      setState(() {
        _totalRooms =
            _totalRooms + (int.parse(i['rooms']) - int.parse(i['occupied']));
      });
    }
    return _totalRooms.toString();
  }

  void getDefaultConfig() async {
    http.Response response =
        await http.get(Uri.parse(base_url + "general/get-configs/"));
    if (response.statusCode < 206) {
      if (mounted) {
        setState(() {
          _config = json.decode(response.body)['data'];

        });
      }
    } else {
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final _data = Provider.of<UserDetails>(context, listen: true);
    _data.getUserDetails(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDefaultConfig();
    getDate();
  }

  @override
  Widget build(BuildContext context) {
    final _data = Provider.of<UserDetails>(context, listen: true);
    final _userData = _data.userData;

    var size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: MyDrawer(
        logo: _config.isNotEmpty ? _config['siteLogo'] : "",
        url: _config.isNotEmpty ? _config['public_url'] : "",
        exte: _config['allowedExtensions'],
      ),
      backgroundColor: const Color(0Xf4f6faFF),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomePageNav(
                  name: _userData['fname'] != null && _userData['oname'] != null
                      ? "${_userData['fname'][0]}${_userData['oname'][0]}"
                      : "",
                ),
                SizedBox(
                  height: size.height * 0.023,
                ),
                WelcomeWidget(
                  size: size,
                  name: _userData['name'],
                  date: _date,
                ),
                _userData['houses'] == null
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Row(
                              children: [
                                for (var i in [1, 2, 3])
                                  const HouseRowItem(
                                    num: 1,
                                    data: {},
                                    shim: true,
                                  )
                              ],
                            )),
                      )
                    : _userData['houses'].isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: [
                                    for (var i in _userData['houses'])
                                      GestureDetector(
                                        onTap: () => Navigator.of(context).push(
                                          _createRoute(
                                            HouseDetail(
                                              image:
                                                  _config['background'] ?? "",
                                              init_data: i,
                                              url: _config['public_url'],
                                            ),
                                          ),
                                        ),
                                        child: HouseRowItem(
                                          num: _userData['houses'].indexOf(i),
                                          data: i,
                                          shim: false,
                                        ),
                                      ),
                                  ],
                                )),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 30.0,
                                      bottom: 30,
                                    ),
                                    child: Text(
                                      "No Houses",
                                      style: TextStyle(fontSize: 25),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .push(_createRoute(AddHouse())),
                                    child: const Card(
                                      elevation: 5,
                                      color: app_color,
                                      child: Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          "Add a house",
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                if (_userData['houses'] != null &&
                    _userData['houses'].length > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            _createRoute(
                              HousesPage(
                                image: _config['background'],
                                data: _userData['houses'],
                                url: _config['public_url'] ?? "",
                              ),
                            ),
                          ),
                          child: const Text(
                            "See all >>",
                            style: TextStyle(color: app_color),
                          ),
                        )
                      ],
                    ),
                  ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Info",
                        style: TextStyle(
                            color: faintColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Container(
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          padding: const EdgeInsets.all(1),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TenantsPage(),
                                    ),
                                  );
                                },
                                child: CommWidget(
                                  title: "Tenants",
                                  icon: Icons.people,
                                  num: _userData['houses'] == null
                                      ? "0"
                                      : countTenants(_userData),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Container(
                                  height: 1,
                                  color: faintColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  _createRoute(
                                    HousesPage(
                                      image: _config['background'] ?? "",
                                      data: _userData['houses'],
                                      url: _config['public_url'] ?? "",
                                    ),
                                  ),
                                ),
                                child: CommWidget(
                                  title: "Houses",
                                  num: _userData['houses'] != null
                                      ? "${_userData['houses'].length}"
                                      : "0",
                                  icon: Icons.house,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Container(
                                  height: 1,
                                  color: faintColor,
                                ),
                              ),
                              CommWidget(
                                title: "Total Rooms",
                                num: _userData['houses'] == null
                                    ? "0"
                                    : countTotalRooms(_userData),
                                icon: Icons.bed,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Container(
                                  height: 1,
                                  color: faintColor,
                                ),
                              ),
                              CommWidget(
                                title: "Available Rooms",
                                num: _userData['houses'] == null
                                    ? "0"
                                    : countAvailbleRooms(_userData),
                                icon: Icons.bed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyDrawer extends StatefulWidget {
  final String logo;
  final String url;
  final String exte;

  const MyDrawer(
      {Key? key, required this.logo, required this.url, required this.exte})
      : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  SharedPreferences? sharedPreferences;

  void initShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initShared();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
              decoration: BoxDecoration(
                  color: widget.logo.isEmpty ? app_color : Colors.transparent),
              child: Image.asset(
                "assets/images/logo.png",
                fit: BoxFit.fitHeight,
              )),
          ListTile(
            title: const Text(
              'Add House',
              style: TextStyle(fontSize: 16),
            ),
            leading: const Icon(
              Icons.house,
              color: app_color,
            ),
            onTap: () {
              Navigator.of(context).push(
                _createRoute(
                  const AddHouse(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Add Tenant',
              style: TextStyle(fontSize: 16),
            ),
            leading: const Icon(
              Icons.person_add_alt_1_outlined,
              color: app_color,
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(
              Icons.receipt_long,
              color: app_color,
            ),
            title: const Text(
              'My Requests',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.support_agent,
              color: app_color,
            ),
            title: const Text(
              'Support',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupportPage(
                    url: widget.url,
                    extensions: widget.exte.toString().split(","),
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: app_color,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 16),
            ),
            onTap: () {
              sharedPreferences!.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (BuildContext context) => LoginPage(),
                ),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class HouseRowItem extends StatefulWidget {
  final Map data;
  final bool shim;
  final int num;

  const HouseRowItem(
      {Key? key, required this.data, required this.shim, required this.num})
      : super(key: key);

  @override
  State<HouseRowItem> createState() => _HouseRowItemState();
}

class _HouseRowItemState extends State<HouseRowItem> {
  final TextEditingController _reason = TextEditingController();

  removeTenant(String id) async {
    Navigator.pop(context);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final pref = sharedPreferences.getStringList('data');
    Map _data = {
      "user_id": pref![1],
      "data_id": id,
      "type": "house",
      "reason": _reason.text,
    };
    try {
      http.Response response = await http.post(
        Uri.parse(base_url + "landlord/remove-request"),
        body: _data,
        headers: {HttpHeaders.authorizationHeader: "Bearer ${pref[0]}"},
      );

      if (response.statusCode < 206) {
        String message = json.decode(response.body)['message'];

        Toast.show(
          message,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      } else {
        String message = json.decode(response.body)['message'];

        Toast.show(
          message,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      }
      // Navigator.pop(context);
    } on SocketException {
      Toast.show(
        "No internet connection",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  void deleteTenant() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Remove House"),
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
                    maxLines: 4,
                    controller: _reason,
                    validator: (e) {
                      if (_reason.text.isEmpty) {
                        return "Please enter your reason";
                      } else {
                        return null;
                      }
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: kMainTextFieldDecoration.copyWith(
                      labelText: "Enter reason*",
                      labelStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => removeTenant(widget.data['id'].toString()),
                  child: const Text('Proceed'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    Future<String> getAddress(String gps) async {
      final coordinates = Coordinates(
        double.parse(gps.split(" ")[0]),
        double.parse(gps.split(" ")[1]),
      );
      final addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      final first = addresses.first;

      return first.addressLine;
    }

    var _random = Random();
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          height: 140,
          width: 280,
          child: Padding(
              padding:
                  const EdgeInsets.only(right: 13.0, left: 13.0, top: 13.0),
              child: !widget.shim
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: app_color,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  widget.data['id'].toString(),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => deleteTenant(),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          widget.data['name'],
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "${widget.data['gps']}",
                          style: const TextStyle(color: faintColor),
                        )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimWidget(
                              color: app_color,
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: app_color,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const ShimWidget(
                              color: faintColor,
                              child: Icon(
                                Icons.more_horiz,
                                color: faintColor,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        const ShimWidget(
                          color: Colors.black,
                          child: Text(
                            "..........",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        const ShimWidget(
                          color: faintColor,
                          child: Text(
                            "........",
                            style: TextStyle(color: faintColor),
                          ),
                        )
                      ],
                    )),
        ),
      ),
    );
  }
}

class WelcomeWidget extends StatelessWidget {
  const WelcomeWidget(
      {Key? key, required this.size, required this.name, required this.date})
      : super(key: key);

  final Size size;
  final String name;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(color: faintColor),
          ),
          SizedBox(
            height: size.height * 0.010,
          ),
          const Text(
            "Welcome back,",
            style: TextStyle(
                color: faintColor, fontSize: 35, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: size.height * 0.002,
          ),
          Text(
            name != null ? name : "...........",
            style: const TextStyle(
                color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: size.height * 0.0660,
          ),
          const Text(
            "My Properties",
            style: TextStyle(
                color: faintColor, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}

class HomePageNav extends StatelessWidget {
  final String name;

  const HomePageNav({Key? key, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openDrawer();
              },
              child: const Icon(
                Icons.menu,
                size: 30,
              ),
            ),
          ),
          CircleAvatar(
            radius: 25,
            backgroundColor: app_color,
            child: Center(
              child: Text(name),
            ),
          )
        ],
      ),
    );
  }
}

class CommWidget extends StatelessWidget {
  final String? title;
  final String? num;
  final IconData? icon;

  CommWidget({this.title, this.num, this.icon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 27,
        color: Colors.black,
      ),
      title: Text(title ?? ""),
      trailing: Container(
        width: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: app_color, borderRadius: BorderRadius.circular(10)),
              child: Text(
                num ?? "",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black,
            )
          ],
        ),
      ),
    );
  }
}

Route _createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(0.0, 1.0);
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

class ShimWidget extends StatelessWidget {
  const ShimWidget({Key? key, required this.child, required this.color})
      : super(key: key);
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      child: child,
      baseColor: color,
      highlightColor: Colors.white,
      direction: ShimmerDirection.rtl,
    );
  }
}
