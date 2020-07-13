import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PersonalInfoFormDialog extends StatelessWidget {
  final String title;
  final TextEditingController nameController = TextEditingController(),
      phoneController = TextEditingController(),
      emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PersonalInfoFormDialog({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _validateForm(context);
        return Future.value(false);
      },
      child: AlertDialog(
        title: Text(
          title ?? "",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        content: Form(
          key: _formKey,
          child: Container(
            width: 256.0,
            height: 232.0,
            child: ListView(
              children: [
                _buildTextField(
                  "Nom",
                  MdiIcons.account,
                  nameController,
                  isRequired: true,
                ),
                _buildTextField(
                  "Numero de téléphone",
                  MdiIcons.phone,
                  phoneController,
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                  minLength: 8,
                  textInputFormatters: [
                    WhitelistingTextInputFormatter.digitsOnly
                  ],
                ),
                _buildTextField(
                  "Email",
                  Icons.email,
                  emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
        actions: [
          RaisedButton(
            onPressed: () => _validateForm(context),
            child: Text("Continuer", style: TextStyle(color: black70)),
          ),
        ],
      ),
    );
  }

  // BUILD
  Widget _buildTextField(
    String label,
    IconData iconData,
    TextEditingController controller, {
    TextInputType keyboardType,
    List<TextInputFormatter> textInputFormatters,
    int minLength,
    bool isRequired = false,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Theme(
          data: ThemeData(primaryColor: secondaryMain),
          child: TextFormField(
            validator: isRequired
                ? (val) {
                    if (val == null ||
                        val == "" ||
                        (minLength != null && val.length < minLength))
                      return "Entrer un $label valide";
                    return null;
                  }
                : null,
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: textInputFormatters,
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
        ),
      );

  // METHODS
  void _validateForm(BuildContext context) {
    if (_formKey.currentState.validate()) {
      Map<String, Map> contactInfo = {};
      contactInfo["name"] = {
        "label": "Name",
        "value": nameController.text,
      };
      contactInfo["phone"] = {
        "label": "Phone Number",
        "value": phoneController.text,
      };
      if (emailController.text != null && emailController.text != "")
        contactInfo["email"] = {
          "label": "Email",
          "value": emailController.text,
        };
      Navigator.of(context).pop(contactInfo);
    }
  }
}
