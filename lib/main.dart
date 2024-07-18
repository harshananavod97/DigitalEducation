import 'package:flutter/material.dart';
import 'package:flutterquiz/app/app.dart';
import 'package:flutterquiz/ui/provider/advancedlevel.dart';
import 'package:provider/provider.dart'; 

void main() async {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayMartProvider()),
      ],
      child: await initializeApp(),
    ),
  );
}
