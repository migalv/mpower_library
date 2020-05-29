import 'package:cons_calc_lib/src/models/answer_model.dart';

class Question {
  Question({
    this.id,
    this.label,
    this.answers,
    this.index,
    this.questionPurpose,
    this.tableId,
    this.applianceKey,
  });

  final String id;
  final Map label;
  final List<Answer> answers;
  final int index;
  final QuestionPurpose questionPurpose;
  final String tableId;
  final String applianceKey;

  Question.fromJson(final Map<String, dynamic> json)
      : this.id = json[ID],
        this.label = json[LABEL],
        this.answers = json[ANSWERS] != null
            ? json[ANSWERS]
                .map((answer) =>
                    Answer.fromJson(Map<String, dynamic>.from(answer)))
                .cast<Answer>()
                .toList()
            : [],
        this.index = json[INDEX],
        this.tableId = json[TABLE_ID],
        this.applianceKey = json[APPLIANCE_KEY],
        this.questionPurpose = json[QUESTION_PURPOSE] != null
            ? QuestionPurpose.values[json[QUESTION_PURPOSE]]
            : null;

  static const String ID = "question_id";
  static const String LABEL = "question_label";
  static const String ANSWERS = "answers";
  static const String INDEX = "index";
  static const String TABLE_ID = "table_id";
  static const String QUESTION_PURPOSE = "question_purpose";
  static const String APPLIANCE_KEY = "appliance_key";
  static const String JUST_VALUE = "JUST_VALUE";
}

enum QuestionPurpose {
  CONSUMPTION,
  MARKETING,
  TRIGGER,
  NUM_OF_UNITS,
  ADD_FORM,
  PRODUCT_SELECTION,
}
