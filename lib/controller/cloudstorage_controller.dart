import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class CloudStorageController {
  static Future<Map<ARGS, String>> uploadPhotoFile({
    required File photo,
    String? filename,
    required String uid,
    required Function listener,
  }) async {
    filename ??= '${Constant.PHOTO_IMAGES_FOLDER}/$uid/${(Uuid().v1())}}';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      listener(progress);
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return {
      ARGS.DownloadURL: downloadURL,
      ARGS.Filename: filename,
    };
  }

  static Future<void> deletePhotoFile({required PhotoMemo photoMemo}) async {
    await FirebaseStorage.instance
        .ref()
        .child(photoMemo.photoFilename)
        .delete();
  }

  static Future<File> getPhotoFile({required String filename}) async {
    var random = new Random();
    String directory = (await getTemporaryDirectory()).path;
    File file = new File('$directory' + (random.nextInt(10)).toString() + '.png');
    await FirebaseStorage.instance.ref(filename).writeToFile(file);
    return file;
  }
}
