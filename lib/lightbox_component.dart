import 'dart:html';
import 'dart:async';

import 'package:angular2/core.dart';
import 'package:observable/observable.dart';
import 'package:angular_components/angular_components.dart';

import 'chart_loader_component.dart';
import 'platform_responsive_policy_service.dart';

@Component (
  selector: 'light-box',
  template: '''
  <div (keypress)="onKeyPress(\$event)" class="light-box">
      <i (click)="requestClose()"
          class="lb-close-icon material-icons md-light md-36">
          <glyph icon="clear"></glyph></i>
      <h1 *ngIf="responsivePolicy.isDesktopRes" class="title">{{title}}</h1>
      <h4 *ngIf="responsivePolicy.isMobileRes" class="title">{{title}}</h4>
      <div class="content-chart-box">
        <chart #chartLoader [parentSelector]="'.light-box .content-chart-box'"></chart>
      </div>
      <i *ngIf="responsivePolicy.isMobileRes"
         class="lb-help-icon material-icons md-light md-36"
         (click)="onHelpClicked()">
         <glyph icon="help_outline"></glyph></i>
      <div *ngIf="responsivePolicy.isDesktopRes" class="lb-text-content">
        <p *ngIf="htmlPreface == null" [innerHTML]="htmlText"></p>
        <table *ngIf="htmlPreface != null"><tr align="top" >
          <th>{{htmlPreface}}:</th><td>{{clearText}}</td>
        </tr></table>
      </div>
  </div>
  ''',
  styles: const ['''
  @keyframes lb-fade {
    from { opacity: 0.0; }
    to {opacity: 1.0; }
  }
  .light-box { width:100%; height:100%;
               position:fixed;
               top:0; left:0;
               background-color:rgba(0, 0, 0, 0.8);
               font-family:"Pontano Sans", Arial, sans-serif;
               text-align:center;
               border: 2px solid white; 
               padding:20px;
               opacity: 0.0;
               }

  .lightbox-fadein {
     opacity: 1.0;
     animation-name: lb-fade;
     animation-duration:1s;
  }
  .lb-help-icon,
  .lb-close-icon { cursor:pointer; position:absolute; color:#ccc; }
  h1,h4 { position:absolute; width:50%;}
  h1 { font-weight:100; }
  h4 { font-size: 1.0rem; }
  h1,h4,.lb-text-content { background-color:black; border-radius:10px;
                         color:#ccc; padding:0.5em 0;
                         border:3px solid #666;}
  .content-chart-box { position:absolute; 
                 background-color:white; border:2px solid #ccc; }
  .lb-text-content { position:absolute; width:75%; text-align:center; }
  .lb-text-content table { width:90%; margin-left:auto; margin-right:auto; }
  .lb-text-content table th { width: 25%; border-right:thin solid #ccc; }
  '''],
  directives: const [ChartLoaderComponent, materialDirectives],
  providers: const [PlatformResponsivePolicyService, materialProviders]
)

class LightBoxComponent extends Object with ChangeNotifier 
                        implements AfterViewInit {
  @Input() var childData;
  @ViewChild('chartLoader') ChartLoaderComponent chartLoader;

  static LightBoxComponent _instance;
  static get instance => _instance;

  bool show = false;

  PlatformResponsivePolicyService _responsivePolicy;
  PlatformResponsivePolicyService get responsivePolicy => _responsivePolicy;

  LightBoxComponent(PlatformResponsivePolicyService this._responsivePolicy) {
    _instance = this;
  }

  void requestClose() {
    Element chartCell = querySelector('.content-chart-box .chart-cell');
    if (chartCell != null)
      chartCell.remove();
    notifyChange(new MapChangeRecord('closeRequest', '', ''));
    }

  void onKeyPress(KeyEvent evt) {
    print('got keydown event');
    if (evt.keyCode == KeyCode.ESC)
      requestClose();
  }

  void onHelpClicked() {
    notifyChange(new MapChangeRecord('help', null, childData));
  }

  void adjustContentCtnrLayout() {
    if (chartLoader.chartInstance == null)
      return;
            // this will be true if the panel is not opened...

        Element closeIcon = querySelector('.lb-close-icon');
        Element chartBoxEL = querySelector('.light-box .content-chart-box');
        Element titleEL = querySelector('.light-box .title');
        Rectangle titleRect = titleEL.getBoundingClientRect();
        Rectangle closeIconRect = closeIcon.getBoundingClientRect();

        Element textEL;
        Rectangle textRect;
        Element helpEL;

        if (responsivePolicy.isDesktopRes) {
          textEL = querySelector('.light-box .lb-text-content');
          textRect = textEL.getBoundingClientRect();
        }

        else {
          textRect = new Rectangle(0, 0, 0, 0);
          helpEL = querySelector('.lb-help-icon');
        }

        int boxVMargin = 12;
        int chartBoxBorderWidthx2 = 4; 

        int chartBoxSize;

        int contentMargin = 20,
            contentWidth = window.innerWidth - contentMargin - contentMargin;


        int titleTop = contentMargin,
            titleLeft = (window.innerWidth - titleRect.width) ~/ 2,
            titleBottom = contentMargin + titleTop + titleRect.height,
            textTop = window.innerHeight - textRect.height - contentMargin,
            textLeft = (window.innerWidth - textRect.width) ~/ 2,
            residualHeight = textTop - boxVMargin - boxVMargin - titleBottom,
            closeIconTop = 0,
            closeIconLeft = window.innerWidth - closeIconRect.width - 5,
            chartBoxTop, chartBoxLeft;

      
        if (residualHeight > contentWidth) {
          chartBoxSize = contentWidth - chartBoxBorderWidthx2;
          chartBoxTop = titleBottom + ((residualHeight - chartBoxSize) ~/2);
          chartBoxLeft = contentMargin;
        } else {
          chartBoxSize = residualHeight - chartBoxBorderWidthx2;
          chartBoxTop = titleBottom;
          chartBoxLeft = (((window.innerWidth - (contentMargin * 2)) - chartBoxSize) ~/ 2)
                          + contentMargin;
        }

        closeIcon.style.top = '${closeIconTop}px';
        closeIcon.style.left = '${closeIconLeft}px';

        titleEL.style.top = '${titleTop}px';
        titleEL.style.left = '${titleLeft}px';

        if (textEL != null) {
          textEL.style.top = '${textTop}px';
          textEL.style.left = '${textLeft}px';
        }

        if (helpEL != null) {
          helpEL.style.top = '${chartBoxTop + chartBoxSize + 6}px';
          helpEL.style.left = '${chartBoxLeft}px';
        }

        chartBoxEL.style.height = '${chartBoxSize}px';
        chartBoxEL.style.width = '${chartBoxSize}px';
        chartBoxEL.style.top = '${chartBoxTop}px';
        chartBoxEL.style.left = '${chartBoxLeft}px';
        chartLoader.chartInstance.updateGeometry();
  }

  void ngAfterViewInit() {
    window.onResize.listen((_) {
      new Future.delayed(new Duration()).then((_) {
              // wait for texts to size
        adjustContentCtnrLayout(); });
      });
  }

  String _title = "Here's a Title";
  String get title => _title;
  String _htmlText = "<p>Some Text will go here, right?</p>";
  String get htmlText => _htmlText;
  String _htmlPreface;
  String get clearText => htmlText.replaceAll(
                          new RegExp('<p>'), '').replaceAll(
                          new RegExp('</p>'), ' ');

  String get htmlPreface => _htmlPreface;

  void setContent({String title, Type componentType,
                   String htmlPreface, String htmlText}) {
/*                     
    int current{os = querySelector('body').offsetTop;
    querySelector('.light-box').style.top = '-$currentScrollPos';
//      '${currentScrollPos}px';
*/
    chartLoader.chartInfo = childData;
    chartLoader.animDelay = 1;
    chartLoader.allowInteraction = true;
    chartLoader.showInfo = true;
    chartLoader.loadComponent().then((_) {
      chartLoader.chartInstance.allowFixDivHeight(false);
      new Future.delayed(new Duration()).then((_) {
        adjustContentCtnrLayout();
        querySelector('.light-box').classes.add('lightbox-fadein');
        });
      });

    _title = title;
    _htmlPreface = htmlPreface;
    _htmlText = htmlText;
  }
}
