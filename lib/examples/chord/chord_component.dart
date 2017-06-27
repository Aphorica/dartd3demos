import 'dart:js';
import 'dart:math' as Math;

import 'package:angular2/core.dart';
import 'package:d3/d3.dart';

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';

@Component (
  selector: 'chord',
  template: '<div class="chart-cell chord-chart"></div>'
)

class ChordComponent extends Object with ChartController
                     implements ChartInterface {


void createChart(String parentSelector) {
    init(960, parentSelector, '.chord-chart');
    var offset = 70;
    var outerRadius = (plotSize / 2) - offset;
    var innerRadius = outerRadius - 130;

    var fill = new OrdinalScale.category20c();

    var chord = new ChordLayout()
      ..padding = 0.04
      ..sortSubgroups = descending
      ..sortChords = descending;

    var arc = new Arc()
      ..innerRadius = innerRadius
      ..outerRadius = innerRadius + 20;

    svg = new Selection(selector).append("svg");
    setupTransform(outerRadius + offset, outerRadius + offset);

    json("assets/readme.json").then((imports) {
      var indexByName = <String, int>{};
      var nameByIndex = <int, String>{};
      var matrix = [], n = 0;

      // Returns the Flare package name for the given class name.
      String name(String name) {
        return name.substring(0, name.lastIndexOf(".")).substring(6);
      }

      // Compute a unique index for each package name.
      (imports as List).forEach((d) {
        if (!indexByName.containsKey(d = name(d['name']))) {
          nameByIndex[n] = d;
          indexByName[d] = n++;
        }
      });

      // Construct a square matrix counting package imports.
      imports.forEach((JsObject d) {
        var source = indexByName[name(d['name'])];
        List row;
        if (source >= matrix.length) {
          matrix.add(row = new List.generate(n, (_) => 0));
        } else {
          row = matrix[source];
        }
        d['imports'].forEach((String d) {
          row[indexByName[name(d)]]++;
        });
      });

      chord.matrix = matrix;

      var g = scaleNode.selectAll(".group").setDataFn(chord.groups).enter().append("g")
        ..attr["class"] = "group";

      g.append("path")
        ..styleFn["stroke"] = ((JsObject d) => fill(d['index']))
        ..styleFn["fill"] = ((JsObject d) => fill(d['index']))
        ..attrFn["d"] = arc;

      g.append("text")
        ..eachFn((d) {
          d['angle'] = (d['startAngle'] + d['endAngle']) / 2;
        })
        ..attr["dy"] = ".35em"
        ..attrFn["transform"] = ((d) {
          return "rotate(${d['angle'] * 180 / Math.PI - 90})"
              "translate(${innerRadius + 26})"
              "${d['angle'] > Math.PI ? "rotate(180)" : ""}";
        })
        ..styleFn["text-anchor"] = ((d) => d['angle'] > Math.PI ? "end" : null)
        ..textFn = ((d) => nameByIndex[d['index']]);

      scaleNode.selectAll(".chord").setDataFn(chord.chords).enter().append("path")
        ..attr["class"] = "chord"
        ..styleFn["stroke"] = ((JsObject d) =>
            new Rgb.parse(fill(d['source']['index'])).darker())
        ..styleFn["fill"] = ((JsObject d) => fill(d['source']['index']))
        ..attrFn["d"] = (new Chord()..radius = innerRadius);
    }, onError: (err) => throw err);
  }
}

///
/// 
int Descending(dynamic a, dynamic b) => b < a ? -1 : b > a ? 1 : b >= a ? 0 : -1; 
var descending = Descending;
