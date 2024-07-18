import 'package:flutter/material.dart';

import 'package:flutterquiz/utils/constants/fonts.dart';

class studyTipsview extends StatefulWidget {
  String headTitle, Description, Image;
  studyTipsview(
      {super.key,
      required this.Description,
      required this.headTitle,
      required this.Image});

  @override
  State<studyTipsview> createState() => _studyTipsviewState();
}

class _studyTipsviewState extends State<studyTipsview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Text(
                    widget.headTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeights.bold,
                      color: Colors.black,
                    ),
                  ),
                  Center(
                    child: Image.network(
                      widget.Image, // Replace with your image URL
                      height: 180.0, // Adjust the height as needed
                      width: 180.0, // Adjust the width as needed
                      fit: BoxFit.contain,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Container();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Text(
                        widget.Description.replaceAll(
                            r'\n', '\n'), // Replace '\n' with line breaks
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
