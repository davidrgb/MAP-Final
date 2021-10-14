class PhotoMemo {
  String? docId;
  late String createdBy;
  late String title;
  late String memo;
  late String photoFilename;
  late String photoURL;
  DateTime? timestamp;
  late List<dynamic> sharedWith;
  late List<dynamic> imageLabels;

  PhotoMemo({
    this.docId,
    this.createdBy = '',
    this.title = '',
    this.memo = '',
    this.photoFilename = '',
    this.photoURL = '',
    this.timestamp,
    List<dynamic>? sharedWith,
    List<dynamic>? imageLabels,
  }) {
    this.sharedWith = sharedWith == null ? [] : [...sharedWith];
    this.imageLabels = imageLabels == null ? [] : [...imageLabels];
  }
}