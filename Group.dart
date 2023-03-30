import 'package:chat/Screen/Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Group extends StatefulWidget {
  final List<Map<String, dynamic>> memberList;
  const Group({super.key, required this.memberList});

  @override
  State<Group> createState() => _GroupState();
}

class _GroupState extends State<Group> {
  TextEditingController groupName = TextEditingController();

  void createGroup() async {
    String groupId = Uuid().v1();

    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      "members": widget.memberList,
      "id": groupId,
    });

    for (int i = 0; i < widget.memberList.length; i++) {
      String uid = widget.memberList[i]['userId'];

      await FirebaseFirestore.instance.collection('user').doc(uid).collection('groups').doc(groupId).set({
        "name": groupName.text,
        "id": groupId,
      });
    }

    await FirebaseFirestore.instance.collection('groups').doc(groupId).collection('chats').add({
      "message": "${FirebaseAuth.instance.currentUser!.displayName} Created This Group.",
      "type": "notify",
    });

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          "Group Name",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: groupName,
              decoration: InputDecoration(
                hintText: "Enter Group Name",
                contentPadding: const EdgeInsets.all(10),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () {
              createGroup();
            },
            child: const Text("Create Group"),
          )
        ],
      ),
    );
  }
}


// https://github.com/Programmer9211/Chat_App_Flutter_Firebase