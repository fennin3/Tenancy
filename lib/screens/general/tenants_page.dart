import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:tenancy/screens/general/tenant_detail.dart';
import 'package:tenancy/screens/my_colors.dart';
import 'dart:math';

class TenantsPage extends StatefulWidget {
  const TenantsPage({Key? key}) : super(key: key);

  @override
  _TenantsPageState createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  List _data = [];
  List _backup = [];
  bool showSpinner = false;
  String _value = "";

  getAllTenants() async {
    setState(() {
      showSpinner = true;
    });
    _data = await MyFunc.getAllTenants(context);

    try {
      print(_data[0]);
    } catch (e) {
      setState(() {
        _data = [];
      });
    }
    setState(() {
      _backup = _data;
      _data = _data;
      showSpinner = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllTenants();
  }

  @override
  Widget build(BuildContext context) {
    var _random = Random();

    return Scaffold(
      backgroundColor: Color(0Xf4f6faFF),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        progressIndicator: spinkit,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _value = value;
                            if (_value.length < 1) {
                              _data = _backup;
                            }
                          });
                        },
                        style: TextStyle(fontSize: 14),
                        decoration: kMainTextFieldDecoration.copyWith(
                          hintText: "Search...",
                          hintStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          print(_value);
                          setState(() {
                            if (_value.isNotEmpty) {
                              _data = _data
                                  .where((element) => element['name']
                                      .toLowerCase()
                                      .contains(_value.toLowerCase()))
                                  .toList();
                            } else {
                              _data = _backup;
                            }
                          });
                        },
                        child: const Icon(
                          Icons.search,
                          size: 21,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Container(
                      child: _data.length > 0
                          ? ListView.builder(
                              itemCount: _data.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TenantDetail(
                                          data: _data[index],
                                        ),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: all_colors[
                                        _random.nextInt(all_colors.length)],
                                    child: Text(
                                      "${_data[index]['fname'][0]}${_data[index]['surname'][0]}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Text("${_data[index]['name']}"),
                                  subtitle: const Text("Software Developer"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                );
                              },
                            )
                          : const Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Text(
                                "No Data",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ))),
            ],
          ),
        ),
      ),
    );
  }
}
