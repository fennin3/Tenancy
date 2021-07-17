import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tenancy/get_functions.dart';

class UserDetails with ChangeNotifier{
  Map userData = {};
  late bool loading;
  List requests = [];
  List tickets = [];

  void getUserDetails(context)async{
    userData = await MyFunc.getUserDetails(context);

    notifyListeners();
  }

  void getRequests(context)async{
    requests = await MyFunc.getRequests(context);

    notifyListeners();
  }

  void getTickets(context)async{
    tickets = await MyFunc.getTickets(context);
    notifyListeners();
  }
}