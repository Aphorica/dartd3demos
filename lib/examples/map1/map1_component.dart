import 'dart:math' as Math;

import 'package:angular2/core.dart';
import 'package:d3/js/d3.dart' as d3;
import 'package:d3/js/behavior.dart' as behavior;

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';

@Component (
  selector: 'map1',
  template: '<div class="chart-cell map1-chart"></div>'
)

class Map1ChartComponent extends Object with ChartController
                        implements ChartInterface {

  void createChart(String parentSelector) {
    init (960, parentSelector, '.map1-chart', true);
    var width = plotSize, height = plotSize;

    var projection = d3.mercator().translate([width / 2, height / 2])
        .scale((width - 1) / 2 / Math.PI);

    var zoom = behavior.zoom().scaleExtent([1, 8]);

    var path = d3.path().projection(projection);

    svg = d3.select(selector).append("svg");
    setupTransform(0, 0);

    var g = scaleNode.append("g");

    scaleNode
        .append("rect")
        .attr("class", "overlay")
        .attr("width", width)
        .attr("height", height);

    scaleNode.call(zoom).call(zoom.event);

    g.append("path").datum({"type": "Sphere"})
        .attr("class", "sphere")
        .attr("d", path);

    d3.json("assets/ne_110m_admin_0_countries_lakes.geojson", (error, world) {
      if (error != null) throw error;

      g.append("path").datum(world).attr("class", "land").attr("d", path);
    });

    d3.json("assets/ne_110m_admin_0_boundary_lines_land.geojson", (error, world) {
      if (error != null) throw error;
      g.append("path").datum(world).attr("class", "boundary").attr("d", path);
    });

    if (allowInteractionFlag) {
      zoom.on("zoom", () {
        var translate = d3.event['translate'];
        g.attr("transform",
            "translate(${translate[0]},${translate[1]})scale(${d3.event['scale']})");
      });
    }
  }
}