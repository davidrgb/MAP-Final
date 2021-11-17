import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/favorite.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/commentview_screen.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class FavoriteScreen extends StatefulWidget {
  final List<PhotoMemo> photoMemoList;
  final User user;

  FavoriteScreen({required this.photoMemoList, required this.user});

  static const routeName = '/favoriteScreen';
  @override
  State<StatefulWidget> createState() {
    return _FavoriteState();
  }
}

class _FavoriteState extends State<FavoriteScreen> {
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
        title: Text('${widget.user.email} Favorites'),
      ),
      body: SingleChildScrollView(
        child: widget.photoMemoList.isEmpty
            ? Text('No favorites',
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
  late _FavoriteState state;
  late List<PhotoMemo> photoMemoList;
  late List<bool> memoHasComments;
  late List<bool> favorites;
  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    memoHasComments = [];
    checkComments();
    favorites = [];
    for (int i = 0; i < photoMemoList.length; i++) {
      favorites.insert(i, true);
    }
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
      } else {
        result.photoMemoIds.add(photoMemoList[index].docId);
        favorites.removeAt(index);
        favorites.insert(index, true);
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