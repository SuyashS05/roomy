import 'package:flutter/material.dart';
import 'package:romy/Models/Users.dart';

class PgAddPage extends StatefulWidget {
  final String? editListingId;
  final UserModel owner;

  const PgAddPage({super.key, required this.owner, this.editListingId});

  @override
  State<PgAddPage> createState() => _PgAddPageState();
}

class _PgAddPageState extends State<PgAddPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add PG")),
      body: Center(child: Text("PG Add/Edit Page for ${widget.owner.displayName}")),
    );
  }
}
