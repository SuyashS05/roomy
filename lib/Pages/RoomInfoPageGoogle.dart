import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Roominfopage extends StatefulWidget {
  const Roominfopage({super.key});

  @override
  State<Roominfopage> createState() => _RoominfopageState();
}

class _RoominfopageState extends State<Roominfopage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 30,),
              Text("Room Info Page",style: TextStyle(fontSize: 30,fontWeight: FontWeight.w600),)
            ],
          ),
        ),
      ),
    );
  }
}

