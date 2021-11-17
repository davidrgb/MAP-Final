class Favorite {
  static const FAVORITED_BY = 'favoritedby';
  static const PHOTOMEMOIDS = 'photomemoids';

  String? docId;
  late String favoritedBy;
  late List<dynamic> photoMemoIds;

  Favorite({
    this.docId,
    this.favoritedBy = '',
    List<dynamic>? photoMemoIds,
  }) {
    this.photoMemoIds = photoMemoIds == null ? [] : [...photoMemoIds];
  }

  Favorite.clone(Favorite f) {
    this.docId = f.docId;
    this.favoritedBy = f.favoritedBy;
    this.photoMemoIds = [...f.photoMemoIds];
  }

  void assign(Favorite f) {
    this.docId = f.docId;
    this.favoritedBy = f.favoritedBy;
    this.photoMemoIds.clear();
    this.photoMemoIds.addAll(f.photoMemoIds);
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      FAVORITED_BY: this.favoritedBy,
      PHOTOMEMOIDS: this.photoMemoIds,
    };
  }

  static Favorite? fromFirestoreDoc(
      {required Map<String, dynamic> doc, required String docId}) {
    for (var key in doc.keys) {
      if (doc[key] == null) return null;
    }
    return Favorite(
      docId: docId,
      favoritedBy: doc[FAVORITED_BY] ??= 'N/A',
      photoMemoIds: doc[PHOTOMEMOIDS] ??= [],
    );
  }
}
