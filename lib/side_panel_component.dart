import 'dart:html';
import 'package:angular2/core.dart';

import 'help_component.dart';
import 'side_panel_content_interface.dart';

@Component(
  selector: 'side-panel',
  template: '''
  <div [class.show-nav]="showingPanel" class="side-panel">
    <i href="#" (click)="closePanel()"
      class="sidepanel-close-icon material-icons md-light md-24">&#xE14C;</i>
    <help #help></help>
  </div>
  ''',
  styleUrls: const ['side_panel_component.css'],
  directives: const[HelpComponent]
)

class SidePanelComponent {
  @ViewChild('help') SidePanelContentInterface contentPanel;
  bool showingPanel = false;
  void showPanel() {
    querySelector('.side-panel').style.zIndex = '9999';
    showingPanel = true; contentPanel.showingPanel(true);
    }
  void closePanel() { showingPanel = false; contentPanel.showingPanel(false); }
}