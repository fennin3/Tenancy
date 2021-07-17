import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:tenancy/screens/general/homepage.dart';
import 'dart:convert';
import 'package:tenancy/screens/auth/signup_page.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map _config = {};
  bool showSpinner = false;

  final TextEditingController _id = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void getDefaultConfig() async {
    setState(() {
      showSpinner = true;
    });
    http.Response response =
        await http.get(Uri.parse(base_url + "general/get-configs/"));
    if (response.statusCode < 206) {
      if (mounted) {
        setState(() {
          _config = json.decode(response.body)['data'];
          print(_config);
          showSpinner = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          showSpinner = false;
        });
      }
      Toast.show("No Internet Connection", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      showSpinner = true;
    });
    Map _data = _config.isNotEmpty && _config['use_password'].toString() == "1"
        ? {"user_id": _id.text, "password": _password.text}
        : {
            "user_id": _id.text,
          };

    http.Response response = await http
        .post(Uri.parse(base_url + "landlord/login"), body: _data)
        .timeout(Duration(seconds: 20), onTimeout: () {
      Toast.show("No internet connection", context);
      throw TimeoutException('The connection has timed out, Please try again!');
    });

    if (response.statusCode < 206) {
      final _res = json.decode(response.body);
      print(_res);
      final List<String> data = [
        _res['token'],
        _res['data']['id'],
        _res['data']['fname'],
        _res['data']['oname'],
        _res['data']['phone'],
        _res['data']['email'],
      ];
      sharedPreferences.setStringList('data', data);
      setState(() {
        showSpinner = false;
      });
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      print(json.decode(response.body));
      Toast.show(
        json.decode(response.body)['message'],
        context,
        gravity: Toast.BOTTOM,
        duration: Toast.LENGTH_LONG,
      );
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDefaultConfig();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: spinkit,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: size.height * 0.5,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage(
                          "assets/images/back2.jpg",
                        ),
                        fit: BoxFit.cover,
                      )),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                        child: Container(
                          width: double.infinity,
                          color: Colors.black26,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: "logo",
                                  child: Container(
                                    height: 90,
                                    width: 90,
                                    child:
                                        Image.asset("assets/images/logo.png"),
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
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: _config.isNotEmpty &&
                              _config['use_password'].toString() == "1"
                          ? -90
                          : -40,
                      left: size.width * 0.1,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: const Color.fromRGBO(242, 250, 252, 0.6),
                        elevation: 10,
                        child: Container(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            height: _config.isNotEmpty &&
                                    _config['use_password'].toString() == "1"
                                ? 180
                                : 90,
                            width: size.width * 0.8,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(242, 250, 252, 0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _id,
                                  decoration: knewinput,
                                  // textAlign: TextAlign.start,
                                ),
                                if (_config.isNotEmpty &&
                                    _config['use_password'].toString() == "1")
                                  TextField(
                                    controller: _password,
                                    decoration: knewinput.copyWith(
                                        labelText: "Enter your password"),
                                    // textAlign: TextAlign.start,
                                  ),
                              ],
                            )),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: _config.isNotEmpty &&
                          _config['use_password'].toString() == "1"
                      ? size.height * 0.15
                      : size.height * 0.11,
                ),
                GestureDetector(
                  onTap: () => login(),
                  // onTap: () => Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => const HomePage())),
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: app_color,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.15,
                ),
                const Text(
                  "Don't have an account yet?",
                  style: TextStyle(color: faintColor),
                ),
                const SizedBox(
                  height: 2,
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    _createRoute(
                      SignUpPage(
                        pass: int.parse(_config['use_password']),
                      ),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: app_color, fontSize: 16),
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

// Container(
// decoration: const BoxDecoration(
// image: DecorationImage(
// image: AssetImage("assets/images/back.png"),
// fit: BoxFit.cover,
// ),
// ),
// child: BackdropFilter(
// filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
// child: Container(
// width: double.infinity,
// color: const Color.fromRGBO(242, 250, 252, 0.2),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// SizedBox(
// height: MediaQuery.of(context).size.height * 0.06,
// ),
// const Icon(
// Icons.house,
// size: 70,
// color: Color.fromRGBO(35, 72, 120, 1),
// ),
// SizedBox(
// height: MediaQuery.of(context).size.height * 0.06,
// ),
// const Text(
// "Login",
// style: TextStyle(
// fontSize: 31,
// fontWeight: FontWeight.bold,
// fontStyle: FontStyle.italic,
// color: Color.fromRGBO(35, 72, 120, 1),
// ),
// )
// ],
// ),
// ),
// ) /* add child content here */,
// )
