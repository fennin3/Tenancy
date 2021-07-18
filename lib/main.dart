import 'package:flutter/material.dart';
import 'package:tenancy/screens/auth/loginpage.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:google_fonts/google_fonts.dart';
import 'package:tenancy/screens/general/homepage.dart';
import 'package:tenancy/screens/intro.dart';
import 'package:tenancy/spla_screen.dart';
import 'package:tenancy/utils/provider_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() async {
  timeDilation = 2.0;
  bool loggedIn = false;
  bool installed = false;
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  if (sharedPreferences.getStringList("data") != null) {
    loggedIn = true;
  }
  if (sharedPreferences.getBool("installed") != null) {
    installed = true;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserDetails>(
          create: (_) => UserDetails(),
        ),
      ],
      child: MyApp(
        loggedIn: loggedIn,
        installed: installed,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, required this.loggedIn, required this.installed})
      : super(key: key);

  final bool loggedIn;
  final bool installed;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: !widget.installed
          ? const SplashScreenCust(
              next: IntroScreen(),
            )
          : widget.loggedIn
              ? const SplashScreenCust(
                  next: HomePage(),
                )
              : SplashScreenCust(
                  next: LoginPage(),
                ),
    );
  }
}
