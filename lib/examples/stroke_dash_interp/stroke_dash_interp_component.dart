import 'dart:svg' show PathElement;

import 'package:angular2/core.dart';
import 'package:d3/d3.dart';
import 'package:d3/js/transition.dart';

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';

@Component (
  selector: 'stroke-dash-interp',
  template: '<div class="chart-cell stroke-dash-interp-chart"></div>'
)

class StrokeDashInterpComponent extends Object with ChartController
                        implements ChartInterface {

  var line;

  void createChart(String parentSelector) {
    init(960, parentSelector, '.stroke-dash-interp-chart');
    animStarter = lclStartAnim;

    var points = [
      [480, 200],
      [580, 400],
      [680, 100],
      [780, 300],
      [180, 300],
      [280, 100],
      [380, 400]
    ];

    svg = new Selection(selector).append("svg");

    setupTransform(0.0, (plotSize - 500) / 2);

    scaleNode.datum = points;

    line = new Line()
      ..tension = 0 // Catmull–Rom
      ..interpolate = "cardinal-closed";

    scaleNode.append("path")
      ..style["stroke"] = "steelblue"
      ..style["stroke-dasharray"] = "4,4"
      ..attrFn["d"] = line;

  }

  void lclStartAnim() {
    transition(Selection path) {
      path.transition()
        ..duration = 7500
        ..attrTween("stroke-dasharray", tweenDash)
        ..each((elem, _, __) {
          transition(new Selection.elem(elem));
        }, "end");
    }
    transition(scaleNode.append("path")..attrFn["d"] = line); 
  }

  tweenDash(PathElement elem, _, __) {
    var l = elem.getTotalLength();
    var i = interpolateString("0,$l", "$l,$l");
    return (t) => i(t);
  }
}