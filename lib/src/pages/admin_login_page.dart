import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/pages/admin_dashboard_page.dart';
import 'package:flutter/material.dart';

class AdminLoginPage extends StatefulWidget {
  static String route = '/admin';

  const AdminLoginPage({Key key}) : super(key: key);
  @override
  _AdminLoginPageState createState() => new _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController _userNameController =
      TextEditingController(text: 'admin');
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.network(
          "https://firebasestorage.googleapis.com/v0/b/mpower-dashboard-components.appspot.com/o/assets%2Fmpower_logos%2Flogo-con-text.svg?alt=media&token=3d4fd611-cff2-4a2a-b752-64d935902b29",
          color: Color.fromRGBO(0, 54, 103, 1),
        ),
      ),
    );

    final email = TextFormField(
      controller: _userNameController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          if (_userNameController.text == "admin"
              // &&
              //     _passwordController.text == "mPowerAdmin.123"
              )
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => AdminDashboardPage()));
          else
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text(
                        "Incorrect credentials",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      content: Text(
                        "Name or password are incorrect, please try again.",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      actions: [
                        FlatButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Close"),
                        )
                      ],
                    ));
        },
        padding: EdgeInsets.all(12),
        color: Colors.white,
        child: Text('Log In'),
      ),
    );

    return Scaffold(
      backgroundColor: secondaryMain,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 480),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              SizedBox(height: 48.0),
              email,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 24.0),
              loginButton
            ],
          ),
        ),
      ),
    );
  }
}
