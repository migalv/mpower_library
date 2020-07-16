import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/dynamic_form_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';

abstract class DynamicFormsRepository {
  DynamicForm initialForm;
  FirebaseUser currentUser;

  Stream<Map<String, Map>> get formResultsStream =>
      _formResultsStreamController.stream;
  final _formResultsStreamController = BehaviorSubject<Map<String, Map>>();

  /// Fetches asynchronously a form from Firestore that matches the given [formId]
  ///
  /// Returns a DynamicForm Model with all the questions & answers
  /// if there was an error fetching the form the function will return null
  Future<DynamicForm> getFormWithId(String formId);

  /// Uploads the answer of a question for the form with id [formId] that a user
  /// with id [userId] answered
  void uploadAnswer(String formId, String questionId, Map answerResults) {
    Map answerResultsCopy = Map.from(answerResults);

    if (answerResultsCopy["question_purpose"] ==
        QuestionPurpose.PRODUCT_SELECTION)
      answerResultsCopy["value"] = answerResultsCopy["value"]?.name ?? "N/A";
    QuestionPurpose qp = answerResultsCopy["question_purpose"];
    answerResultsCopy.remove("question_purpose");
    answerResultsCopy["question_purpose"] = qp.index;
    answerResultsCopy.remove("table_id");

    Firestore.instance
        .collection("form_results")
        .document(currentUser.uid)
        .setData({
      "$formId": {
        "$questionId": answerResultsCopy,
      },
      "last_updated_at": DateTime.now().millisecondsSinceEpoch,
    }, merge: true);
  }

  /// Signs in anonymously
  Future<void> signInAnonymously() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    if (currentUser == null)
      currentUser = (await FirebaseAuth.instance.signInAnonymously()).user;
  }

  /// Update the email list for a form
  void updateEmailList(
      {@required List<String> emails, @required String formId}) {
    Firestore.instance
        .collection("form_results")
        .document(currentUser.uid)
        .setData({
      "email_list": {
        "$formId": emails,
      }
    }, merge: true);
  }

  /// Updates the value of the form results
  void formFinished(Map<String, Map> formResults) {
    _formResultsStreamController.add(formResults);
    // TODO CALL CLOUD FUNCTION TO NOTIFY THAT THE FORM WAS FINISHED
  }

  void dispose() {
    _formResultsStreamController.close();
  }
}
