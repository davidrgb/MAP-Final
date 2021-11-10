import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/model/comment.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/mydialog.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class CommentViewScreen extends StatefulWidget {
  static const routeName = '/commentViewScreen';

  late final User user;
  final PhotoMemo photoMemo;

  CommentViewScreen({required this.user, required this.photoMemo});

  @override
  State<StatefulWidget> createState() {
    return _CommentViewState();
  }
}

class _CommentViewState extends State<CommentViewScreen> {
  late _Controller con;
  GlobalKey<FormState> newCommentFormKey = GlobalKey();
  GlobalKey<FormState> editCommentFormKey = GlobalKey();

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
        title: Text('Comments on ' + widget.photoMemo.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: WebImage(
                url: widget.photoMemo.photoURL,
                context: context,
              ),
            ),
            for (int i = 0; i < con.commentList.length; i++)
              Card(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      Text(
                        '${con.commentList[i].createdBy} at ${con.commentList[i].timestamp}',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Text(
                        con.commentList[i].content,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      con.commentList[i].createdBy == widget.user.email!
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text('Edit Comment'),
                                      actions: [
                                        Form(
                                          key: editCommentFormKey,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'Edit comment',
                                            ),
                                            initialValue:
                                                con.commentList[i].content,
                                            maxLines: 3,
                                            autocorrect: true,
                                            validator: Comment.validateContent,
                                            onSaved: con.saveCommentContent,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  con.editComment(i),
                                              child: Text('Edit'),
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.green),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Text('Edit'),
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.green),
                                ),
                                ElevatedButton(
                                  onPressed: () => showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text('Confirm Delete'),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => {
                                                con.deleteComment(i),
                                                Navigator.pop(context),
                                              },
                                              child: Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  child: Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              height: 1.0,
                            ),
                    ],
                  ),
                ),
              ),
            Form(
              key: newCommentFormKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'New comment',
                    ),
                    maxLines: 3,
                    autocorrect: true,
                    validator: Comment.validateContent,
                    onSaved: con.saveCommentContent,
                  ),
                  ElevatedButton(
                    onPressed: con.addComment,
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  late _CommentViewState state;
  Comment tempComment = Comment();
  late List<Comment> commentList;
  late String contentEdit;

  _Controller(this.state) {
    commentList = [];
    getComments();
  }

  void getComments() async {
    late List<Comment> results;
    try {
      results = await FirestoreController.getCommentList(
          photoMemoID: state.widget.photoMemo.docId!);
    } catch (e) {
      if (Constant.DEV) print('======== getComment error: $e');
      MyDialog.showSnackBar(
          context: state.context, message: 'Failed to get comment list: $e');
    }
    state.render(() => commentList = results);
  }

  void saveCommentContent(String? value) {
    if (value != null) tempComment.content = value;
  }

  void addComment() async {
    FormState? currentState = state.newCommentFormKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    try {
      tempComment.createdBy = state.widget.user.email!;
      tempComment.timestamp = DateTime.now();
      tempComment.photoMemoID = state.widget.photoMemo.docId!;

      String docId = await FirestoreController.addComment(comment: tempComment);
      tempComment.docId = docId;
      commentList.insert(0, Comment.clone(tempComment));

      tempComment = Comment();

      currentState.reset();

      state.render(() {});
    } catch (e) {
      if (Constant.DEV) print('======== Add new comment failed: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Add new comment failed: $e',
      );
    }
  }

  void deleteComment(int index) async {
    try {
      await FirestoreController.deleteComment(comment: commentList[index]);

      state.render(() => {commentList.removeAt(index)});
    } catch (e) {
      if (Constant.DEV) print('======== Delete comment failed: $e');
      MyDialog.showSnackBar(
        context: state.context,
        message: 'Delete comment failed: $e',
      );
    }
  }

  void editComment(int index) async {
    FormState? currentState = state.editCommentFormKey.currentState;
    if (currentState == null || !currentState.validate()) return;
    currentState.save();

    try {
      Map<String, dynamic> updateInfo = {};

      if (tempComment.content != commentList[index].content)
        updateInfo[Comment.CONTENT] = tempComment.content;

      tempComment.createdBy = commentList[index].createdBy;
      tempComment.photoMemoID = commentList[index].photoMemoID;
      tempComment.docId = commentList[index].docId;
      tempComment.timestamp = commentList[index].timestamp;

      if (updateInfo.isNotEmpty) {
        tempComment.timestamp = DateTime.now();
        updateInfo[Comment.TIMESTAMP] = tempComment.timestamp;
        await FirestoreController.updateComment(
          docId: tempComment.docId!,
          updateInfo: updateInfo,
        );
        commentList.removeAt(index);
        commentList.insert(0, Comment.clone(tempComment));
        tempComment = Comment();

        currentState.reset();

        state.render(() => {Navigator.pop(state.context)});
      }
    } catch (e) {
      if (Constant.DEV) print('======== Edit comment failed: $e');
      MyDialog.showSnackBar(
          context: state.context, message: 'Edit comment failed: $e');
    }
  }
}
