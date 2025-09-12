import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:romy/Pages/ProfileSectionPages/InterestHobbiesPage.dart';

import 'RoommatePreferencePage.dart';
class Personalinfopage extends StatefulWidget {
  const Personalinfopage({super.key});

  @override
  State<Personalinfopage> createState() => _PersonalinfopageState();
}

class _PersonalinfopageState extends State<Personalinfopage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_new)),
        title: Text("Profile Information"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              InkWell(
                onTap: (){

                },
                child: Container(
                  height: 100,
                  child: Card(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: ListTile(
                        title: Text("Basic Information",style: TextStyle(color: Colors.black),),
                        subtitle: Text("Contains your profile basic infromation"),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              InkWell(
                onTap: (){
                  Get.to(InterestsPage());
                },
                child: Container(
                  height: 100,
                  child: Card(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: ListTile(
                        title: Text("Your Interest & Hobbies",style: TextStyle(color: Colors.black),),
                        subtitle: Text("Your interest to be displayed for other users"),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8,),
              InkWell(
                onTap: (){
                  Get.to(RoommatePreferencePage());
                },
                child: Container(
                  height: 100,
                  child: Card(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: ListTile(
                        title: Text("Roommate Preference",style: TextStyle(color: Colors.black),),
                        subtitle: Text("Type of roommate you would prefer to share your room with"),
                        trailing: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
