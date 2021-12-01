import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';

class GoogleMLController {
  static const MIN_CONFIDENCE = 0.5;

  static Future<List<String>> getImageLabels({
    required File photo,
  }) async {
    var inputImage = InputImage.fromFile(photo);
    final imageLabeler = GoogleMlKit.vision.imageLabeler();
    final List<ImageLabel> imageLabels =
        await imageLabeler.processImage(inputImage);
    imageLabeler.close();

    var results = <String>[];
    for (ImageLabel i in imageLabels) {
      if (i.confidence >= MIN_CONFIDENCE) {
        results.add(i.label.toLowerCase());
      }
    }
    return results;
  }

  static Future<List<String>> getImageText({
    required File photo,
  }) async {
    var inputImage = InputImage.fromFile(photo);
    final textRecognition = GoogleMlKit.vision.textDetector();
    final RecognisedText recognizedText =
        await textRecognition.processImage(inputImage);
    textRecognition.close();

    var results = <String>[];
    for (TextBlock t in recognizedText.blocks) {
      for (TextLine l in t.lines) {
        for (TextElement e in l.elements) {
          var words = e.text.split(RegExp('(,| )+')).toList();
          for (var w in words) {
            if (w.trim().isNotEmpty &&
                !results.contains(w.trim().toLowerCase()))
              results.add(w.trim().toLowerCase());
          }
        }
      }
    }
    return results;
  }
}
