import 'dart:io';

import 'dart:developer';
import 'package:chat/Screen/videoCommon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Chating extends StatefulWidget {
  final String userMap, id;
  const Chating({super.key, required this.userMap, required this.id});

  @override
  State<Chating> createState() => _ChatingState();
}

class _ChatingState extends State<Chating> {
  void sendmessage() {
    Map<String, dynamic> data = {
      "sendBy": FirebaseAuth.instance.currentUser!.displayName,
      "recieveBy": widget.userMap,
      "time": FieldValue.serverTimestamp(),
      "message": chat.text,
      "type": "tex",
      "samay": DateFormat('hh:mm a').format(DateTime.now())
    };

    FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").add(data);
    chat.clear();
  }

  String? uuu;
  QueryDocumentSnapshot<Object?>? userMap;
  File? pickedFile;
  File? pickedVideo;
  void selectImage() async {
    ImagePicker picker = ImagePicker();
    // ignore: deprecated_member_use
    await picker.getImage(source: ImageSource.gallery).then((XFile) {
      pickedFile = File(XFile!.path);
    });
    uploadImage();
  }

  void uploadImage() async {
    String filename = Uuid().v1();
    var ref = FirebaseStorage.instance.ref("Image").child(filename + ".jpg");
    var uploadtask = await ref.putFile(pickedFile!);
    String url = await uploadtask.ref.getDownloadURL();

    Map<String, dynamic> data = {
      "sendBy": FirebaseAuth.instance.currentUser!.displayName,
      "recieveBy": widget.userMap,
      "time": FieldValue.serverTimestamp(),
      "message": url,
      "type": "image",
      "samay": DateFormat('hh:mm a').format(DateTime.now()),
    };
    FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").add(data);
  }

  //late VideoPlayerController  videoPlayerController;
  void selectVideo() async {
    await ImagePicker().pickVideo(source: ImageSource.gallery).then((XFile) {
      pickedVideo = File(XFile!.path);
    });

    uploadVideo();
  }

  void uploadVideo() async {
    String filename = Uuid().v1();
    var ref = FirebaseStorage.instance.ref("Video").child(filename + ".mp4");
    var uploadtask = await ref.putFile(pickedVideo!);
    String videoUrl = await uploadtask.ref.getDownloadURL();
    print(videoUrl);

    Map<String, dynamic> data = {
      "sendBy": FirebaseAuth.instance.currentUser!.displayName,
      "recieveBy": widget.userMap,
      "time": FieldValue.serverTimestamp(),
      "message": videoUrl,
      "type": "video",
      "samay": DateFormat('hh:mm a').format(DateTime.now()),
    };
    FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").add(data);
  }

  TextEditingController chat = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.userMap,
            style: const TextStyle(fontSize: 25, fontStyle: FontStyle.italic),
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body: Stack(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").orderBy("time").snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, index) {
                        return Column(
                          crossAxisAlignment: snapshot.data!.docs[index]["sendBy"] == FirebaseAuth.instance.currentUser!.displayName ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            snapshot.data!.docs[index]["type"] == "tex"
                                ? Padding(
                                    padding: EdgeInsets.only(left: snapshot.data!.docs[index]["sendBy"] == FirebaseAuth.instance.currentUser!.displayName ? 80 : 8, top: 8, bottom: 8, right: snapshot.data!.docs[index]["recieveBy"] != FirebaseAuth.instance.currentUser!.displayName ? 8 : 80),
                                    child: Container(
                                      decoration: BoxDecoration(color: Colors.blueGrey, borderRadius: BorderRadius.circular(10)),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 5,
                                            right: 4,
                                            child: Text(
                                              snapshot.data!.docs[index]["samay"],
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ),
                                          Container(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8, bottom: 8, right: 70, left: 8),
                                              child: Text(
                                                snapshot.data!.docs[index]["message"],
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : snapshot.data!.docs[index]["type"] == "image"
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 275,
                                          width: 225,
                                          decoration: BoxDecoration(border: Border.all(color: Colors.blueGrey, width: 5)),
                                          child: snapshot.data!.docs[index]["message"] != ""
                                              ? Image.network(
                                                  snapshot.data!.docs[index]["message"],
                                                  fit: BoxFit.cover,
                                                )
                                              : Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                        ),
                                      )
                                    : VideoComon(ex: snapshot.data!.docs[index]["message"])
                            // Container(
                            //     height: 250,
                            //     width: 200,
                            //     margin: EdgeInsets.all(8),
                            //     decoration: BoxDecoration(
                            //       border: Border.all(color: Colors.blueGrey, width: 5),
                            //     ),
                            //     child: ReusableVideoPlayer(
                            //       url: snapshot.data!.docs[index]["message"],
                            //     ),
                            //   )
                          ],
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
            Positioned(
              bottom: 0,
              child: Container(
                height: 70,
                width: Get.width,
                color: Colors.white,
              ),
            ),
            Positioned(
                bottom: 5,
                right: 10,
                child: InkWell(
                  onTap: () {
                    sendmessage();
                  },
                  child: const CircleAvatar(
                    maxRadius: 25,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                )),
            Positioned(
              bottom: 5,
              left: 10,
              child: Container(
                width: 300,
                child: TextField(
                  controller: chat,
                  cursorColor: Colors.blueGrey,
                  decoration: InputDecoration(
                    prefixIcon: InkWell(
                      onTap: () {
                        selectVideo();
                      },
                      child: const Icon(
                        Icons.video_camera_back_outlined,
                        color: Colors.blueGrey,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        selectImage();
                      },
                      child: const Icon(
                        Icons.image,
                        color: Colors.blueGrey,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide(color: Colors.blueGrey)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: const BorderSide(color: Colors.blueGrey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

class ex extends StatefulWidget {
  const ex({super.key});

  @override
  State<ex> createState() => _exState();
}

class _exState extends State<ex> {
  String? name;
  void thumb() async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: "https://firebasestorage.googleapis.com/v0/b/chat-6d802.appspot.com/o/Video%2F63072320-c967-11ed-9c2b-6fecb518814d.mp4?alt=media&token=5ddc3146-7920-4e80-822c-7ee835179576",
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );

    setState(() {
      name = fileName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            child: name != null ? Image.file(File(name!)) : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                thumb();
              },
              child: const Text("select"))
        ],
      ),
    );
  }
}
