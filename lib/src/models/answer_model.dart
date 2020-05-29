import 'package:cons_calc_lib/cons_calc_lib.dart';

class Answer {
  final String id;
  final AnswerType type;
  final String nextQuestionId;
  final Map<String, String> label;
  final String key;
  final bool isDefault;
  final bool restartForm;
  dynamic _value;
  dynamic get value => _value;

  Answer({
    this.id,
    this.type,
    value,
    this.nextQuestionId,
    this.label,
    this.key,
    this.isDefault = false,
    this.restartForm,
  }) : _value = value;

  Answer.fromJson(Map<String, dynamic> json)
      : this.id = json[ID],
        _value = json[VALUE],
        this.nextQuestionId = json[NEXT_QUESTION_ID],
        this.label =
            json[LABEL] != null ? Map<String, String>.from(json[LABEL]) : null,
        this.key = json[KEY],
        this.isDefault = json[DEFAULT] ?? false,
        this.type = json[TYPE] != null ? AnswerType.values[json[TYPE]] : null,
        this.restartForm = json[RESTART_FORM] ?? false;

  void setNewValue(dynamic newValue) => _value = newValue;

  static const String ID = "answer_id";
  static const String VALUE = "value";
  static const String NEXT_QUESTION_ID = "next_question_id";
  static const String KEY = "key";
  static const String LABEL = "answer_label";
  static const String DEFAULT = "is_default_answer";
  static const String TYPE = "answer_type";
  static const String FINISH_FORM = "END";
  static const String RESTART_FORM = "restart_form";
}
