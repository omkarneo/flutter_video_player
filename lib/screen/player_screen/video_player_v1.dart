import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  Duration position = const Duration();
  bool isHourZero = false;
  bool isMinutesZero = false;
  bool isFullScreen = false;
  bool actionScreen = false;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        // "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"
        // "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"
        'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        if (_controller.value.duration.inHours == 0) {
          isHourZero = true;
        }
        if (_controller.value.duration.inMinutes == 0) {
          isMinutesZero = true;
        }

        _controller.addListener(updateSeeker);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.removeListener(updateSeeker);
    super.dispose();
  }

  Future<void> updateSeeker() async {
    final newPosition = await _controller.position;
    // print(newPosition);
    setState(() {
      position = newPosition!;
    });
  }

  void actionsSheet(int second, bool withSeeker) {
    // print("For Testing")
    setState(() {
      actionScreen = true;
    });

    Future.delayed(Duration(seconds: second), () {
      print(_controller.value.isPlaying);
      setState(() {
        if ((_controller.value.isPlaying)) {
          actionScreen = false;
        }
      });
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      appBar: isPortrait
          ? AppBar(
              title: const Text("Video Player Example"),
            )
          : null,
      body: Stack(children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _controller.value.isInitialized
                ? InkWell(
                    onTap: () {
                      actionsSheet(2, false);
                    },
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: isPortrait
                          ? 220
                          : MediaQuery.sizeOf(context).height - 1,
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : Container(),
            !actionScreen
                ? SizedBox(
                    height: isPortrait ? 1 : 0,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          trackShape: CustomTrackForNonIntereactorShape(),
                          thumbColor: Colors.transparent,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0.0)),
                      child: Slider(
                          min: 0,
                          max: _controller.value.duration.inSeconds.toDouble(),
                          activeColor: Colors.red.shade500,
                          inactiveColor: Colors.grey,
                          value: position.inSeconds.toDouble(),
                          allowedInteraction: SliderInteraction.tapOnly,
                          autofocus: false,
                          onChanged: (value) {}),
                    ),
                  )
                : Container(),
          ],
        ),

        actionScreen
            ? Positioned(

                // top: isFullScreen ? 300 : 150,
                // left: -10,
                height: isPortrait ? 250 : MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width + 20,
                child: Container(
                  height: isPortrait ? 250 : MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width + 20,
                  color: Colors.black.withOpacity(0.3),
                ))
            : const SizedBox.shrink(),
        actionScreen
            ? Positioned(
                top: isPortrait ? 135 : 300,
                left: -10,
                // height: 250,
                width: MediaQuery.sizeOf(context).width + 20,
                child: Column(
                  children: [
                    Slider(
                      min: 0,
                      max: _controller.value.duration.inSeconds.toDouble(),
                      // ? _controller.value.duration.inMinutes.toDouble()
                      // : _controller.value.duration.inSeconds.toDouble(),
                      activeColor: Colors.red.shade500,
                      inactiveColor: Colors.grey,
                      thumbColor: Colors.red.shade900,
                      value: position.inSeconds.toDouble(),
                      autofocus: false,
                      onChanged: (value) {
                        setState(() {
                          position = Duration(seconds: value.toInt());

                          _controller
                              .seekTo(position)
                              .then((value) => {actionsSheet(2, true)});
                        });
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        actionScreen
            ? Positioned(
                top: isPortrait ? 70 : 230,
                left: 0,
                height: 250,
                width: MediaQuery.sizeOf(context).width,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                          } else {
                            _controller.play();
                            actionsSheet(1, false);
                          }
                        });

                        setState(() {});
                      },
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _controller.value.volume == 0
                              ? _controller.setVolume(1)
                              : _controller.setVolume(0);
                        });
                      },
                      icon: Icon(
                        _controller.value.volume != 0
                            ? Icons.volume_up
                            : Icons.volume_off,
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${(position.inHours == 0) ? "" : "${position.inHours}:"}${position.inMinutes.toString()}:${(position.inSeconds % 60).toString().length == 1 ? "0${position.inSeconds % 60}" : "${position.inSeconds % 60}"} / ${_controller.value.duration.inHours == 0 ? "" : "${_controller.value.duration.inHours}:"}${_controller.value.duration.inMinutes}:${_controller.value.duration.inSeconds % 60}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        // void enterFullScreen() {
                        if (!isPortrait) {
                          setState(() async {
                            await SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.portraitUp]);
                            // isFullScreen = false;
                          });
                          // print(isFullScreen);
                        } else {
                          setState(() async {
                            await SystemChrome.setPreferredOrientations(
                                [DeviceOrientation.landscapeLeft]);
                            // isFullScreen = true;
                          });
                          // print(isFullScreen);
                        }
                        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        //     overlays: []);
                        // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                        //     overlays: SystemUiOverlay.values);
                        // }
                        // _controller.
                        // setState(() {
                        //   _controller.value.volume == 0
                        //       ? _controller.setVolume(1)
                        //       : _controller.setVolume(0);
                        // });
                      },
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),

        // Container(
        //   height: 10,
        //   width: MediaQuery.sizeOf(context).width,
        //   child: Row(
        //     children: [
        //       Container(
        //         color: Colors.red,
        //       ),
        //       Container(
        //         height: 50,
        //         width: 10,
        //         decoration: BoxDecoration(
        //             borderRadius: BorderRadius.circular(50), color: Colors.red),
        //       ),
        //       Container(
        //         color: Colors.white,
        //       ),
        //     ],
        //   ),
        // ),
        // ,
        // ElevatedButton(
        //     onPressed: () async {
        //       print("=========");
        //       print(await _controller.position);
        //       print(_controller.value.duration);
        //       print("=========");
        //       // print(_controller.position);
        //       _controller.seekTo(Duration(seconds: 02));
        //     },
        //     child: Text("click here"))
      ]),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       _controller.value.isPlaying
      //           ? _controller.pause()
      //           : _controller.play();
      //     });
      //   },
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}

class CustomTrackForNonIntereactorShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackLeft = offset.dx;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, 0, trackWidth, 2);
  }
}
