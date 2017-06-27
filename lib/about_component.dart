import 'dart:html' as Html;

import 'package:angular2/core.dart';
import 'package:markdown/markdown.dart' as MD;

@Component (
  selector: 'about',
  template: '''
<div class="jumbotron about" [innerHtml]="about_content"></div>
''',
)

class AboutComponent implements OnInit {
  String about_content;
  final String prefix = '''
<div class="about-header">README.md</div>
''';

  ngOnInit() {
    Html.HttpRequest.getString("assets/about.md").then((String s) {
      about_content = prefix + MD.markdownToHtml(s);
    });
  }
}