import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:romy/Pages/UIHelper.dart';
import 'package:get/get.dart';
import 'package:romy/main.dart';
class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilepageState();
}

class _ProfilepageState extends State<Profilepage> {
  final firstname=TextEditingController();
  final lastname=TextEditingController();
  final email=TextEditingController();
  final phone=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Profile Info",style: TextStyle(fontSize: 25,fontWeight: FontWeight.w600),),
                Text("Tell us more about yourself"),
                SizedBox(height: 20,),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green,

                ),
                SizedBox(height: 35,),
                UIHelper().TextFieldHelper(firstname, "First Name", "Enter First Name"),
                UIHelper().TextFieldHelper(lastname, "Last Name", "Enter Lat Name"),
                UIHelper().TextFieldHelper(email, " Email", "Enter Email"),
                UIHelper().TextFieldHelper(phone, "Phone No", "Enter Phone No"),
                SizedBox(height: 20,),
                UIHelper().ButtonHelper("Submit", (){
                  Get.to(MainPage());
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}