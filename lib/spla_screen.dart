import 'package:flutter/material.dart';
import 'package:tenancy/screens/auth/loginpage.dart';

class SplashScreenCust extends StatefulWidget {
  final Widget next;

  const SplashScreenCust({Key? key, required this.next}) : super(key: key);

  @override
  State<SplashScreenCust> createState() => _SplashScreenCustState();
}

class _SplashScreenCustState extends State<SplashScreenCust> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 3)).then(
      (value) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget.next,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: Image.asset(
                    "assets/images/splash.png",
                    fit: BoxFit.cover,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
