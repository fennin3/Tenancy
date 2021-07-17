import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class TenantDetail extends StatefulWidget {
  final Map data;

  const TenantDetail({Key? key, required this.data}) : super(key: key);

  @override
  State<TenantDetail> createState() => _TenantDetailState();
}

class _TenantDetailState extends State<TenantDetail> {
  final TextEditingController _reason = TextEditingController();
  bool showSpinner = false;

  removeTenant() async {
    Navigator.pop(context);
    setState(() {
      showSpinner = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final pref = sharedPreferences.getStringList('data');
    Map _data = {
      "user_id": pref![1],
      "data_id": widget.data['id'],
      "type": "tenant",
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
        setState(() {
          showSpinner = false;
        });

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
      setState(() {
        showSpinner = false;
      });
    }
  }

  void deleteTenant() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Remove tenant."),
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
                  onPressed: () => removeTenant(),
                  child: const Text('Submit'),
                ),
              ],
            ));
  }

  _launchCaller(String number) async {
    String url = "tel:$number";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not call $url';
    }
  }

  _launchMailer(String email) async {
    String url = "mailto:$email";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not mail $url';
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _reason.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data);
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0Xf4f6faFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Tenant",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    const SizedBox()
                  ],
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height * 0.025,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 45,
                          child: Text(
                            "${widget.data['surname'][0]}${widget.data['fname'][0]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _launchCaller(widget.data['phone']);
                          },
                          child: const Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(
                                Icons.phone,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () => _launchMailer(widget.data['email']),
                          child: const Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: Icon(
                                Icons.email,
                                size: 20,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TenantInfoWidget(
                      title: "Name",
                      text: widget.data['name'],
                    ),
                    TenantInfoWidget(
                      title: "Date Of Birth",
                      text: "${widget.data['dob']}",
                    ),
                    Row(
                      children: [
                        Flexible(
                            child: TenantInfoWidget(
                          title: "Place Of Birth",
                          text: "${widget.data['place_of_birth']}",
                        )),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Hometown",
                            text: "${widget.data['hometown']}",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Gender",
                            text: "${widget.data['gender']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Nationality",
                            text: "${widget.data['nationality']}",
                          ),
                        ),
                      ],
                    ),
                    TenantInfoWidget(
                      title: "Religion",
                      text: "${widget.data['religion']}",
                    ),
                    TenantInfoWidget(
                      title: "Email",
                      text: "${widget.data['email']}",
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Phone 1",
                            text: "${widget.data['phone']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Phone 2",
                            text: "${widget.data['phone2']}",
                          ),
                        ),
                      ],
                    ),
                    TenantInfoWidget(
                      title: "Occupation",
                      text: "${widget.data['occupation']}",
                    ),
                    TenantInfoWidget(
                      title: "Last Residence",
                      text: "${widget.data['last_residence']}",
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Employer Name",
                            text: "${widget.data['nof_employer']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Employer Contact",
                            text: "${widget.data['cof_employer']}",
                          ),
                        ),
                      ],
                    ),
                    TenantInfoWidget(
                      title: "Work Place",
                      text: "${widget.data['work_place']}",
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Father Name",
                            text: "${widget.data['f_name']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Father Contact",
                            text: "${widget.data['f_contact']}",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Mother Name",
                            text: "${widget.data['m_name']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Mother Contact",
                            text: "${widget.data['m_contact']}",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Father Hometown",
                            text: "${widget.data['f_hometown']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Mother Hometown",
                            text: "${widget.data['m_hometown']}",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Social Platform",
                            text: "${widget.data['s_platform']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "Social Name",
                            text: "${widget.data['s_name']}",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: TenantInfoWidget(
                            title: "ID Type",
                            text: "${widget.data['id_type']['name']}",
                          ),
                        ),
                        Flexible(
                          child: TenantInfoWidget(
                            title: "ID Number",
                            text: "${widget.data['id_no']}",
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("ID Image", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                          SizedBox(height: 10,),
                          Container(
                            height: 300,
                            width: double.infinity,
                            child: Image.network(
                              widget.data['id_image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: app_color,
        onPressed: () => deleteTenant(),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
    );
  }
}

class TenantInfoWidget extends StatelessWidget {
  final String title;
  final String text;

  TenantInfoWidget({required this.text, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
