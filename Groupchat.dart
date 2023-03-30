import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Groupchat extends StatefulWidget {
  const Groupchat({super.key});

  @override
  State<Groupchat> createState() => _GroupchatState();
}

class _GroupchatState extends State<Groupchat> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          centerTitle: true,
          title: const Text(
            "Group",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("user").doc(FirebaseAuth.instance.currentUser!.uid).collection("groups").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: ListTile(
                      title: Text(
                        snapshot.data!.docs[index]["name"],
                        style: const TextStyle(color: Colors.black, fontSize: 20),
                      ),
                      leading: const CircleAvatar(
                        maxRadius: 25,
                        minRadius: 25,
                        backgroundColor: Colors.blueGrey,
                        child: Icon(
                          Icons.group,
                          color: Colors.white,
                        ),
                      ),
                      trailing: const Icon(Icons.message),
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
        ));
  }
}
