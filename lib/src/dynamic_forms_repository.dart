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
  final String codeVersion;

  DynamicFormsRepository(this.codeVersion);

  Stream<Map<String, List<Map>>> get formResultsStream =>
      _formResultsStreamController.stream;
  final _formResultsStreamController =
      BehaviorSubject<Map<String, List<Map>>>();

  /// Fetches asynchronously a form from Firestore that matches the given [formId]
  ///
  /// Returns a DynamicForm Model with all the questions & answers
  /// if there was an error fetching the form the function will return null
  Future<DynamicForm> getFormWithId(String formId);

  /// Uploads the answer of a question [answerResults] for the form with id
  /// [formId] that a user with id [userId] answered. The [repetitionIndex] is
  /// used to know to which index insert the answer
  void uploadAnswer(String formId, String questionId, Map answerResults,
      int repetitionIndex) {
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
        "$repetitionIndex": {
          "$questionId": answerResultsCopy,
        },
      },
      "last_updated_at": DateTime.now().millisecondsSinceEpoch,
      "last_answer_code_version": codeVersion,
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
      "notify_emails": emails,
    }, merge: true);
  }

  /// Updates the value of the form results
  void formFinished(Map<String, List<Map>> formResults) {
    _formResultsStreamController.add(formResults);
    Firestore.instance
        .collection("form_results")
        .document(currentUser.uid)
        .setData({"completed_forms": formResults.keys}, merge: true);
  }

  void dispose() {
    _formResultsStreamController.close();
  }
}
