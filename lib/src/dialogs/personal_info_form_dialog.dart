import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/material.dart';

class PersonalInfoFormDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: AlertDialog(
        useMaterialBorderRadius: true,
        title: Text(
          "Tell us a little more about yourself",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Theme(
          data: ThemeData(
            primaryColor: secondaryMain,
            cursorColor: secondaryMain,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Name", Icons.person),
              _buildTextField("Phone number", Icons.phone),
              _buildTextField("Email", Icons.email),
            ],
          ),
        ),
        actions: [
          RaisedButton(
            onPressed: () {},
            child: Text("Continue", style: TextStyle(color: black70)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData iconData) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(iconData),
            filled: true,
            border: UnderlineInputBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
          ),
        ),
      );
}
