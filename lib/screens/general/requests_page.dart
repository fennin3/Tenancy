import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:tenancy/utils/provider_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({Key? key}) : super(key: key);

  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  bool showSpinner = false;
  List _data = [];

  void setInit() async {
    setState(() {
      showSpinner = true;
    });
    _data = await MyFunc.getRequests(context);
    setState(() {
      _data = _data;
      showSpinner = false;
    });
  }

  void deleteRequest(String id) async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getStringList("data")![0];
    String user_id = sharedPreferences.getStringList("data")![1];

    Map _data = {"user_id": user_id, "id": id};

    try {
      http.Response response = await http.post(
          Uri.parse(base_url + "landlord/delete-request/"),
          body: _data,
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

      if (response.statusCode < 206) {
        Toast.show(
          "Request has been deleted.",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        Navigator.pop(context);
        setState(() {
          showSpinner = false;
        });
      } else {
        Toast.show(
          "${json.decode(response.body)['message']}",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
        setState(() {
          showSpinner = false;
        });
        Navigator.pop(context);
      }
    } on SocketException {
      Navigator.pop(context);
      Toast.show(
        "No internet connection",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  void deleteRequestDialog(String id) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Delete Request."),
              content: const Text("This action can not be reverted."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => deleteRequest(id),
                  child: const Text('Delete'),
                ),
              ],
            ));
  }

  void showRequesDetail(Map data) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
              child: Container(
                padding: const EdgeInsets.only(
                    right: 15, left: 15, top: 10, bottom: 40),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Request Detail",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: app_color),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Type",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Removal of ${data['type']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Reason",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${data['reason']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Status",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${data['status']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      if (data['status'].toString().toLowerCase() == "declined")
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Reason for Decline",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: app_color),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${data['declined']}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
            ));
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final data = Provider.of<UserDetails>(context, listen: true);
    data.getRequests(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setInit();
  }

  @override
  Widget build(BuildContext context) {
    showSpinner = false;
    final data = Provider.of<UserDetails>(context, listen: true);
    _data = data.requests;
    return Scaffold(
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
                          child:
                              Icon(Icons.arrow_back_ios, color: Colors.white)),
                    ),
                  ),
                  const Text(
                    "My Requests",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(
                    width: 30,
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: _data.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text(
                          "No Requests",
                          style: TextStyle(fontSize: 20),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _data.length,
                        itemBuilder: (context, index) {
                          return Container(
                            child: Slidable(
                              actionPane: SlidableDrawerActionPane(),
                              actionExtentRatio: 0.25,
                              child: Container(
                                color: Colors.white,
                                child: ListTile(
                                  leading: _data[index]['type'].toString().toLowerCase() == "tenant"? const Icon(
                                    Icons.person,
                                    size: 40,
                                  ) : const Icon(
                                    Icons.house,
                                    size: 40,
                                  ),
                                  title: Text(_data[index]['data']['name'] !=
                                          null
                                      ? 'Remove ${_data[index]['data']['name']}'
                                      : ""),
                                  subtitle: Text(
                                      'Date: ${_data[index]['created']}  |  Status: ${_data[index]['status']}'),
                                  trailing: Container(
                                    width: 57,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("<<<"),
                                        _data[index]['status']
                                                    .toString()
                                                    .toLowerCase() ==
                                                "approved"
                                            ? const Icon(Icons.check_circle,
                                                color: Colors.green)
                                            : _data[index]['status']
                                                        .toString()
                                                        .toLowerCase() ==
                                                    "pending"
                                                ? const Icon(Icons.pending,
                                                    color: Colors.yellow)
                                                : const Icon(Icons.close,
                                                    color: Colors.red)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              secondaryActions: <Widget>[
                                IconSlideAction(
                                    caption: 'View',
                                    color: app_color,
                                    icon: Icons.remove_red_eye,
                                    onTap: () =>
                                        showRequesDetail(_data[index])),
                                IconSlideAction(
                                  caption: 'Delete',
                                  color: Colors.red,
                                  icon: Icons.delete,
                                  onTap: () => deleteRequestDialog(
                                      _data[index]['id'].toString()),
                                ),
                              ],
                            ),
                          );
                        })),
          ],
        )),
      ),
    );
  }
}
