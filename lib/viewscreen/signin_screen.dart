import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signInScreen';

  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignInScreen> {
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
        title: Text('Sign In'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('Sign In, Please!',
                  style: Theme.of(context).textTheme.headline5),
              TextFormField(
                decoration: InputDecoration(hintText: 'Email address'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: con.validateEmail,
                onSaved: con.saveEmail,
              ),
              TextFormField(
                decoration: InputDecoration(hintText: 'Enter password'),
                obscureText: true,
                autocorrect: false,
                validator: con.validatePassword,
                onSaved: con.savePassword,
              ),
              ElevatedButton(
                onPressed: con.signIn,
                child: Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.button,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _SignInState state;
  _Controller(this.state);

  String? validateEmail(String? value) {
    return null;
  }

  void saveEmail(String? value) { }

  String? validatePassword(String? value) {
    return null;
  }

  void savePassword(String? value) { }

  void signIn() { }
}
