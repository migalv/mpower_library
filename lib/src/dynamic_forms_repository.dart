import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cons_calc_lib/cons_calc_lib.dart';
import 'package:cons_calc_lib/src/models/analytic_event_type.dart';
import 'package:cons_calc_lib/src/models/dynamic_form_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:meta/meta.dart';

abstract class DynamicFormsRepository {
  DynamicForm initialForm;
  FirebaseUser currentUser;
  final String codeVersion;
  int initTimestamp;
  final bool isDebugging;

  /// The source where the user came from
  final String source;

  /// The name of the campaign the user came from
  final String campaign;

  DynamicFormsRepository(
    this.codeVersion, {
    this.isDebugging,
    this.source = "organic",
    this.campaign,
  });

  Stream<Map<String, List<Map>>> get formResultsStream =>
      _formResultsStreamController.stream;
  final _formResultsStreamController =
      BehaviorSubject<Map<String, List<Map>>>();

  /// Fetches asynchronously a form from Firestore that matches the given [formId]
  ///
  /// Returns a DynamicForm Model with all the questions & answers
  /// if there was an error fetching the form the function will return null
  Future<DynamicForm> getFormWithId(String formId);

  /// Creates a document in Firestore that represents the initiation on a form
  ///
  /// Returns true if the accion was saved in Firestore correctly
  /// false if the call does not execute in less than 3 seconds
  Future<bool> formStarted() async {
    bool response = true;

    try {
      await Firestore.instance
          .collection("form_results")
          .document(initTimestamp.toString())
          .setData({
        "notify_emails": initialForm.emailList,
        "starting_form_id": initialForm.id,
        "starting_timestamp": initTimestamp,
        "source": source,
        "campaign": campaign,
      }, merge: true).timeout(Duration(seconds: 5));
    } on TimeoutException {
      response = false;
    }

    if (response == false) return response;

    registerAnalyticEvent(
      initialFormId: initialForm.id,
      eventName: "source.$source",
      eventType: AnalyticEventType.INCREMENT,
    );

    registerAnalyticEvent(
      initialFormId: initialForm.id,
      eventName: "campaign.$campaign",
      eventType: AnalyticEventType.INCREMENT,
    );

    return response;
  }

  /// Uploads the answer of a question [answerResults] for the form with id
  /// [formId] that a user with id [userId] answered. The [repetitionIndex] is
  /// used to know to which index insert the answer
  ///
  /// Returns true if answer was correctly saved in Firestore
  /// false if the call does not execute in less than 3 seconds
  Future<bool> uploadAnswer(String formId, String questionId, Map answerResults,
      int repetitionIndex) async {
    bool response = true;
    Map answerResultsCopy = Map.from(answerResults);

    if (answerResultsCopy["question_purpose"] ==
        QuestionPurpose.PRODUCT_SELECTION)
      answerResultsCopy["value"] = answerResultsCopy["value"]?.name ?? "N/A";
    QuestionPurpose qp = answerResultsCopy["question_purpose"];
    answerResultsCopy.remove("question_purpose");
    answerResultsCopy["question_purpose"] = qp.index;
    answerResultsCopy.remove("table_id");

    Map<String, dynamic> data = {
      "results": {
        "$formId": {
          "$repetitionIndex": {
            "$questionId": answerResultsCopy,
          },
        },
      },
      "last_updated_at": DateTime.now().millisecondsSinceEpoch,
      "last_answer_code_version": codeVersion,
      "last_answered_question": questionId,
    };

    try {
      await Firestore.instance
          .collection("form_results")
          .document(initTimestamp.toString())
          .setData(data, merge: true)
          .timeout(Duration(seconds: 5));
    } on TimeoutException {
      response = false;
    }

    return response;
  }

  /// Signs in anonymously
  Future<void> signInAnonymously() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    initTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (currentUser == null)
      currentUser = (await FirebaseAuth.instance.signInAnonymously()).user;
  }

  /// Updates the value of the form results
  ///
  /// Returns true if the form was correctly saved in Firestore
  /// false if the call does not execute in less than 3 seconds
  Future<bool> formFinished(Map<String, List<Map>> formResults) async {
    bool response = true;
    _formResultsStreamController.add(formResults);

    try {
      await Firestore.instance
          .collection("form_results")
          .document(initTimestamp.toString())
          .setData({"completed_forms": formResults.keys},
              merge: true).timeout(Duration(seconds: 5));
    } on TimeoutException {
      response = false;
    }

    return response;
  }

  /// Function used to register Analytic Events
  ///
  /// [String initialFormId] is refered to the id of the initial form from where
  /// the event was registered
  ///
  /// [String eventName] is the name of the event that is being registered
  ///
  /// [AnalyticEventType eventType] is an enum to specify the type of event that
  /// is being registered
  ///
  /// [dynamic value] is an optional parameter used when eventType is VALUE
  void registerAnalyticEvent({
    @required String initialFormId,
    @required String eventName,
    @required AnalyticEventType eventType,
    dynamic value,
  }) {
    // If we are devolopping/debuggin we don't register analytic events
    if (isDebugging == true) return;
    // If the event type is INCREMENT then the value has to be null
    assert(eventType == AnalyticEventType.INCREMENT ? value == null : true);

    // If the event type is VALUE then the value can't be null
    assert(eventType == AnalyticEventType.VALUE ? value != null : true);

    DocumentReference doc = Firestore.instance
        .collection("dynamic_forms_analytics")
        .document(initialFormId);

    doc.get().then((docSnapshot) {
      if (docSnapshot.exists) {
        switch (eventType) {
          case AnalyticEventType.INCREMENT:
            doc.updateData({eventName: FieldValue.increment(1)});
            break;
          case AnalyticEventType.VALUE:
            break;
        }
      } else {
        switch (eventType) {
          case AnalyticEventType.INCREMENT:
            doc.setData({eventName: 1});
            break;
          case AnalyticEventType.VALUE:
            break;
        }
      }
    }).catchError((e) {
      print(e);
    });
  }

  void updateLastAnsweredQuestion({
    @required String initialFormId,
    Question currentQuestion,
    Question previousQuestion,
  }) {
    DocumentReference doc = Firestore.instance
        .collection("dynamic_forms_analytics")
        .document(initialFormId);

    if (currentQuestion != null && previousQuestion != null)
      doc.setData({
        "last_answered_question": {
          previousQuestion.id: FieldValue.increment(-1),
          currentQuestion.id: FieldValue.increment(1),
        },
      }, merge: true);
    else if (currentQuestion == null && previousQuestion != null) {
      doc.setData({
        "last_answered_question": {
          previousQuestion.id: FieldValue.increment(-1),
        },
      }, merge: true);
    } else if (currentQuestion != null && previousQuestion == null) {
      doc.setData({
        "last_answered_question": {
          currentQuestion.id: FieldValue.increment(1),
        },
      }, merge: true);
    }
  }

  void updateLastViewedQuestion({
    @required String initialFormId,
    Question currentQuestion,
    Question previousQuestion,
  }) {
    DocumentReference doc = Firestore.instance
        .collection("dynamic_forms_analytics")
        .document(initialFormId);

    if (currentQuestion != null && previousQuestion != null)
      doc.setData({
        "last_viewed_question": {
          previousQuestion.id: FieldValue.increment(-1),
          currentQuestion.id: FieldValue.increment(1),
        },
      }, merge: true);
    else if (currentQuestion == null && previousQuestion != null) {
      doc.setData({
        "last_viewed_question": {
          previousQuestion.id: FieldValue.increment(-1),
        },
      }, merge: true);
    } else if (currentQuestion != null && previousQuestion == null) {
      doc.setData({
        "last_viewed_question": {
          currentQuestion.id: FieldValue.increment(1),
        },
      }, merge: true);
    }
  }

  void dispose() {
    _formResultsStreamController.close();
  }
}
