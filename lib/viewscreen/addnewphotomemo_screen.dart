import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddNewPhotoMemoScreen extends StatefulWidget {
  static const routeName = '/addNewPhotoMemoScreen';
  late final User user;

  AddNewPhotoMemoScreen({required this.user});

  @override
  State<StatefulWidget> createState() {
    return _AddNewPhotoMemoState();
  }
}

class _AddNewPhotoMemoState extends State<AddNewPhotoMemoScreen> {
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey();
  File? photo;

  _AddNewPhotoMemoState() {
    con = _Controller(this);
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New PhotoMemo'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height + 0.35,
                child: photo == null
                    ? FittedBox(
                        child: Icon(Icons.photo_library),
                      )
                    : Image.file(photo!),
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Title'),
                autocorrect: true,
                validator: null,
                onSaved: null,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Memo'),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: null,
                onSaved: null,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Shared with (comma separated email list'),
                maxLines: 2,
                keyboardType: TextInputType.emailAddress,
                validator: null,
                onSaved: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _AddNewPhotoMemoState state;
  _Controller(this.state);
}
