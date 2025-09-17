import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:romy/Pages/pp/ProfilePage.dart';
class Registrationpage extends StatefulWidget {
  const Registrationpage({super.key});

  @override
  State<Registrationpage> createState() => _RegistrationpageState();
}

class _RegistrationpageState extends State<Registrationpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Card(child: Image.asset("assets/img/img.png")),
                  Card(
                    shadowColor: Colors.purpleAccent,
                    elevation: 4,
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("Register As",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                          Text("Select the type of user you are"),
                          SizedBox(height: 10,),
                          InkWell(
                            onTap: (){
                              Get.to(Profilepage());
                            },
                            child: Card(
                              elevation: 4,
                              color: Colors.grey.shade200,
                              child: ListTile(
                                leading: Image.asset("assets/img/room1.jpeg"),
                                title: Text("Roomate"),
                                subtitle: Text("find rooms or shared living option"),
                              ),
                            ),
                          ),
                          SizedBox(height: 8,),
                          InkWell(
                            onTap: (){
                              Get.to(Profilepage());
                            },
                            child: Card(
                              elevation: 4,
                              color: Colors.grey.shade200,
                              child: ListTile(
                                leading: Image.asset("assets/img/room1.jpeg"),
                                title: Text("Landlord/Agent"),
                                subtitle: Text("find rooms or shared living option"),
                              ),
                            ),
                          ),
                          SizedBox(height: 25,),
                          InkWell(
                              onTap: (){

                              },child: Text("Go back to Sign in",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)),
                          SizedBox(height: 40,),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Text("Terms & Condition")
                ],
              ),
            ),
          ),
        )
    );
  }
}