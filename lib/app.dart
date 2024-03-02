import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_native_splash/flutter_native_splash.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    print("object");
    Future.delayed(const Duration(milliseconds: 500), () {
      FlutterNativeSplash.remove();
    });
  }

// Clean up the resources when you leave
  @override
  void dispose() async {
    super.dispose();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Get started with Voice Calling'),
        ),
        body: Center(child: Text("data")));
  }
}
