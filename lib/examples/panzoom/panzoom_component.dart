import 'dart:math' as Math;
import 'package:angular2/core.dart';
import 'package:d3/d3.dart';

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';

@Component (
  selector: 'panzoom',
  template: '<div class="chart-cell panzoom-chart"></div>'
)

class PanZoomChartComponent extends Object with ChartController
                        implements ChartInterface {

  void createChart(String parentSelector) {
    init(960, parentSelector, '.panzoom-chart');
    var width = plotSize, height = 500;
    var v_margin = (plotSize - height) ~/ 2;
    var margin = new Margin(top: v_margin, right: 20, bottom: 0, left: 40);

    var x = new LinearScale()
      ..domain = [-width / 2, width / 2]
      ..range = [0, width];

    var y = new LinearScale()
      ..domain = [-height / 2, height / 2]
      ..range = [height, 0];

    var xAxis = new Axis()
      ..scale = x
      ..orient = "bottom"
      ..tickSize = -height;

    var yAxis = new Axis()
      ..scale = y
      ..orient = "left"
      ..ticks(5)
      ..tickSize = -width;

    svg = new Selection(selector).append("svg");
    setupTransform(margin.left, margin.top);

    var zoom = new Zoom()
      ..x = x
      ..y = y
      ..scaleExtent = [1, 10]
      ..center = [width / 2, height / 2]
      ..size = [width, height];

    scaleNode.call(zoom);

    scaleNode.append("rect")
      ..attr["width"] = "$width"
      ..attr["height"] = "$height";

    scaleNode.append("g")
      ..attr["class"] = "x axis"
      ..attr["transform"] = "translate(0,$height)"
      ..call(xAxis);

    scaleNode.append("g")
      ..attr["class"] = "y axis"
      ..call(yAxis);

    if (allowInteractionFlag) {
      zoomed() {
        scaleNode.select(".x.axis").call(xAxis);
        scaleNode.select(".y.axis").call(yAxis);
      }
      zoom.onZoom.listen((_) => zoomed());

      new Selection("#reset").on("click").listen((_) {
        new Transition()
          ..duration = 750
          ..tween("zoom", () {
            Interpolate<List<num>> ix =
                new Interpolate<List<num>>(x.domain, [-width / 2, width / 2]);
            Interpolate<List<num>> iy =
                new Interpolate<List<num>>(y.domain, [-height / 2, height / 2]);
            return (t) {
              zoom
                ..x = (x..domain = ix(t))
                ..y = (y..domain = iy(t));
              zoomed();
            };
          });
      });
    }

    List coordinates(List point) {
      var scale = zoom.scale;
      var translate = zoom.translate;
      return [
        (point[0] - translate[0]) / scale,
        (point[1] - translate[1]) / scale
      ];
    }

    List point(List coordinates) {
      var scale = zoom.scale;
      var translate = zoom.translate;
      return [
        coordinates[0] * scale + translate[0],
        coordinates[1] * scale + translate[1]
      ];
    }

    new Selection.all("button[data-zoom]").on("click").listen((s) {
      scaleNode.call(zoom.event); // https://github.com/mbostock/d3/issues/2387

      // Record the coordinates (in data space) of the center (in screen space).
      var center0 = zoom.center;
      var translate0 = zoom.translate;
      var coordinates0 = coordinates(center0);
      zoom.scale *= Math.pow(2, int.parse(s.elem.attributes["data-zoom"]));

      // Translate back to the center.
      var center1 = point(coordinates0);
      zoom.translate = [
        translate0[0] + center0[0] - center1[0],
        translate0[1] + center0[1] - center1[1]
      ];

      scaleNode.transition()
        ..duration = 750
        ..call(zoom.event);
    });
  }
}