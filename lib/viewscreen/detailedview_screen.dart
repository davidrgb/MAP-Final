import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lesson3/model/photomemo.dart';
import 'package:lesson3/viewscreen/view/webimage.dart';

class DetailedViewScreen extends StatefulWidget {
  static const routeName = '/detailedViewScreen';

  final User user;
  final PhotoMemo photoMemo;

  DetailedViewScreen({required this.user, required this.photoMemo});

  @override
  State<StatefulWidget> createState() {
    return _DetailedViewState();
  }
}

class _DetailedViewState extends State<DetailedViewScreen> {
  bool editMode = false;
  late _Controller con;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
        title: Text('Detailed View'),
        actions: [
          editMode
              ? IconButton(onPressed: con.update, icon: Icon(Icons.check))
              : IconButton(onPressed: con.edit, icon: Icon(Icons.edit))
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: WebImage(
                      url: con.tempMemo.photoURL,
                      context: context,
                    ),
                  ),
                  editMode
                      ? Positioned(
                        right: 0.0,
                        bottom: 0.0,
                        child: Container(
                          color: Colors.blue,
                          child: PopupMenuButton(
                              onSelected: con.getPhoto,
                              itemBuilder: (context) => [
                                for (var source in PhotoSource.values)
                                  PopupMenuItem<PhotoSource>(
                                    value: source,
                                    child: Text('${source.toString().split('.')[1]}'),
                                  )
                              ],
                            ),
                        ),
                      )
                      : SizedBox(
                          height: 1.0,
                        ),
                ],
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.headline6,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                ),
                initialValue: con.tempMemo.title,
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: null,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: 'Enter memo',
                ),
                initialValue: con.tempMemo.memo,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                autocorrect: true,
                validator: PhotoMemo.validateMemo,
                onSaved: null,
              ),
              TextFormField(
                enabled: editMode,
                style: Theme.of(context).textTheme.bodyText1,
                decoration: InputDecoration(
                  hintText: 'Enter sharedWith email list',
                ),
                initialValue: con.tempMemo.sharedWith.join(','),
                keyboardType: TextInputType.multiline,
                maxLines: 2,
                autocorrect: false,
                validator: PhotoMemo.validateSharedWith,
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
  late _DetailedViewState state;
  late PhotoMemo tempMemo;
  _Controller(this.state) {
    tempMemo = PhotoMemo.clone(state.widget.photoMemo);
  }

  void getPhoto(PhotoSource source) {

  }

  void update() {
    state.render(() => state.editMode = false);
  }

  void edit() {
    state.render(() => state.editMode = true);
  }
}
