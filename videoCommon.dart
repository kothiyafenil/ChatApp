import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// class ReusableVideoPlayer extends StatefulWidget {
//   ReusableVideoPlayer({required this.url, super.key});

//   String url;

//   @override
//   State<ReusableVideoPlayer> createState() => _ReusableVideoPlayerState();
// }

// class _ReusableVideoPlayerState extends State<ReusableVideoPlayer> {
//   late VideoPlayerController videoPlayerController;
//   late ChewieController chewieController;
//   @override
//   void initState() {
//     super.initState();
//     videoPlayerController = VideoPlayerController.network(widget.url);
//     videoPlayerController.initialize();

//     chewieController = ChewieController(
//       videoPlayerController: videoPlayerController,
//       autoPlay: false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: MediaQuery.of(context).size.height,
//       width: double.infinity,
//       child: Chewie(
//         controller: chewieController,
//       ),
//     );
//   }
// }

// class VideoComon extends StatefulWidget {
//   final String ex;
//   const VideoComon({super.key, required this.ex});

//   @override
//   State<VideoComon> createState() => _VideoComonState();
// }

// class _VideoComonState extends State<VideoComon> {
//   @override
//   late VideoPlayerController videoPlayerController;
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     videoPlayerController = VideoPlayerController.network(widget.ex);
//     videoPlayerController.initialize();
//   }

//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           videoPlayerController.value.isPlaying ? videoPlayerController.pause() : videoPlayerController.play();
//         });
//       },
//       child: Container(
//         margin: EdgeInsets.all(8),
//         height: 275,
//         width: 200,
//         decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blueGrey, width: 5)),
//         child: VideoPlayer(videoPlayerController),
//       ),
//     );
//   }
// }
class VideoComon extends StatefulWidget {
  final String ex;
  const VideoComon({super.key, required this.ex});

  @override
  State<VideoComon> createState() => _VideoComonState();
}

class _VideoComonState extends State<VideoComon> {
  late VideoPlayerController videoPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.ex);
    videoPlayerController.initialize();
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          height: 275,
          width: 200,
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blueGrey, width: 5)),
          child: VideoPlayer(videoPlayerController),
        ),
        Positioned(
          top: 130,
          left: 90,
          child: InkWell(
            onTap: () {
              setState(() {
                videoPlayerController.value.isPlaying ? videoPlayerController.pause() : videoPlayerController.play();
              });
            },
            child: Icon(
              videoPlayerController.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 30,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
