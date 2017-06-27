import 'dart:async';

import 'package:angular2/core.dart';

import 'chartinfo.dart';
import 'chart_interface.dart';

@Component (
  selector: 'chart',
  template: ''
)

/**
 * Dynamically instantiates a specific chart component
 * based on content in the chartInfo.
 */
class ChartLoaderComponent implements AfterViewInit {
  @Input() ChartInfo chartInfo;
  @Input() String parentSelector;
  @Input() int animDelay = 5;
  @Input() bool allowInteraction = true;
  @Input() bool showInfo = false;

  ComponentResolver _resolver;
  ViewContainerRef _viewCtnrRef;
  ChartInterface _chart;
  ChartInterface get chartInstance => _chart;

  ChartLoaderComponent(ComponentResolver this._resolver,
                 ViewContainerRef this._viewCtnrRef);

  void ngAfterViewInit(){
    if (chartInfo == null)
      ; // print('>>> in ChartComponent.ngAfterViewInit, chartInfo is null');
    else
      loadComponent();
  }

  Future loadComponent() async {
    await _resolver.resolveComponent(chartInfo.chartClass).then(
      (ComponentFactory fact) {
        ComponentRef<dynamic> cref = _viewCtnrRef.createComponent(fact);
        _chart = cref.instance;
        _chart.allowInteraction(allowInteraction);
        _chart.showInfo(showInfo);
        _chart.createChart(parentSelector);
        _chart.startAnim(animDelay);
        }
    );
  }
}
