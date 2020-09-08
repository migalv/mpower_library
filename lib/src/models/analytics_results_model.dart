class AnalyticsResults {
  final String formId;
  final int visitors;
  final int users;
  final int leads;
  int _bounceCount;
  int get bounceCount => _bounceCount;
  double _bounceRate;
  double get bounceRate => _bounceRate;
  double _userConversionRate;
  double get userConversionRate => _userConversionRate;
  double _leadConversionRate;
  double get leadConversionRate => _leadConversionRate;

  AnalyticsResults(this.formId, this.visitors, this.users, this.leads,
      this._bounceCount, this._bounceRate);

  AnalyticsResults.fromJson({this.formId, Map<String, dynamic> json})
      : this.visitors = json[VISITORS_KEY],
        this.users = json[USERS_KEY],
        this.leads = json[LEADS_KEY] {
    _bounceCount = visitors - users;
    _bounceRate = _bounceCount / visitors * 100;
    _userConversionRate = users / visitors * 100;
    _leadConversionRate = leads / visitors * 100;
  }

  static const String VISITORS_KEY = "visitor_count";
  static const String USERS_KEY = "user_count";
  static const String LEADS_KEY = "lead_count";
}
