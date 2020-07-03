import 'dart:async';

import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/dynamic_form_model.dart';
import 'package:rxdart/rxdart.dart';

abstract class DynamicFormsRepository {
  DynamicForm initialForm;

  Stream<Map<String, Map>> get formResultsStream =>
      _formResultsStreamController.stream;
  final _formResultsStreamController = BehaviorSubject<Map<String, Map>>();

  /// Fetches asynchronously a form from Firestore that matches the given [formId]
  ///
  /// Returns a DynamicForm Model with all the questions & answers
  /// if there was an error fetching the form the function will return null
  Future<DynamicForm> getFormWithId(String formId);

  /// Uploads the results form results to firestore
  void uploadFormResults(Map<String, dynamic> formResults);

  /// Updates the value of the form results
  void updateFormResults(Map<String, Map> formResults) =>
      _formResultsStreamController.add(formResults);

  void dispose() {
    _formResultsStreamController.close();
  }
}
