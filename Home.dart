import 'dart:developer';

import 'package:chat/Screen/Chating.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            centerTitle: true,
            title: InkWell(
              onTap: () {
                // String id = ChatRoomId("Agstya First", "Fenil Kothiya");
                // print(id);
              },
              child: Text(
                FirebaseAuth.instance.currentUser!.displayName.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 25, fontStyle: FontStyle.italic),
              ),
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
                            log(id);
                            String name = snapshot.data!.docs[index]["name"];
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Chating(
                                  userMap: name.toString(),
                                  id: id,
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
              })),
    );
  }
}
