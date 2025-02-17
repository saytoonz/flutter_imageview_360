import 'package:flutter/material.dart';
import 'package:imageview360/imageview360.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImageView360 Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DemoPage(title: 'ImageView360 Demo'),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  List<ImageProvider> imageList = <ImageProvider>[];
  bool autoRotate = true;
  int rotationCount = 10;
  bool canOverrideRotation = true;
  int swipeSensitivity = 2;
  bool allowSwipeToRotate = true;
  RotationDirection rotationDirection = RotationDirection.anticlockwise;
  Duration frameChangeDuration = const Duration(milliseconds: 50);
  bool imagePreCached = false;

  @override
  void initState() {
    //* To load images from assets after first frame build up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateImageList(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 72.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imagePreCached == true
                    ? ImageView360(
                        key: UniqueKey(),
                        imageList: imageList,
                        autoRotate: autoRotate,
                        rotationCount: rotationCount,
                        canOverrideRotation: canOverrideRotation,
                        rotationDirection: RotationDirection.anticlockwise,
                        frameChangeDuration: const Duration(milliseconds: 30),
                        swipeSensitivity: swipeSensitivity,
                        allowSwipeToRotate: allowSwipeToRotate,
                        onImageIndexChanged: (currentImageIndex) {
                          debugPrint("currentImageIndex: $currentImageIndex");
                        },
                      )
                    : const Text("Pre-Caching images..."),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Optional features:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 24),
                  ),
                ),
                DescWidget(
                  text: "Auto rotate: $autoRotate",
                ),
                DescWidget(
                  text: "Rotation count: $rotationCount",
                ),
                DescWidget(
                  text: "Allow user swipe to stop auto rotation:"
                      " $canOverrideRotation",
                ),
                DescWidget(
                  text: "Rotation direction: $rotationDirection",
                ),
                DescWidget(
                  text: "Frame change duration: "
                      "${frameChangeDuration.inMilliseconds} milliseconds",
                ),
                DescWidget(
                  text: "Allow swipe to rotate image: $allowSwipeToRotate",
                ),
                DescWidget(
                  text: "Swipe sensitivity: $swipeSensitivity",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateImageList(BuildContext context) async {
    for (int i = 1; i <= 52; i++) {
      imageList.add(AssetImage('assets/sample/$i.png'));
      //* To pre-cache images so that when required they are loaded faster.
      await precacheImage(AssetImage('assets/sample/$i.png'), context);
    }
    setState(() {
      imagePreCached = true;
    });
  }
}

class DescWidget extends StatelessWidget {
  const DescWidget({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Text(text),
    );
  }
}
