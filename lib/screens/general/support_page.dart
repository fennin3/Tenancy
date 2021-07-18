import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/get_functions.dart';
import 'package:tenancy/screens/general/add_ticket.dart';
import 'package:provider/provider.dart';
import 'package:tenancy/screens/general/image_screen.dart';
import 'package:tenancy/screens/pdf_screen.dart';
import 'package:tenancy/utils/provider_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'dart:convert';

class SupportPage extends StatefulWidget {
  final String url;
  final List extensions;

  const SupportPage({Key? key, required this.url, required this.extensions})
      : super(key: key);

  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  List _data = [];
  bool showSpinner = false;
  List _images = [];
  List _files = [];

  void cancelTicketDialog(String id) {
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
                  onPressed: () => cancelTicket(id),
                  child: const Text('Proceed'),
                ),
              ],
            ));
  }

  void showTicketDetail(Map data) {
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
                            "Ticket Detail",
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
                        "Subject",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${data['subject']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        "Message",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${data['message']}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_files.isNotEmpty)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Attached File(s)",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_files[0].toString().split('.')[1] ==
                                          "pdf") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PdfReadScreen(
                                                      url: widget.url +
                                                          _files[0]
                                                              .toString())),
                                        );
                                      } else if (_files[0]
                                                  .toString()
                                                  .split('.')[1] ==
                                              "doc" ||
                                          _files[0].toString().split('.')[1] ==
                                              "docx") {
                                        Toast.show(
                                            "Sorry, try again later.", context,
                                            gravity: Toast.BOTTOM,
                                            duration: Toast.LENGTH_LONG);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(13),
                                      color: app_color,
                                      child: const Text(
                                        "Open files",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          if (_images.isNotEmpty)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Attached Image(s)",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ImageScreen(
                                            images: _images,
                                            url: widget.url,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(13),
                                      color: app_color,
                                      child: const Text(
                                        "Open Images",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
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
                      if (data['status'].toString().toLowerCase() == "approved")
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "Reply",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: app_color),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${data['reply']}",
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

  void cancelTicket(String id) async {
    setState(() {
      showSpinner = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getStringList("data")![0];
    String user_id = sharedPreferences.getStringList("data")![1];

    Map _data = {"user_id": user_id, "id": id};

    try {
      http.Response response = await http.post(
          Uri.parse(base_url + "landlord/cancel-ticket/"),
          body: _data,
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});

      if (response.statusCode < 206) {
        Toast.show(
          "${json.decode(response.body)['message']}",
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

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final data = Provider.of<UserDetails>(context, listen: true);
    data.getTickets(context);
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<UserDetails>(context, listen: true);
    _data = data.tickets;
    return Scaffold(
      body: SafeArea(
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
                    "Support",
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
                        "No Tickets",
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
                                leading: const Icon(
                                  Icons.support_agent,
                                  color: app_color,
                                  size: 40,
                                ),
                                title: Text('${_data[index]['subject']}'),
                                subtitle: Text(
                                    'Date: ${_data[index]['created']}\nStatus: ${_data[index]['status']}'),
                                trailing: Container(
                                  width: 50,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("<<<"),
                                      _data[index]['status']
                                                  .toString()
                                                  .toLowerCase() ==
                                              "active"
                                          ? const Icon(Icons.access_time,
                                              color: Colors.yellow)
                                          : _data[index]['status']
                                                      .toString()
                                                      .toLowerCase() ==
                                                  "pending"
                                              ? const Icon(Icons.pending,
                                                  color: Colors.grey)
                                              : _data[index]['status']
                                                          .toString()
                                                          .toLowerCase() ==
                                                      "cancelled"
                                                  ? const Icon(Icons.cancel,
                                                      color: Colors.red)
                                                  : const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                    )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            secondaryActions: <Widget>[
                              if (_data[index]['status']
                                      .toString()
                                      .toLowerCase() ==
                                  "pending")
                                IconSlideAction(
                                  caption: 'Cancel',
                                  color: Colors.red,
                                  icon: Icons.cancel,
                                  onTap: () {
                                    cancelTicketDialog(
                                        _data[index]['id'].toString());
                                  },
                                ),
                              IconSlideAction(
                                caption: 'View',
                                color: app_color,
                                icon: Icons.remove_red_eye,
                                onTap: () {
                                  try {
                                    for (var i in _data[index]['files']
                                        .toString()
                                        .split(",")) {
                                      if (widget.extensions
                                              .contains(i.split(".")[1]) &&
                                          i.split(".")[1] != "pdf" &&
                                          i.split(".")[1] != "doc" &&
                                          i.split(".")[1] != "docx") {
                                        setState(() {
                                          _images.add(i);
                                        });
                                      } else if (i.split(".")[1] == "pdf" &&
                                          i.split(".")[1] == "doc" &&
                                          i.split(".")[1] == "docx") {
                                        setState(() {
                                          _files.add(i);
                                        });
                                      }
                                    }
                                  } catch (e) {}
                                  showTicketDetail(_data[index]);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTicket(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
