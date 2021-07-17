import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ImageScreen extends StatefulWidget {
  final List images;
  final String url;

  const ImageScreen({Key? key, required this.images, required this.url}) : super(key: key);

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          CarouselSlider(
            options:
                CarouselOptions(height: MediaQuery.of(context).size.height),
            items: widget.images.map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Image.network(
                            widget.url + i,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),
          Positioned(
              right: 20,
              top: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Card(
                  color: Colors.black54,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ))
        ],
      ),
    ));
  }
}
