import 'dart:html';

import 'package:angular2/core.dart';
import 'package:angular_components/angular_components.dart';
import 'fetch_chartinfo_service.dart';
import 'chartinfo.dart';
import 'platform_responsive_policy_service.dart';
import 'side_panel_content_interface.dart';

@Component (
  selector: 'help',
  template: '''
  <div class="help">
    <h4>Help</h4>
    <div class="help-content-div">
      <material-expansionpanel-set>
        <material-expansionpanel
          *ngFor="let chartInfo of chartInfoList; let ix=index; "
          [expanded]="openPanelIX == ix"
          [hidden]="chartInfo.title.isEmpty"
          (touchstart)="onTouchStart(\$event)"
          (touchmove)="onTouchMove(\$event)"
          (touchend)="onTouchEnd(\$event)"
          (mouseover)="onMouseOver(\$event)"
          (mouseout)="onMouseOut(\$event)"
          [showSaveCancel]="false" [name]="chartInfo.title">
          <p class="chart-info-title">{{chartInfo.helpTitle}}</p>  
          <div class="chart-info-text" [innerHTML]="chartInfo.helpText"></div>
        </material-expansionpanel>
      </material-expansionpanel-set>
    </div>
  </div>
  ''',
  styles: const ['''
  .help {
    padding: 0;
    font-family: "Pontano Sans", Arial, Helvetica, sans-serif;
    font-weight: 300;
  }
  .help-content-div { position:relative; }
  h4 {text-align:center;font-weight:300;}
  material-expansionpanel-set { border-radius:10px; }
  .chart-info-title { font-weight:normal; 
                      border-bottom:thin solid #000; margin:0 24px;}
  .chart-info-text {color:#black; font-family:verdana,sans-serif;
                    font-size:0.8em; margin: 8px 24px; }
  '''],
  directives: const[MaterialExpansionPanel, MaterialExpansionPanelSet],
  providers: const[PlatformResponsivePolicyService]
)

//
// Help Component fills out the help accordian in the slide-in panel.
// TODO: Figure out how the styling works.
//
// There is a *lot* of Rube-Goldberg code in here to style the
// accordian.  It should respond to a theme, aka 'dark-theme',
// but I haven't been able to get it to work.
//
class HelpComponent implements SidePanelContentInterface, AfterViewInit {
  FetchChartInfoService _chartInfoService;
  PlatformResponsivePolicyService _responseService;
  PlatformResponsivePolicyService get responseService => _responseService;

  List<ChartInfo> chartInfoList;
  int openPanelIX = -1;
  int initialY;

  HelpComponent(FetchChartInfoService this._chartInfoService,
                PlatformResponsivePolicyService this._responseService) {
    chartInfoList = _chartInfoService.getChartsInfoList();
    _chartInfoService.changes.listen((_) {
      openPanelIX = _chartInfoService.selectedItemIX;
      });
  }

  void showingPanel(bool showing)
  {
     if (responseService.isMobileRes && showing)
       querySelector('.help-content-div').style.top = '0';
  }

  //
  // beg set styles
  //
  void ngAfterViewInit() {
    initialY = querySelector('.help-content-div').getBoundingClientRect().top;
    
    List<Element> panels = querySelectorAll('.panel');
    for (Element panelEl in panels) {
      panelEl.style.backgroundColor = '#000';
      panelEl.querySelector('.primary-text').style.color = '#ccc';
      panelEl.querySelector('.glyph-i').style.color = '#ccc';
      }

    List<Element> contentWrappers = querySelectorAll('.content-wrapper');
    for (Element wrapperEL in contentWrappers)
    {
      wrapperEL.style.backgroundColor = '#ccc';
      wrapperEL.style.color = '#000';
      wrapperEL.style.margin = '0';
    }
  }

  bool _isChildOf(Element elChildCandidate)
  {
    Element elParent = elChildCandidate.parent;
    while (elParent != null && elParent != elEntered)
      elParent = elParent.parent;

    return elParent != null;
  }

  Element elEntered;

  void onMouseOver(MouseEvent evt) {
    Element el = evt.target;
    if (elEntered == null && el.localName == 'header')
    {
      el.style.backgroundColor = 'DarkBlue';
      elEntered = el;
    }
  }

  void onMouseOut(MouseEvent evt) {
    Element el= evt.target;
    if (el == elEntered && !(_isChildOf(evt.relatedTarget) ||
                             _isChildOf(el)))
    {
      el.style.backgroundColor = 'black';
      elEntered = null;
    }
  }

  int touchOffset, diff;
  void onTouchStart(TouchEvent evt) {
    evt.preventDefault();
    print("Event: $evt");
    int currentTop = 
       querySelector('.help-content-div').getBoundingClientRect().top;
    print('Touch start: ${evt.touches[0].client.y}, divTop: $currentTop');
    touchOffset = 
       evt.touches[0].client.y - currentTop;
  }

  void onTouchEnd(TouchEvent evt) {
    evt.preventDefault();
    print('Touch done');
  }

  void onTouchMove(TouchEvent evt) {
    evt.preventDefault();
    if (evt != null && evt.touches.isNotEmpty) {
      diff = evt.touches[0].client.y - touchOffset ;
      print('Touch move: $diff');
      querySelector('.help-content-div').style.top = 
        "${diff - initialY}px";
    }
  }
}
