library imageview360;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// Enum for rotation direction
enum RotationDirection { clockwise, anticlockwise }

class ImageView360 extends StatefulWidget {
  // List of ImageProviders used to generate the 360 image effect.
  final List<ImageProvider> imageList;

  // By default false. If set to true, the images will be displayed in incremented manner.
  final bool autoRotate;

  // By default true. If set to false, the gestures to rotate the image will be disabled.
  final bool allowSwipeToRotate;

  // By default 1. The number of cycles the whole image rotation should take place.
  final int rotationCount;

  // By default true. Allow user swipe action to stop the default rotation
  final bool canOverrideRotation;

  // By default 1. Based on the value the sensitivity of swipe gesture increases and decreases proportionally
  final int swipeSensitivity;

  // By default Duration(milliseconds: 80). The time interval between shifting from one image frame to other.
  final Duration frameChangeDuration;

  // By default RotationDirection.clockwise. Based on the value the direction of rotation is set.
  final RotationDirection rotationDirection;

  // Callback function to provide you the index of current image when image frame is changed.
  final Function(int? currentImageIndex)? onImageIndexChanged;

  ImageView360({
    required Key key,
    required this.imageList,
    this.autoRotate = false,
    this.allowSwipeToRotate = true,
    this.rotationCount = 1,
    this.canOverrideRotation = true,
    this.swipeSensitivity = 1,
    this.rotationDirection = RotationDirection.clockwise,
    this.frameChangeDuration = const Duration(milliseconds: 80),
    this.onImageIndexChanged,
  }) : super(key: key);

  @override
  _ImageView360State createState() => _ImageView360State();
}

class _ImageView360State extends State<ImageView360> {
  late int rotationIndex, sensitivity;
  int rotationCompleted = 0;
  double localPosition = 0.0;
  late Function(int? currentImageIndex) onImageIndexChanged;

  @override
  void initState() {
    sensitivity = widget.swipeSensitivity;
    // To bound the sensitivity range from 1-5
    if (sensitivity < 1) {
      sensitivity = 1;
    } else if (sensitivity > 5) {
      sensitivity = 5;
    }
    onImageIndexChanged = widget.onImageIndexChanged ?? (currentImageIndex) {};
    rotationIndex = widget.rotationDirection == RotationDirection.anticlockwise
        ? 0
        : (widget.imageList.length - 1);

    if (widget.autoRotate) {
      // To start the image rotation
      rotateImage();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onHorizontalDragEnd: (details) {
            localPosition = 0.0;
          },
          onHorizontalDragUpdate: (details) {
            // Swipe check,if allowed than only will image move
            if (widget.allowSwipeToRotate) {
              if (details.delta.dx > 0) {
                handleRightSwipe(details);
              } else if (details.delta.dx < 0) {
                handleLeftSwipe(details);
              }
            }
          },
          child: Image(
            image: widget.imageList[rotationIndex],
            gaplessPlayback: true,
          ),
        ),
      ],
    );
  }

  void rotateImage() async {
    // Check for rotationCount
    if (rotationCompleted < widget.rotationCount) {
      // Frame change duration logic
      await Future.delayed(widget.frameChangeDuration);
      if (mounted) {
        setState(() {
          if (widget.rotationDirection == RotationDirection.anticlockwise) {
            // Logic to bring the frame to initial position on cycle complete in positive direction
            if (rotationIndex < widget.imageList.length - 1) {
              rotationIndex++;
            } else {
              rotationCompleted++;
              rotationIndex = 0;
            }
          } else {
            // Logic to bring the frame to initial position on cycle complete in negative direction
            if (rotationIndex > 0) {
              rotationIndex--;
            } else {
              rotationCompleted++;
              rotationIndex = widget.imageList.length - 1;
            }
          }
        });

        onImageIndexChanged(rotationIndex);
      }
      //Recursive call
      rotateImage();
    }
  }

  void handleRightSwipe(DragUpdateDetails details) {
    _checkAndOverrideDefaultRotation();

    int? originalIndex = rotationIndex;
    if ((localPosition +
            (pow(4, (6 - sensitivity)) / (widget.imageList.length))) <=
        details.localPosition.dx) {
      rotationIndex = rotationIndex + 1;
      localPosition = details.localPosition.dx;
    }
    // Check to ignore rebuild of widget is index is same
    if (originalIndex != rotationIndex) {
      setState(() {
        if (rotationIndex < widget.imageList.length - 1) {
          rotationIndex = rotationIndex;
        } else {
          rotationIndex = 0;
        }
      });
      onImageIndexChanged(rotationIndex);
    }
  }

  void handleLeftSwipe(DragUpdateDetails details) {
    _checkAndOverrideDefaultRotation();

    double distanceDifference = (details.localPosition.dx - localPosition);
    int? originalIndex = rotationIndex;
    if (distanceDifference < 0) {
      distanceDifference = (-distanceDifference);
    }
    if (distanceDifference >=
        (pow(4, (6 - sensitivity)) / (widget.imageList.length))) {
      rotationIndex = rotationIndex - 1;
      localPosition = details.localPosition.dx;
    }
    // Check to ignore rebuild of widget is index is same
    if (originalIndex != rotationIndex) {
      setState(() {
        if (rotationIndex > 0) {
          rotationIndex = rotationIndex;
        } else {
          rotationIndex = widget.imageList.length - 1;
        }
      });
      onImageIndexChanged(rotationIndex);
    }
  }

  void _checkAndOverrideDefaultRotation() {
    // if rotating automatically and user try to swipe stop rotation
    if (widget.canOverrideRotation &&
        rotationCompleted < widget.rotationCount) {
      setState(() {
        rotationCompleted = widget.rotationCount;
      });
    }
  }
}
