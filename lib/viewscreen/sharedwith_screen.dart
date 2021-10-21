import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/photomemo.dart';
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
            ? Text('No PhotoMemos shared with me', style: Theme.of(context).textTheme.headline6)
            : Column(
                children: [
                  for (var photoMemo in widget.photoMemoList)
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: WebImage(
                              url: photoMemo.photoURL,
                              context: context,
                              height: MediaQuery.of(context).size.height * 0.35,
                            ),
                          ),
                          Text(
                            photoMemo.title,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(photoMemo.memo),
                          Text('Created by: ${photoMemo.createdBy}'),
                          Text('Created at: ${photoMemo.timestamp}'),
                          Text('Shared with: ${photoMemo.sharedWith}'),
                          Text('Image Labels: ${photoMemo.imageLabels}'),
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
  late _SharedWithState state;
  _Controller(this.state);
}
