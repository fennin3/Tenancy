import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

const base_url = "https://tenancy.colorbrace.com/api/";
// general/get-id-types/

class MyFunc {
  static Future<List> getIDTypes(context) async {
    List _data = [];
    try {
      http.Response response = await http.get(
        Uri.parse("${base_url}general/get-id-types/"),
      );
      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      }
    } on SocketException {
      Toast.show(
        'No internet connection',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
    return _data;
  }

  static Future<List> getRegions(context) async {
    List _data = [];
    try {
      http.Response response = await http.get(
        Uri.parse("${base_url}general/get-regions/"),
      );
      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      }
    } on SocketException {
      Toast.show(
        'No internet connection',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }

    return _data;
  }

  static Future<List> getDistricts(cityId, context) async {
    List _data = [];
    try {
      http.Response response = await http.get(
        Uri.parse("${base_url}general/general/get-cities-districts/$cityId/"),
      );
      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      }
    } on SocketException {
      Toast.show(
        'No internet connection',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
    return _data;
  }

  static Future<List> getCities(regionId, context) async {
    List _data = [];
    try {
      http.Response response = await http.get(
        Uri.parse("${base_url}general/general/get-cities/$regionId/"),
      );
      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      }
    } on SocketException {
      Toast.show(
        'No internet connection',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
    return _data;
  }

  static getUserDetails(context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final List? _pref = sharedPreferences.getStringList("data");

    Map _data = {};

    http.Response response = await http
        .get(Uri.parse(base_url + "landlord/get-user/${_pref![1]}/"), headers: {
      HttpHeaders.authorizationHeader: "Bearer ${_pref[0]}"
    }).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode < 206) {
      _data = json.decode(response.body)['data'];
    } else {}

    return _data;
  }

  static getAllTenants(context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final List? _pref = sharedPreferences.getStringList("data");

    List _data = [];
    try {
      http.Response response = await http.get(
          Uri.parse(base_url + "landlord/get-tenants/${_pref![1]}/"),
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${_pref[0]}"
          }).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          Toast.show(
            "No internet connection",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        },
      );

      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      } else {}
    } on SocketException {
      _data = [];
      Toast.show(
        "No internet connection",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
    return _data;
  }

  static getHouseDetails(context, hsId) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final List? _pref = sharedPreferences.getStringList("data");

    Map _data = {};
    try {
      http.Response response = await http.get(
          Uri.parse(base_url + "landlord/get-house/$hsId/"),
          headers: {HttpHeaders.authorizationHeader: "Bearer ${_pref![0]}"});

      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      } else {}
    } on SocketException {
      Toast.show(
        'No internet connection',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
    return _data;
  }

  static getRequests(context)async{
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final List? _pref = sharedPreferences.getStringList("data");

    List _data = [];
    try {
      http.Response response = await http.get(
          Uri.parse(base_url + "landlord/get-requests/${_pref![1]}/"),
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${_pref[0]}"
          }).timeout(
        const Duration(seconds: 16),
        onTimeout: () {
          Toast.show(
            "No internet connection",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        },
      );

      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      } else {}
    } on SocketException {
      _data = [];

    }
    return _data;
  }
  static getTickets(context)async{
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final List? _pref = sharedPreferences.getStringList("data");

    List _data = [];
    try {
      http.Response response = await http.get(
          Uri.parse(base_url + "landlord/get-tickets/${_pref![1]}/"),
          headers: {
            HttpHeaders.authorizationHeader: "Bearer ${_pref[0]}"
          }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          Toast.show(
            "No internet connection",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
          );
          throw TimeoutException(
              'The connection has timed out, Please try again!');
        },
      );

      if (response.statusCode < 206) {
        _data = json.decode(response.body)['data'];
      } else {}
    } on SocketException {
      _data = [];

    }
    return _data;
  }
}
