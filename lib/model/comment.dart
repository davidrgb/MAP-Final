class Comment {
  static const CREATED_BY = 'createdby';
  static const CONTENT = 'content';
  static const TIMESTAMP = 'timestamp';
  static const PHOTOMEMOID = 'photomemoid';

  String? docId;
  late String createdBy;
  late String content;
  DateTime? timestamp;
  late String photoMemoID;

  Comment({
    this.docId,
    this.createdBy = '',
    this.content = '',
    this.timestamp,
    this.photoMemoID = '',
  });

  Comment.clone(Comment c) {
    this.docId = c.docId;
    this.createdBy = c.createdBy;
    this.content = c.content;
    this.timestamp = c.timestamp;
    this.photoMemoID = c.photoMemoID;
  }

  void assign(Comment c) {
    this.docId = c.docId;
    this.createdBy = c.createdBy;
    this.content = c.content;
    this.timestamp = c.timestamp;
    this.photoMemoID = c.photoMemoID;
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      CREATED_BY: this.createdBy,
      CONTENT: this.content,
      TIMESTAMP: this.timestamp,
      PHOTOMEMOID: this.photoMemoID,
    };
  }

  static Comment? fromFirestoreDoc(
      {required Map<String, dynamic> doc, required String docId}) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }
    return Comment(
      docId: docId,
      createdBy: doc[CREATED_BY] ??= 'N/A',
      content: doc[CONTENT] ??= 'N/A',
      photoMemoID: doc[PHOTOMEMOID] ??= 'N/A',
      timestamp: doc[TIMESTAMP] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              doc[TIMESTAMP].millisecondsSinceEpoch)
          : DateTime.now(),
    );
  }

  static String? validateContent(String? value) {
    return value == null || value.trim().length < 3 ? 'Content too short' : null;
  }
}
