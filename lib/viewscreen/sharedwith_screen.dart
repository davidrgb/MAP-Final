import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/favorite.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/commentview_screen.dart';
import 'package:lesson3/viewscreen/favorite_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class SharedWithScreen extends StatefulWidget {
  final List<PhotoMemo> photoMemoList;
  final User user;

  SharedWithScreen({required this.photoMemoList, required this.user});

  static const routeName = '/sharedWithScreen';
  @override
  State<StatefulWidget> createState() {
    return _SharedWithState();
  }
}

class _SharedWithState extends State<SharedWithScreen> {
  late _Controller con;

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shared With ${widget.user.email}'),
        actions: [
          IconButton(
            onPressed: con.favoriteScreen,
            icon: Icon(Icons.favorite),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: widget.photoMemoList.isEmpty
            ? Text('No PhotoMemos shared with me',
                style: Theme.of(context).textTheme.headline6)
            : Column(
                children: [
                  for (int i = 0; i < widget.photoMemoList.length; i++)
                    GestureDetector(
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  WebImage(
                                    url: widget.photoMemoList[i].photoURL,
                                    context: context,
                                    height: MediaQuery.of(context).size.height *
                                        0.35,
                                  ),
                                  if (con.memoHasComments.isNotEmpty)
                                    con.memoHasComments[i]
                                        ? Positioned(
                                            bottom: 10.0,
                                            right: 10.0,
                                            child: CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Colors.blue,
                                              child: Icon(
                                                Icons.comment,
                                                size: 32.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 1.0,
                                          ),
                                  Positioned(
                                    left: 10.0,
                                    top: 10.0,
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.blue,
                                      child: IconButton(
                                        onPressed: () => con.favorite(i),
                                        icon: (con.favorites.isNotEmpty)
                                            ? con.favorites[i]
                                                ? Icon(
                                                    Icons.favorite,
                                                    color: Colors.white,
                                                    size: 32.0,
                                                  )
                                                : Icon(
                                                    Icons.favorite_outline,
                                                    color: Colors.white,
                                                    size: 32.0,
                                                  )
                                            : Icon(
                                                Icons.favorite_outline,
                                                color: Colors.white,
                                                size: 32.0,
                                              ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              widget.photoMemoList[i].title,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            Text(widget.photoMemoList[i].memo),
                            Text(
                                'Created by: ${widget.photoMemoList[i].createdBy}'),
                            Text(
                                'Created at: ${widget.photoMemoList[i].timestamp}'),
                            Text(
                                'Shared with: ${widget.photoMemoList[i].sharedWith}'),
                            Text(
                                'Image Labels: ${widget.photoMemoList[i].imageLabels}'),
                          ],
                        ),
                      ),
                      onTap: () => con.onTap(i),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Controller {
  late _SharedWithState state;
  late List<PhotoMemo> photoMemoList;
  late List<bool> memoHasComments;
  late List<bool> favorites;
  late List<PhotoMemo> favoritePhotoMemoList;
  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    memoHasComments = [];
    checkComments();
    favorites = [];
    checkFavorites();
    favoritePhotoMemoList = [];
  }

  void favoriteScreen() async {
    try {
      await Navigator.pushNamed(
        state.context,
        FavoriteScreen.routeName,
        arguments: {
          ARGS.PhotoMemoList: favoritePhotoMemoList,
          ARGS.USER: state.widget.user,
        },
      );
    } catch (e) {
      if (Constant.DEV) print('======== Failed to open favorites screen: $e');
      MyDialog.showSnackBar(
          context: state.context,
          message: '======== Failed to open favorites screen: $e');
    }
    await checkFavorites();
    state.render((){});
  }

  void favorite(int index) async {
    late Favorite result;
    try {
      result = await FirestoreController.getFavorites(
          email: state.widget.user.email!);
    } catch (e) {
      if (Constant.DEV) print('======== Failed to get favorites: $e');
      MyDialog.showSnackBar(
          context: state.context,
          message: '======== Failed to get favorites: $e');
    }
    try {
      if (favorites[index]) {
        result.photoMemoIds.remove(photoMemoList[index].docId);
        favorites.removeAt(index);
        favorites.insert(index, false);
        favoritePhotoMemoList.remove(photoMemoList[index]);
      } else {
        result.photoMemoIds.add(photoMemoList[index].docId);
        favorites.removeAt(index);
        favorites.insert(index, true);
        favoritePhotoMemoList.add(photoMemoList[index]);
      }
      if (result.docId == null) {
        result.favoritedBy = state.widget.user.email!;
        await FirestoreController.addFavorite(favorite: result);
      } else {
        Map<String, dynamic> updateInfo = {};
        updateInfo[Favorite.PHOTOMEMOIDS] = result.photoMemoIds;
        await FirestoreController.updateFavorite(
            docId: result.docId!, updateInfo: updateInfo);
      }
    } catch (e) {
      if (Constant.DEV) print('======== Failed to update favorites: $e');
      MyDialog.showSnackBar(
          context: state.context,
          message: '======== Failed to update favorites: $e');
    }
    state.render(() {});
  }

  Future<void> checkFavorites() async {
    late Favorite result;
    try {
      result = await FirestoreController.getFavorites(
          email: state.widget.user.email!);
    } catch (e) {
      if (Constant.DEV) print('======== Failed to get favorites: $e');
      MyDialog.showSnackBar(
          context: state.context,
          message: '======== Failed to get favorites: $e');
    }
    favorites.clear();
    favoritePhotoMemoList.clear();
    for (int i = 0; i < photoMemoList.length; i++) {
      if (result.photoMemoIds.contains(photoMemoList[i].docId)) {
        favorites.insert(i, true);
        favoritePhotoMemoList.add(photoMemoList[i]);
      } else {
        favorites.insert(i, false);
      }
    }
  }

  void onTap(int index) async {
    await Navigator.pushNamed(state.context, CommentViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
    checkComments();
  }

  void checkComments() async {
    if (memoHasComments.isNotEmpty) memoHasComments.clear();
    for (int i = 0; i < photoMemoList.length; i++) {
      late List<Comment> results;
      try {
        results = await FirestoreController.getCommentList(
            photoMemoID: state.widget.photoMemoList[i].docId!);
      } catch (e) {
        if (Constant.DEV) print('======== Failed to get comment list: $e');
        MyDialog.showSnackBar(
            context: state.context,
            message: '======== Failed to get comment list: $e');
      }
      if (results.isNotEmpty)
        memoHasComments.insert(i, true);
      else
        memoHasComments.insert(i, false);
    }
    state.render(() {});
  }
}
