import 'dart:developer';

import 'package:chat/Screen/Group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  List<bool> checkBox = [];
  List<Map<String, dynamic>> membersList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
        onPressed: () {
          if (membersList.length > 2) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Group(memberList: membersList),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Plsease Select Member More Than 2"),
              ),
            );
          }
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        title: const Text(
          "Create Group",
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 22),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("user").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            for (int i = 0; i <= snapshot.data!.docs.length; i++) {
              checkBox.add(false);
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.account_circle_rounded,
                    size: 50,
                  ),
                  title: Text(snapshot.data!.docs[index]["name"].toString()),
                  subtitle: Text(snapshot.data!.docs[index]["email"]),
                  trailing: Checkbox(
                    value: checkBox[index],
                    onChanged: (value) {
                      setState(
                        () {
                          checkBox[index] = value!;
                          if (checkBox[index] == true) {
                            membersList.add(
                              {
                                "name": snapshot.data!.docs[index]["name"],
                                "email": snapshot.data!.docs[index]["email"],
                                "userId": snapshot.data!.docs[index]["userId"],
                              },
                            );
                          } // if
                          else {
                            membersList.removeWhere(
                              (element) {
                                return element["name"] == snapshot.data!.docs[index]['name'];
                              },
                            );
                          }
                          log(
                            membersList.toString(),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
