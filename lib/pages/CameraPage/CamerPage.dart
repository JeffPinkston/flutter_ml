import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

List<CameraDescription> cameras;

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  CameraPage({Key key, this.cameras}) : super(key: key);

  _CameraPageState createState() => _CameraPageState();
}

IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraPageState extends State<CameraPage> {
  CameraController controller;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    controller.initialize().then((_){
      if(!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return _showLoadingIndicator();
    }
    return _showCameraPreview();
  }

  _showCameraPreview() {
    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Camera example'),
      ),
      body: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
    )
    );
  }

  _showLoadingIndicator() {
    return Scaffold(
      appBar: AppBar(title: Text('Camera'),),
      body: Container(
        child: SpinKitRotatingCircle(
        color: Colors.white,
        size: 50.0,
      )
      )
    );
  }
}
