import 'package:astrokavach/api/astrologer/privacy_policy_api.dart';
import 'package:astrokavach/custom_widgets/custom_appbar.dart';
import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;

Map<String, String>? _policyHtmlCustomStyles(dom.Element element) {
  if (element.localName == 'p') {
    return {
      'margin-top': '0',
      'margin-bottom': '8px',
      'line-height': '1.5',
    };
  }
  return null;
}

class _PolicyBlockSpan {
  _PolicyBlockSpan.list(this.start, this.end, this.listInner) : pBody = null;
  _PolicyBlockSpan.pnum(this.start, this.end, this.pBody) : listInner = null;

  final int start;
  final int end;
  final String? listInner;
  final String? pBody;
}

List<_PolicyBlockSpan> _policyCollectSpans(String html) {
  final reList = RegExp(
    r'(?:<ol[^>]*>([\s\S]*?)</ol>)|(?:<ul[^>]*>([\s\S]*?)</ul>)',
    caseSensitive: false,
  );
  final reP = RegExp(r'<p>\s*\d+\.\s*([\s\S]*?)</p>', caseSensitive: false);
  final spans = <_PolicyBlockSpan>[];
  for (final m in reList.allMatches(html)) {
    final inner = m.group(1) ?? m.group(2)!;
    spans.add(_PolicyBlockSpan.list(m.start, m.end, inner));
  }
  for (final m in reP.allMatches(html)) {
    spans.add(_PolicyBlockSpan.pnum(m.start, m.end, m.group(1)!));
  }
  spans.sort((a, b) => a.start.compareTo(b.start));
  return spans;
}

List<Widget> _policyBuildWidgets(String html, TextStyle textStyle) {
  final liRe = RegExp(r'<li[^>]*>([\s\S]*?)</li>', caseSensitive: false);
  final spans = _policyCollectSpans(html);
  if (spans.isEmpty) {
    return [
      HtmlWidget(
        html,
        textStyle: textStyle,
        customStylesBuilder: _policyHtmlCustomStyles,
      ),
    ];
  }

  final out = <Widget>[];
  var cursor = 0;
  for (final sp in spans) {
    if (sp.start > cursor) {
      final gap = html.substring(cursor, sp.start).trim();
      if (gap.isNotEmpty) {
        out.add(
          HtmlWidget(
            gap,
            textStyle: textStyle,
            customStylesBuilder: _policyHtmlCustomStyles,
          ),
        );
      }
    }
    if (sp.listInner != null) {
      for (final li in liRe.allMatches(sp.listInner!)) {
        out.add(
          _PolicyBulletRow(
            bodyHtml: li.group(1)!.trim(),
            textStyle: textStyle,
          ),
        );
      }
    } else if (sp.pBody != null) {
      out.add(
        _PolicyBulletRow(
          bodyHtml: sp.pBody!.trim(),
          textStyle: textStyle,
        ),
      );
    }
    cursor = sp.end;
  }
  if (cursor < html.length) {
    final tail = html.substring(cursor).trim();
    if (tail.isNotEmpty) {
      out.add(
        HtmlWidget(
          tail,
          textStyle: textStyle,
          customStylesBuilder: _policyHtmlCustomStyles,
        ),
      );
    }
  }
  return out;
}

class _PolicyBulletRow extends StatelessWidget {
  const _PolicyBulletRow({
    required this.bodyHtml,
    required this.textStyle,
  });

  final String bodyHtml;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '\u2022',
              textAlign: TextAlign.center,
              style: textStyle.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: HtmlWidget(
              bodyHtml,
              textStyle: textStyle,
              customStylesBuilder: _policyHtmlCustomStyles,
            ),
          ),
        ],
      ),
    );
  }
}

class AstrologerPrivacyPolicyScreen extends StatefulWidget {
  const AstrologerPrivacyPolicyScreen({super.key});

  @override
  State<AstrologerPrivacyPolicyScreen> createState() =>
      _AstrologerPrivacyPolicyScreenState();
}

class _AstrologerPrivacyPolicyScreenState
    extends State<AstrologerPrivacyPolicyScreen> {
  final PrivacyPolicyApiService _api = PrivacyPolicyApiService();
  String? _html;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _api.fetchPrivacyPolicy();
    final first = res?.data?.isNotEmpty == true ? res!.data!.first : null;
    if (!mounted) return;
    setState(() {
      _html = first?.content;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: Colors.black87,
      fontWeight: FontWeight.w400,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        backgroundColor: CustomStyles.whiteColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        automaticallyImplyLeading: false,
        title: 'drawer_privacy_policy'.tr,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        minimum: const EdgeInsets.only(bottom: 12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                child: LayoutBuilder(
                  builder: (context, c) {
                    return SizedBox(
                      width: c.maxWidth,
                      child: _html == null || _html!.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 48),
                              child: Center(
                                child: Text(
                                  'No content',
                                  style:
                                      TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _policyBuildWidgets(
                                _html!,
                                textStyle,
                              ),
                            ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
