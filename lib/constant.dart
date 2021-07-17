import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

const faintColor = Colors.black45;

const  spinkit = SpinKitThreeBounce(
  color: app_color,
  size: 22.0,
  duration: Duration(seconds: 1),
);

const kTextFieldDecoration = InputDecoration(
    hintText: 'Enter a value',
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: app_color),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: app_color),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: app_color),
    ));

const kMainTextFieldDecoration = InputDecoration(
    labelStyle: TextStyle(fontSize: 12),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: app_color),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: app_color),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: app_color),
    ));


const app_color = Color.fromRGBO(30, 174, 152, 1);

const knewinput =
    InputDecoration(border: UnderlineInputBorder(), labelText: 'Enter your ID', hintStyle: TextStyle(fontSize: 13));
