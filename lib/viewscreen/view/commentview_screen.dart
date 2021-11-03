import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class CommentViewScreen extends StatefulWidget {
  static const routeName = '/commentViewScreen';

  final User user;
  final PhotoMemo photoMemo;

  CommentViewScreen({required this.user, required this.photoMemo});

  @override
  State<StatefulWidget> createState() {
    return _CommentViewState();
  }
}

class _CommentViewState extends State<CommentViewScreen> {
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
        title: Text('Comments'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: WebImage(
                url: widget.photoMemo.photoURL,
                context: context,
              ),
            ),
            TextFormField(
              enabled: false,
              style: Theme.of(context).textTheme.headline6,
              initialValue: widget.photoMemo.title,
            ),
          ],
        ),
      ),
    );
  }
}

class _Controller {
  late _CommentViewState state;

  _Controller(this.state);
}
