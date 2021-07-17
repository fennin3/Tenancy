import 'package:flutter/material.dart';
import 'package:tenancy/screens/auth/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  bool manage = false;

  void changeUI() {
    setState(() {
      manage = !manage;
    });
  }

  void setInstalledValue() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool('installed', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !manage
              ? Container(
                  width: 293,
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xffdadada),
                  ),
                  child: Image.asset(
                    "assets/images/Signup.png",
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 293,
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xffdadada),
                  ),
                  child: Image.asset(
                    "assets/images/manage.png",
                    fit: BoxFit.cover,
                  ),
                ),
          !manage
              ? Container(
                  width: 319,
                  height: 207,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome",
                        style: TextStyle(
                          color: Color(0xff1e2022),
                          fontSize: 19,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 19),
                      SizedBox(
                        width: 319,
                        child: Text(
                          "Sign up for a landlord account and get to manage your houses and tenants.\n\n",
                          style: TextStyle(
                            color: Color(0xff77838f),
                            fontSize: 17,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: 319,
                  height: 207,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "What you can do after signup",
                        style: TextStyle(
                          color: Color(0xff1e2022),
                          fontSize: 19,
                          fontFamily: "Montserrat",
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 19),
                      SizedBox(
                        width: 319,
                        child: Text(
                          "After signing up and logging in, you get to add your houses and tenants to the platform. This makes you be able to manage them more efficiently\n\n",
                          style: TextStyle(
                            color: Color(0xff77838f),
                            fontSize: 17,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          Container(
            width: 51,
            height: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: !manage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: !manage
                        ? const Color(0xff1eae98)
                        : const Color(0xffdadada),
                  ),
                ),
                const SizedBox(width: 5.50),
                Container(
                  width: !manage ? 8 : 24,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color:
                        !manage ? Color(0xffdadada) : const Color(0xff1eae98),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
              ),
              Positioned(
                  right: -MediaQuery.of(context).size.width * 0.58,
                  bottom: -MediaQuery.of(context).size.width * 0.74,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.551,
                    backgroundColor: Color(0x301dae98),
                  )),
              Positioned(
                  left: -MediaQuery.of(context).size.width * 0.58,
                  bottom: -MediaQuery.of(context).size.width * 0.74,
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.551,
                    backgroundColor: Color(0x301dae98),
                  )),
              Positioned(
                  right: MediaQuery.of(context).size.width * 0.10,
                  bottom: MediaQuery.of(context).size.width * 0.10,
                  child: GestureDetector(
                    onTap: () {
                      setInstalledValue();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: Container(
                      width: 110,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xff1eae98),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            !manage ? "Skip" : "Next",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "SF Pro Text",
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
              Positioned(
                  left: MediaQuery.of(context).size.width * 0.10,
                  bottom: MediaQuery.of(context).size.width * 0.10,
                  child: GestureDetector(
                    onTap: () {
                      changeUI();
                    },
                    child: Container(
                      width: 110,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xff1eae98),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            !manage ? "Next" : "Previous",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "SF Pro Text",
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
            ],
          )
        ],
      ),
    ));
  }
}
