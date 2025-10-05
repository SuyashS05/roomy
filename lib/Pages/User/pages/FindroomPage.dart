import 'package:easy_localization/easy_localization.dart';
import 'package:romy/Pages/User/pages/SearchBar.dart';
import 'package:flutter/material.dart';

class FindroomPage extends StatefulWidget {
  const FindroomPage({super.key});

  @override
  State<FindroomPage> createState() => _FindroomPageState();
}

class _FindroomPageState extends State<FindroomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('find_room'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const RoomSearchWidget(),
          ],
        ),
      ),
    );
  }
}