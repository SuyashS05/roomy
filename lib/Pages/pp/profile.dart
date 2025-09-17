import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:romy/Pages/pp/ProfileSectionPages/PersonalInfoPage.dart';

/// -------------------- PROFILE PAGE --------------------
class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text("Prathmesh Pimpare")),
                const Center(child: Text("Prathmesh@gmail.com")),
                const SizedBox(height: 25),
                InkWell(
                  onTap: () {
                    Get.to(Personalinfopage());
                  },
                  child: SizedBox(
                    height: 80,
                    child: Card(
                      surfaceTintColor: Colors.purpleAccent,
                      child: const Center(
                        child: ListTile(
                          leading: Icon(
                            Icons.person,
                            color: Colors.purpleAccent,
                          ),
                          title: Text("Personal Information"),
                          trailing: Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Card(
                    surfaceTintColor: Colors.red,
                    child: const Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        title: Text("Favorites"),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Card(
                    surfaceTintColor: Colors.deepOrangeAccent,
                    child: const Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.settings,
                          color: Colors.deepOrangeAccent,
                        ),
                        title: Text("Settings"),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: Card(
                    surfaceTintColor: Colors.blue,
                    child: const Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: Colors.blue,
                        ),
                        title: Text("Logout"),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}