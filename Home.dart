import 'dart:developer';
import 'dart:ffi';

import 'package:chat/Screen/Chating.dart';
import 'package:chat/Screen/CreateGroup.dart';
import 'package:chat/Screen/Groupchat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  TextEditingController search = TextEditingController();
  // QueryDocumentSnapshot<Object?>? userMap;
  // List<QueryDocumentSnapshot<Object?>?> data = [];

  // void Getdata() {
  //   FirebaseFirestore.instance.collection('user').get().then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((doc) {
  //       setState(() {
  //         userMap = doc;

  //         data.add(userMap);

  //         print(data);
  //         // print(userMap?["email"]);
  //       });
  //     });
  //   });
  // }

  String ChatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] > user2[0].toLowerCase().codeUnits[0]) {
      return "$user1  $user2";
    } else {
      return "$user2  $user1";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setstatus("Online");
    // getPermission();
  }

  void setstatus(String status) {
    FirebaseFirestore.instance.collection("user").doc(FirebaseAuth.instance.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setstatus("Online");
      // online
    } else {
      setstatus("Offline");
      //offline
    }
  }

  void getPermission() async {
    if (await Permission.contacts.isGranted) {
      // fetchdata();
// catch data..
    } else {
      await Permission.contacts.request();
    }
  }

  // List<Contact> contacts = [];

  // void fetchdata() async {
  //   contacts = await ContactsService.getContacts();
  // }

  // contact na phone number and apa data set karava ena phone number same hova jovi

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueGrey,
          child: const Icon(Icons.group),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const Groupchat(),
              ),
            );
          },
        ),
        appBar: AppBar(
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 0,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CreateGroup(),
                          ),
                        );
                      },
                      child: const Text("Create a group"),
                    ),
                  ),
                ];
              },
            )
          ],
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
          title: Text(
            FirebaseAuth.instance.currentUser!.displayName.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 25, fontStyle: FontStyle.italic),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("user").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        String id = ChatRoomId(FirebaseAuth.instance.currentUser!.displayName.toString(), snapshot.data!.docs[index]["name"]);
                        String userId = snapshot.data!.docs[index]["userId"];
                        log(id);
                        String name = snapshot.data!.docs[index]["name"];
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Chating(
                              userMap: name.toString(),
                              id: id,
                              userId: userId,
                            ),
                          ),
                        );
                      },
                      leading: const Icon(
                        Icons.account_circle_rounded,
                        size: 50,
                      ),
                      title: Text(snapshot.data!.docs[index]["name"].toString()),
                      subtitle: Text(snapshot.data!.docs[index]["email"]),
                      trailing: const Icon(Icons.message),
                    );
                  },
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
