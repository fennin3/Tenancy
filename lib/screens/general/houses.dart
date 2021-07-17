import 'package:flutter/material.dart';
import 'package:tenancy/constant.dart';
import 'package:tenancy/screens/general/create_house.dart';
import 'package:tenancy/screens/general/house_detail.dart';
import 'package:tenancy/screens/my_colors.dart';
import 'dart:math';

class HousesPage extends StatefulWidget {
  const HousesPage({Key? key, required this.data, required this.image, required this.url}) : super(key: key);

  final List data;
  final String image;
  final String url;

  @override
  _HousesPageState createState() => _HousesPageState();
}

class _HousesPageState extends State<HousesPage> {
  final _random = Random();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0Xf4f6faFF),
      body: SafeArea(
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
                    child: const Icon(
                      Icons.search,
                      size: 21,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            widget.data.length > 0
                ? Expanded(
                    child: Container(
                    child: ListView.builder(
                      itemCount: widget.data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HouseDetail(
                                  image: widget.image,
                                  init_data: widget.data[index],
                                  url: widget.url,
                                ),
                              ),
                            );
                          },
                          leading: Icon(
                            Icons.house,
                            size: 50,
                            color:
                                all_colors[_random.nextInt(all_colors.length)],
                          ),
                          title: Text("${widget.data[index]['name']}"),
                          subtitle: Text("${widget.data[index]['area']}"),
                          trailing: const Icon(Icons.arrow_forward_ios),
                        );
                      },
                    ),
                  ))
                : Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                      ),
                      const Text(
                        "No Houses",
                        style: TextStyle(fontSize: 25),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddHouse(),
                            ),
                          );
                        },
                        child: const Card(
                          color: app_color,
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Add a House",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
