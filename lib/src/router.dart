import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/pages/admin_login_page.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class FluroRouter {
  static Router router = Router();

  static Handler _adminLoginHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          AdminLoginPage());

  static Handler _dynamicFormsHandler = Handler(
      handlerFunc: (BuildContext context, Map<String, dynamic> params) =>
          DynamicFormPage());
  static void setupRouter() {
    router.define(
      '/',
      handler: _dynamicFormsHandler,
    );
    router.define(
      '/admin',
      handler: _adminLoginHandler,
    );
  }
}
