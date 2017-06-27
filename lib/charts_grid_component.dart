// Copyright (c) 2017, Rick Berger. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:async';
import 'dart:html' as Html;

import 'package:angular2/core.dart';
import 'package:ng_bootstrap/ng_bootstrap.dart';
import 'package:angular_components/angular_components.dart';
import 'package:observable/observable.dart';
import 'package:aphorica_dartutils/utilities.dart' as AphUtils;

import 'chart_loader_component.dart';
import 'fetch_chartinfo_service.dart';
import 'chartinfo.dart';
import 'side_panel_component.dart';
import 'lightbox_component.dart';
import 'platform_responsive_policy_service.dart';

@Component (
  selector: 'charts-grid',
  templateUrl: 'charts_grid_component.html',
  directives: const [ChartLoaderComponent, SidePanelComponent, BS_DIRECTIVES, materialDirectives],
  providers: const [FetchChartInfoService, PlatformResponsivePolicyService, materialProviders]  
)

class ChartsGridComponent implements OnInit, AfterViewInit {
  @ViewChild('sidePanel') var sidePanel;

  PlatformResponsivePolicyService _responsivePolicy;
  PlatformResponsivePolicyService get responsivePolicy => _responsivePolicy;

  int _hoveredIX = -1;
  bool _touchStarted = false;

  int get lastChartIX {
     for (int lastIX = chartList.length - 1; lastIX >= 0; lastIX--)
       if (chartList[lastIX].title.isNotEmpty) {
          return lastIX;
     }

     return -1;
  }

  void onChartHelpBtnMouseOver(int ix) { _hoveredIX = ix; }
  void onChartHelpBtnMouseOut() { _hoveredIX = -1; }
  final String chartHelpBtn_Normal = "",
               chartHelpBtn_Hover = "";
  String chartHelpBtn(int ix) => ix == _hoveredIX? 'help' : 'help_outline';

  List<ChartInfo> chartList;
  FetchChartInfoService _chartInfoService;

  ChartsGridComponent(FetchChartInfoService this._chartInfoService, 
               PlatformResponsivePolicyService this._responsivePolicy)
  {
    chartList = _chartInfoService.getChartsInfoList();
  }

  int currYPos;

  @override
  void ngOnInit() {
      LightBoxComponent.instance.changes.listen((List<ChangeRecord> crList) {
        MapChangeRecord changeRec = crList[0];
        String key = changeRec.key;
        if (key == 'closeRequest') {
          AphUtils.unlockBody();
          LightBoxComponent.instance.show = false;
          if (!responsivePolicy.gridChartsLive) {
            setLightboxActivationOnCharts(true);
          }
        }
        
        else if (key == 'help') {
          ChartInfo info = changeRec.newValue;
          showHelp(info.id - 1);
        }
    }); 
  }

  @override
  void ngAfterViewInit() {
    if (!responsivePolicy.gridChartsLive) {
      setLightboxActivationOnCharts(true);
    }
  }

  void setLightboxActivationOnCharts(bool add) {
    List<Html.Element> chartBoxes = Html.querySelectorAll('.grid-ctnr .example-grid .row .chart-box');
    for (int ix = 0; ix < chartBoxes.length; ix++) {
      if (add) {
        print('Adding lightbox click');
        chartBoxes[ix].addEventListener('touchstart', onTouchStart);
        chartBoxes[ix].addEventListener('touchmove', onTouchMove);
        chartBoxes[ix].addEventListener('touchend', onTouchEnd);
      } else {
        print('Removing lightbox click');
        chartBoxes[ix].removeEventListener('touchstart', onTouchStart);
        chartBoxes[ix].removeEventListener('touchmove', onTouchMove);
        chartBoxes[ix].removeEventListener('touchend', onTouchEnd);       
      }
    }
  }

  void onTouchStart(_) {
    print('Lightbox touch start');
    _touchStarted = true;
  }

  void onTouchMove(_) {
    print('Lightbox touch moved');
    _touchStarted = false;
  }

  void onTouchEnd(Html.Event evt) {
    print('Lightbox touch ended');
    if (_touchStarted) {
      print('got valid launch lightbox action');
      Html.Element el = evt.currentTarget;
      int ix = Html.querySelectorAll('.grid-ctnr .example-grid .row .chart-box').indexOf(el);
      _touchStarted = false;
      evt.preventDefault();

      new Future.delayed(new Duration()).then((_) {
        print ('launching lighbox with chart: $ix');
        launchChartLightbox(ix);
        setLightboxActivationOnCharts(false);
      });
    }
  }

  void launchChartLightbox(int ix) {
    AphUtils.lockBody();
    LightBoxComponent.instance.show = true;
    new Future.delayed(new Duration()).then((_) {
      ChartInfo info = chartList[ix];
      LightBoxComponent.instance.childData = info;
      LightBoxComponent.instance.setContent(title:info.title, componentType: info.chartClass,
                          htmlPreface:info.helpTitle, htmlText:info.helpText);
      });
  }

  void showHelp(int ix) {
    print ('in showHelp, selected: $ix');
    if (_chartInfoService.selectedItemIX == ix) {
      sidePanel.closePanel();
      _chartInfoService.selectItem(-1);
    } else {
      _chartInfoService.selectItem(ix);
      sidePanel.showPanel();
    }
  }
}