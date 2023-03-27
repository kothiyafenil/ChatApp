import 'dart:io';
import 'dart:developer';
import 'dart:math';
import 'package:chat/Screen/VideoPlayer.dart';
import 'package:chat/Screen/videoCommon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Chating extends StatefulWidget {
  final String userMap, id, userId;
  const Chating({super.key, required this.userMap, required this.id, required this.userId});

  @override
  State<Chating> createState() => _ChatingState();
}

class _ChatingState extends State<Chating> {
  Map<String, dynamic> messageModal = {};
  void sendmessage() {
    Map<String, dynamic> data = {
      "sendBy": FirebaseAuth.instance.currentUser!.displayName,
      "recieveBy": widget.userMap,
      "time": FieldValue.serverTimestamp(),
      "message": chat.text,
      "type": "tex",
      "samay": DateFormat('hh:mm a').format(DateTime.now()),
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
      // "timestamp": DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 30).microsecondsSinceEpoch.toString()
    };

    FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").add(data);
    chat.clear();
  }

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
    int status = 1;

    FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").doc(filename).set({
      "sendBy": FirebaseAuth.instance.currentUser!.displayName,
      "recieveBy": widget.userMap,
      "time": FieldValue.serverTimestamp(),
      "message": "",
      "type": "image",
      "samay": DateFormat('hh:mm a').format(DateTime.now()),
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now()),
    });
    var ref = FirebaseStorage.instance.ref("Image").child(filename + ".jpg");
    var uploadtask = await ref.putFile(pickedFile!).catchError((Error) {
      FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").doc(filename).delete();
      status = 0;
    });
    if (status == 1) {
      String url = await uploadtask.ref.getDownloadURL();
      FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").doc(filename).update({
        "message": url
      });
    }
  }

  void selectVideo() async {
    await ImagePicker().pickVideo(source: ImageSource.gallery).then((XFile) {
      pickedVideo = File(XFile!.path);
    });

    uploadVideo();
  }

  void uploadVideo() async {
    String filename = Uuid().v1();
    int status = 1;
    FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").doc(filename).set({
      "sendBy": FirebaseAuth.instance.currentUser!.displayName,
      "recieveBy": widget.userMap,
      "time": FieldValue.serverTimestamp(),
      "message": "",
      "video": "",
      "type": "video",
      "samay": DateFormat('hh:mm a').format(DateTime.now()),
      "date": DateFormat('yyyy-MM-dd').format(DateTime.now())
    });

    var ref = FirebaseStorage.instance.ref("Video").child(filename + ".mp4");
    var uploadtask = await ref.putFile(pickedVideo!).catchError((Error) {
      FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").doc(filename).delete();
      status = 0;
    });

    if (status == 1) {
      String videoUrl = await uploadtask.ref.getDownloadURL();
      print(videoUrl);

      // lets create a thumbnail ..

      final thhumbnail = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 275, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 100,
      );
      File pickThumb;
      pickThumb = File(thhumbnail.toString());
      var refrence = FirebaseStorage.instance.ref("Thumbnail Image").child(filename + ".jpg");
      var upload = await refrence.putFile(pickThumb);
      String ThumbUrl = await upload.ref.getDownloadURL();

      FirebaseFirestore.instance.collection("chatroom").doc(widget.id).collection("chat").doc(filename).update({
        "message": ThumbUrl,
        "video": videoUrl,
      });
    }
  }

  TextEditingController chat = TextEditingController();
// extra work
  // static String groupMessageDateAndTime(String time) {
  //   var dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(time.toString()));
  //   var originalDate = DateFormat('MM/dd/yyyy').format(dt);

  //   final todayDate = DateTime.now();

  //   final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
  //   final yesterday = DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
  //   String difference = '';
  //   final aDate = DateTime(dt.year, dt.month, dt.day);

  //   if (aDate == today) {
  //     difference = "Today";
  //   } else if (aDate == yesterday) {
  //     difference = "Yesterday";
  //   } else {
  //     difference = DateFormat.yMMMd().format(dt).toString();
  //   }
  //   print(difference);
  //   return difference;
  // }

  // static DateTime returnDateAndTimeFormat(String time) {
  //   var dt = DateTime.fromMicrosecondsSinceEpoch(int.parse(time.toString()));
  //   var originalDate = DateFormat('MM/dd/yyyy').format(dt);

  //   return DateTime(dt.year, dt.month, dt.day);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection("user").doc(widget.userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          // print("1");
                          // groupMessageDateAndTime(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).microsecondsSinceEpoch.toString());
                        },
                        child: Text(
                          snapshot.data?["name"],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text(
                        snapshot.data?["status"],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              }),
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
                        // let create timestamp date

                        //  if(index == 0  && messagesList.length ==  1){
                        //   newDate =  groupMessageDateAndTime(messagesList[index].timeStamp.toString()).toString();
                        // }else if(index == messagesList.length-1){
                        //   newDate =  groupMessageDateAndTime(messagesList[index].timeStamp.toString()).toString();
                        // }else {

                        //   final DateTime date = returnDateAndTimeFormat(messagesList[index].timeStamp.toString());
                        //   final DateTime prevDate = returnDateAndTimeFormat(messagesList[index+1].timeStamp.toString());
                        //   isSameDate = date.isAtSameMomentAs(prevDate);

                        //   print("$date $prevDate $isSameDate");
                        //   newDate =  isSameDate ?  '' : groupMessageDateAndTime(messagesList[index-1].timeStamp.toString()).toString() ;
                        // }

                        //
                        String? newDate = '';
                        // bool isSameDate = false;

                        // if (index == 0 && snapshot.data!.docs.length == 1) {
                        //   newDate = groupMessageDateAndTime(snapshot.data!.docs[index]["timestamp"]).toString();
                        // } else if (index == snapshot.data!.docs.length - 1) {
                        //   print("index:$index");
                        //   print(snapshot.data!.docs.length - 1);
                        //   print("111");
                        //   newDate = groupMessageDateAndTime(snapshot.data!.docs[index]["timestamp"]).toString();
                        // } else {
                        //   final DateTime date = returnDateAndTimeFormat(snapshot.data!.docs[index]["timestamp"].toString());
                        //   final DateTime prevDate = returnDateAndTimeFormat(snapshot.data!.docs[index + 1]["timestamp"].toString());
                        //   isSameDate = date.isAtSameMomentAs(prevDate);
                        //   print("$date $prevDate $isSameDate");
                        //   newDate = isSameDate ? '' : groupMessageDateAndTime(snapshot.data!.docs[index - 1]["timestamp"].toString());
                        // }

                        return Column(
                          crossAxisAlignment: snapshot.data!.docs[index]["sendBy"] == FirebaseAuth.instance.currentUser!.displayName ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            snapshot.data!.docs[index]["type"] == "tex"
                                ? Padding(
                                    padding: EdgeInsets.only(left: snapshot.data!.docs[index]["sendBy"] == FirebaseAuth.instance.currentUser!.displayName ? 80 : 8, top: 8, bottom: 8, right: snapshot.data!.docs[index]["recieveBy"] != FirebaseAuth.instance.currentUser!.displayName ? 8 : 80),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: snapshot.data!.docs[index]["sendBy"] == FirebaseAuth.instance.currentUser!.displayName ? Colors.blueGrey : Colors.grey,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
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
                                          SizedBox(
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
                                              : const Center(
                                                  child: CircularProgressIndicator(),
                                                ),
                                        ),
                                      )
                                    : Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.all(8),
                                            height: 275,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.blueGrey, width: 5),
                                            ),
                                            child: snapshot.data!.docs[index]["message"] != ""
                                                ? Image.network(
                                                    snapshot.data!.docs[index]["message"],
                                                    fit: BoxFit.cover,
                                                  )
                                                : const Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                          ),
                                          Positioned(
                                            top: 120,
                                            left: 80,
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (contex) => vplayer(
                                                      video: snapshot.data!.docs[index]["video"],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const CircleAvatar(
                                                maxRadius: 25,
                                                minRadius: 25,
                                                backgroundColor: Colors.black45,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
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
                height: 65,
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

class Message {
  final String tex;
  final DateTime date;

  const Message({required this.tex, required this.date});
}

class ex extends StatefulWidget {
  const ex({super.key});

  @override
  State<ex> createState() => _exState();
}

class _exState extends State<ex> {
  List<Message> message = [
    Message(tex: "hey", date: DateTime.now().subtract(Duration(minutes: 1))),
    Message(tex: "hey", date: DateTime.now().subtract(Duration(minutes: 1))),
    Message(tex: "kem che", date: DateTime.now().subtract(Duration(minutes: 1))),
    Message(tex: "saru", date: DateTime.now().subtract(Duration(minutes: 1))),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GroupedListView<Message, DateTime>(
        elements: message,
        groupBy: (Element) => DateTime(Element.date.year, Element.date.month, Element.date.day),
        groupHeaderBuilder: (Message element) {
          return Text(DateFormat.yMMMd().format(element.date));
        },
        indexedItemBuilder: (context, element, index) {
          return Text(element.tex);
        },
      ),
    );
  }
}
