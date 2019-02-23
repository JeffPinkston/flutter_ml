import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutter_ml/util/index.dart';

const String mobile = "MobileNet";
const String ssd = "SSD MobileNet";
const String yolo = "Tiny YOLOv2";

class ImagePickerPage extends StatefulWidget {
  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  File _imageFile;
  Size _imageSize;
  dynamic _scanResults;
  Detector _currentDetector = Detector.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Vision Example'),
        actions: <Widget>[
          PopupMenuButton<Detector>(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
              const PopupMenuItem<Detector>(
                child: Text('Detect Barcode'),
                value: Detector.barcode
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Face'),
                value: Detector.face
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Label'),
                value: Detector.label
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Cloud Label'),
                value: Detector.cloudLabel
              ),
              const PopupMenuItem<Detector>(
                child: Text('Detect Text'),
                value: Detector.text
              ),
            ],
            onSelected: (Detector result) {
              _currentDetector = result;
              if (_imageFile != null) _scanImage(_imageFile);
            },
          )
        ],
      ),
      body: _imageFile == null
        ? const Center(child: Text('No Image Selected.'))
        : _buildImage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getAndScanImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Future<void> _getAndScanImage() async {
    setState(() {
      _imageSize = null;
      _imageFile = null;
    });

    final File imageFile =
      await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
      FirebaseVisionImage.fromFile(imageFile);

    dynamic results;
    switch (_currentDetector) {
      case Detector.barcode:
        final BarcodeDetector detector =
          FirebaseVision.instance.barcodeDetector();
        results = await detector.detectInImage(visionImage);
        break;
      case Detector.face:
        final FaceDetector detector =
          FirebaseVision.instance.faceDetector();
        results = await detector.processImage(visionImage);
        break;
      case Detector.label:
        final LabelDetector detector =
          FirebaseVision.instance.labelDetector();
        results = await detector.detectInImage(visionImage);
        break;
      case Detector.cloudLabel:
        final CloudLabelDetector detector =
          FirebaseVision.instance.cloudLabelDetector();
        results = await detector.detectInImage(visionImage);
        break;
      case Detector.text:
        final TextRecognizer detector =
          FirebaseVision.instance.textRecognizer();
        results = await detector.processImage(visionImage);
        break;
    }

    setState(() {
      _scanResults = results;
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer =Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      (ImageInfo info, bool _) {
        completer.complete(
          Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          )
        );
      }
    );

    final Size imageSize = await completer.future;
    setState(() {
       _imageSize = imageSize;
    });
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image:DecorationImage(
          image: Image.file(_imageFile).image,
          fit: BoxFit.fill
        )
      ),
      child: _imageSize == null || _scanResults == null
        ? const Center(
          child: Text(
            'Scanning...',
            style:TextStyle(
              color: Colors.green,
              fontSize: 30.0,
            )
          ),
        )
        : _buildResults(_imageSize, _scanResults)
    );
  }

  CustomPaint _buildResults(Size imageSize, dynamic results) {
    CustomPainter painter;

    switch (_currentDetector) {
      case Detector.barcode:
        painter = BarcodeDetectorPainter(_imageSize, results);
        break;
      case Detector.face:
        painter = FaceDetectorPainter(_imageSize, results);
        break;
      case Detector.label:
        painter = LabelDetectorPainter(_imageSize, results);
        break;
      case Detector.cloudLabel:
        painter = LabelDetectorPainter(_imageSize, results);
        break;
      case Detector.text:
        painter = TextDetectorPainter(_imageSize, results);
        break;
      default:
        break;
    }

    return CustomPaint(
      painter: painter,
    );
  }


}
