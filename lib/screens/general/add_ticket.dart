import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tenancy/constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:tenancy/get_functions.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';

class AddTicket extends StatefulWidget {
  const AddTicket({Key? key}) : super(key: key);

  @override
  _AddTicketState createState() => _AddTicketState();
}

class _AddTicketState extends State<AddTicket> {
  bool showSpinner = false;
  final TextEditingController _subject = TextEditingController();
  final TextEditingController _body = TextEditingController();
  String filepath = "";

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path.toString());
      setState(() {
        filepath = file.path;
      });
    } else {
      // User canceled the picker
    }
    print(filepath);
  }


  void AddTicket()async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final token = sharedPreferences.getStringList("data")![0];
    final userId = sharedPreferences.getStringList("data")![1];
    setState(() {
      showSpinner = true;
    });

    final Map<String, String> data = {
      "user_id": userId,
      "subject": _subject.text,
      "message": _body.text,

    };


    try{
      final response =
      http.MultipartRequest('POST', Uri.parse("${base_url}landlord/create-ticket"));


      if(filepath.isNotEmpty){
        response.files
            .add(await http.MultipartFile.fromPath("ticket_file", filepath));
      }

      response.fields.addAll(data);
      response.headers['authorization'] = "Bearer $token";

      var streamedResponse = await response.send();
      var res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode < 206) {
        Toast.show(
          "${json.decode(res.body)}",
          context,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
        Future.delayed(
          const Duration(
            seconds: 1,
          ),
        );
        // Navigator.pop(context);
      } else {
        Toast.show(
          "${json.decode(res.body)['message']}",
          context,
          gravity: Toast.BOTTOM,
          duration: Toast.LENGTH_LONG,
        );
      }
      print(res.statusCode);
      setState(() {
        showSpinner = false;
      });
    }
    on SocketException{
      setState(() {
        showSpinner = false;
      });
      Toast.show(
        "No internet connection",
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
    _subject.dispose();
    _body.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0Xf4f6faFF),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: spinkit,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 30,
                        width: 30,
                        padding: const EdgeInsets.only(left: 7),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.4)),
                        child: const Center(
                            child: Icon(Icons.arrow_back_ios,
                                color: Colors.white)),
                      ),
                    ),
                    const Text(
                      "Add Ticket",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: TextFormField(
                        controller: _subject,
                        validator: (e) {
                          if (_subject.text.isEmpty) {
                            return "Please Subject";
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(fontSize: 16),
                        decoration: kMainTextFieldDecoration.copyWith(
                          labelText: "Enter subject*",
                          labelStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.only(left: 20, right: 10),
                      child: TextFormField(
                        maxLines: 5,
                        controller: _body,
                        validator: (e) {
                          if (_body.text.isEmpty) {
                            return "Please message";
                          } else {
                            return null;
                          }
                        },
                        style: const TextStyle(fontSize: 16),
                        decoration: kMainTextFieldDecoration.copyWith(
                          labelText: "Enter message*",
                          labelStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.only(
                          left: 20, right: 10, top: 7, bottom: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                                filepath.isEmpty ? "Upload file (optional)" : filepath),
                          ),
                          GestureDetector(
                            onTap: ()=> pickFile(),
                            child: const Icon(
                              Icons.upload_file,
                              color: app_color,
                              size: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: ()=>Navigator.pop(context),
                          child: Container(
                            color: app_color,
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: (){
                            AddTicket();
                          },
                          child: Container(
                            color: app_color,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: const Text(
                              "Submit",
                              style: TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
