import 'dart:svg' show PathElement;

import 'package:angular2/core.dart';
import 'package:d3/d3.dart';

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';

@Component (
  selector: 'point-along-path',
  template: '<div class="chart-cell point-along-path-chart"></div>'
)

class PointAlongPathComponent extends Object with ChartController
                        implements ChartInterface {

  var circle, path;

  void createChart(String parentSelector) {
    init(960, parentSelector, '.point-along-path-chart');
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
    var xOffset = 0, yOffset = (plotSize - 500) / 2;

    setupTransform(xOffset, yOffset);

    path = scaleNode.append("path")
      ..data([points])
      ..attrFn["d"] = (new Line()
        ..tension = 0 // Catmull–Rom
        ..interpolate = "cardinal-closed");

    scaleNode.selectAll(".point").data(points).enter().append("circle")
      ..attr["r"] = '4'
      ..attrFn["transform"] = (d) => "translate(${d[0]},${d[1]})";

    circle = scaleNode.append("circle")
      ..attr["r"] = '13'
      ..attr["transform"] = "translate(${points[0][0]},${points[0][1]})";
  }

  void lclStartAnim() {
          transition(selector) {
          circle.transition()
            ..duration = 7500
            ..attrTween("transform", translateAlong(path.node()))
            ..each(transition, "end");
          }

          transition(selector);
  }

  /// Returns an attrTween for translating along the specified path element.
  translateAlong(PathElement path) {
    var l = path.getTotalLength();
    return (d, i, a) {
      return (t) {
        var p = path.getPointAtLength(t * l);
        return "translate(${p.x},${p.y})";
      };
    };
  }
}