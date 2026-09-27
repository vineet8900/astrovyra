class NewsletterResponse {
  NewsletterResponse({
    required this.newsletterStatus,
    required this.message,
    required this.requestOk,
  });

  /// 0 = show Subscribe, 1 = show Unsubscribe (matches API `status`).
  final int newsletterStatus;
  final String message;
  final bool requestOk;

  bool get isSubscribed => newsletterStatus == 1;

  factory NewsletterResponse.fromJson(Map<String, dynamic> json) {
    final dynamic successRaw = json['success'];
    bool requestOk = true;
    if (successRaw != null) {
      requestOk = successRaw == true ||
          successRaw == 1 ||
          successRaw == '1' ||
          (successRaw is String && successRaw.toLowerCase() == 'true');
    }

    dynamic st = json['status'] ?? json['newsletter_status'];
    if (json['data'] is Map<String, dynamic>) {
      final d = json['data'] as Map<String, dynamic>;
      st ??= d['status'] ?? d['newsletter_status'];
    }

    return NewsletterResponse(
      newsletterStatus: _parseNewsletterStatus(st),
      message: (json['message'] ?? json['msg'])?.toString() ?? '',
      requestOk: requestOk,
    );
  }

  static int _parseNewsletterStatus(dynamic st) {
    if (st == null) return 0;
    if (st is int) return st == 1 ? 1 : 0;
    if (st is bool) return st ? 1 : 0;
    if (st is String) {
      final t = st.trim().toLowerCase();
      if (t == '1' || t == 'true') return 1;
      final n = int.tryParse(t);
      if (n == 1) return 1;
    }
    return 0;
  }
}
