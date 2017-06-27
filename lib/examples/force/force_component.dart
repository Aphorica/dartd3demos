import 'dart:math' as Math;
import 'dart:html';

import 'package:angular2/core.dart';
import 'package:d3/d3.dart' as d3;

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';
import 'package:aphorica_dartutils/utilities.dart' as AphUtils;

@Component (
  selector: 'force',
  template: '<div class="chart-cell force-chart"></div>'
)

class ForceChartComponent extends Object with ChartController
                        implements ChartInterface {
  var node;

  static final String instruction = 'Hover/swipe points...';
  void createChart(String parentSelector) {
    init(960, parentSelector, '.force-chart');
    var width = plotSize, height = 500;

    var color = new d3.OrdinalScale.category20();

    var force = new d3.Force()
      ..charge = -120
      ..linkDistance = 100
      ..size = [width, height];

    svg = new d3.Selection(selector).append("svg");
    setupTransform(0, (plotSize - height) / 2);

    d3.json("assets/miserables.json").then((graph) {
      force
        ..nodes = graph['nodes']
        ..links = graph['links']
        ..start();

      var link =
          scaleNode.selectAll(".link").data(graph['links']).enter().append("line")
            ..attr["class"] = "link"
            ..styleFn["stroke-width"] = (d) => Math.sqrt(d['value']);

      node =
          scaleNode.selectAll(".node")
            .data(graph['nodes'])
            .enter()
            .append("circle")
            ..attr["class"] = "node"
            ..attr["r"] = "6"
            ..attrFn["desc"] = ((d) => d['name'])
            ..styleFn["fill"] = ((d) => color(d['group']))
            ..call((_) => force.drag());

      force.onTick.listen((_) {
        link
          ..attrFn["x1"] = ((d) => d['source']['x'])
          ..attrFn["y1"] = ((d) => d['source']['y'])
          ..attrFn["x2"] = ((d) => d['target']['x'])
          ..attrFn["y2"] = ((d) => d['target']['y']);

        node
          ..attrFn["cx"] = ((d) => d['x'])
          ..attrFn["cy"] = ((d) => d['y']);
      });

    if (allowInteractionFlag) {
      if (true) { //responsivePolicy.chartInteractionDesktop) {
        showInfo(true);
                  // force info show on desktop.

        activeElementClass = 'hovered';
        createInfoDisplay(instruction);
        if (responsivePolicy.chartInteractMobile) {
          svg.on('touchstart').listen((_) { handleTouchStart(); });
          svg.on('touchmove').listen((_) { handleHover(); });
          svg.on('touchend').listen((_){ handleTouchEnd(); });
          }
        else if (responsivePolicy.chartInteractDesktop) {  // chartInteractDesktop
          tooltip.registerSelections(scaleNode.selectAll(".node"));
          svg.on('mouseover').listen((_) { handleHover(); });
          }
        }
      }
    }, onError: (err) => throw err);
  }

  void handleTouchStart() {
    d3.event.preventDefault();
    Point touchPoint = AphUtils.getCoordsFromEvent(d3.event);
    if (touchPoint.x != -1) {
      var el = document.elementFromPoint(touchPoint.x, touchPoint.y);
      if (el.localName == 'circle') {
        activeElement = el;
      }

      else {
        activeElement = null;
      }
    }
  }

  void handleTouchEnd() {
    d3.event.preventDefault();
  }

  void handleHover() {
    if (responsivePolicy.chartInteractMobile)
      d3.event.preventDefault();

    Point touchPoint = AphUtils.getCoordsFromEvent(d3.event);
    if (touchPoint.x != -1) {
      node.attr['r'] = '6';
      node.style['stroke'] = 'none';

      var el = document.elementFromPoint(touchPoint.x, touchPoint.y);
      if (el.localName == 'circle') {
        activeElement = el;

        var sel = new d3.Selection.elem(el)
             ..attr['r'] = '12'
             ..style['stroke'] = 'black'
             ..style['stroke-width'] = '3';

        infoText = AphUtils.searchAttrFromD3ParentSelection(sel, 'desc');
      }

      else {
          if (activeElement != null) {
            new d3.Selection.elem(activeElement)
              ..attr['r'] = '6'
              ..style['stroke'] = 'none';

            activeElement = null;
          }

          resetInfo();
        }
     }
  }
}