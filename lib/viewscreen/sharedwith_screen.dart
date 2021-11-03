import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/commentview_screen.dart';
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
                                  if (con.memoHasCommments.isNotEmpty)
                                    con.memoHasCommments[i]
                                        ? Positioned(
                                            bottom: 10.0,
                                            right: 10.0,
                                            child: Icon(
                                              Icons.comment,
                                              size: 36.0,
                                            ),
                                          )
                                        : SizedBox(
                                            height: 1.0,
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
  late List<bool> memoHasCommments;
  _Controller(this.state) {
    photoMemoList = state.widget.photoMemoList;
    memoHasCommments = [];
    checkComments();
  }

  void onTap(int index) async {
    await Navigator.pushNamed(state.context, CommentViewScreen.routeName,
        arguments: {
          ARGS.USER: state.widget.user,
          ARGS.OnePhotoMemo: photoMemoList[index],
        });
  }

  void checkComments() async {
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
        memoHasCommments.insert(i, true);
      else
        memoHasCommments.insert(i, false);
    }
    state.render(() {});
  }
}
