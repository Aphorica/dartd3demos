import 'dart:html';
import 'dart:async';

import 'package:angular2/core.dart';
import 'package:d3/d3.dart' as d3;
import 'package:quiver/iterables.dart' show max;

import 'package:dartd3_demos/chart_controller.dart';
import 'package:dartd3_demos/chart_interface.dart';
import 'package:aphorica_dartutils/utilities.dart' as AphUtils;

@Component (
  selector: 'barchart',
  template: '<div class="chart-cell barchart"></div>',
)

class BarChartComponent extends Object with ChartController
                        implements ChartInterface{

  static final String instruction = 'Hover/swipe over bar...';

  d3.Selection barTexts;
  void createChart(String parentClass) {
    init(960, parentClass, '.barchart');
     
    final int plotHeight = 500;
    final int v_margin = (plotSize - plotHeight) ~/ 2;

    final d3.Margin margin = new d3.Margin(top: v_margin,
                                           right: 20,
                                           bottom:0,
                                           left: 40);

    var plotWidth = plotSize - margin.left - margin.right;

    var x = new d3.OrdinalScale()
      ..rangeRoundBands([0, plotWidth], 0.1);

    var y = new d3.LinearScale<num>()
      ..range = [plotHeight, 0];

    var xAxis = new d3.Axis()
      ..scale = x
      ..orient = "bottom";

    var yAxis = new d3.Axis()
      ..scale = y
      ..orient = "left"
      ..ticks(10, "%");


    svg = new d3.Selection(selector).append("svg");
    setupTransform(margin.left, margin.top);

    d3.tsv("assets/data.tsv", type).then((List data) {
      x.domain = data.map((d) => d['letter']);
      y.domain = [0, max(data.map((d) => d['frequency']))];

      scaleNode.append("g")
        ..attr["class"] = "x axis"
        ..attr["transform"] = "translate(0,${plotHeight})"
        ..call(xAxis);

      var g = scaleNode.append("g")
        ..attr["class"] = "y axis"
        ..call(yAxis);
      g.append("text")
        ..attr["transform"] = "rotate(-90)"
        ..attr["y"] = "6"
        ..attr["dy"] = ".71em"
        ..style["text-anchor"] = "end"
        ..text = "Frequency";

      var bars = scaleNode.selectAll(".bar")
        .data(data)
        .enter()
        .append("rect")
        ..attrFn["x"] = ((d) {
          return  x(d['letter']);
          })
        ..attrFn["width"] = ((d) {
            return "${x.rangeBand}";
        })
        ..attrFn["y"] = ((d) {
            return y(d['frequency']);
        })
        ..attrFn["height"] = ((d) {
          return plotHeight - y(d['frequency']);
        });
      
      bars.append('text')
        ..textFn = (d) => d['letter'];

      barTexts = scaleNode.selectAll('.bar-text')
        .data(data)
        .enter()
        .append("text")
        ..attr['class'] = 'bar-text'
        ..attrFn["x"] = ((d) {
          num xPos = x(d['letter']);
          return  (xPos + xPos + x.rangeBand) /2;
          })
        ..attrFn["y"] = ((d) {
          return y(d['frequency']);
          })
        ..attr["dy"] = -10.0
        ..textFn = ((d) { return d["frequency"].toStringAsFixed(2); });

      bars.attr['class'] = 'bar';
      if (allowInteractionFlag) {  
        activeElementClass = 'bar-hover';

        createInfoDisplay(instruction);

        svg.on('touchstart').listen((_) { handleTouchStart(); });
        svg.on('mousedown').listen((_) { handleTouchStart(); });

        svg.on('touchend').listen((_) { handleTouchEnd(); });
        svg.on('mouseup').listen((_) { handleTouchEnd(); });

        svg.on('touchmove').listen((_) { handleTouchMove(); });
        svg.on('mousemove').listen((_) { handleTouchMove(); });
      }
    }, onError: (err) => throw err);
  }

  bool isBar(Element el) {
    return el.localName == 'rect' && el.classes.contains('bar');
  }

  void handleTouchStart() {
    Point touchPoint = AphUtils.getCoordsFromEvent(d3.event);
    if (touchPoint.x != -1) {
          Element hit = document.elementFromPoint(touchPoint.x, touchPoint.y);
          if (isBar(hit)) {
              activeElement = hit;
      }
    }
    d3.event.preventDefault();   
  }

  void handleTouchEnd() {
     activeElement = null;
     d3.event.preventDefault();
  }

  void handleTouchMove() {
    Point touchPoint = AphUtils.getCoordsFromEvent(d3.event);
    if (touchPoint.x != -1) {
      Element hit = document.elementFromPoint(touchPoint.x, touchPoint.y);
      new Future.delayed(new Duration()).then((_) {
        if (isBar(hit))
        {
          if (hit != activeElement)
          {
            barTexts.style['visibility'] = 'hidden';

            barTexts.filterFn((d) {
              if (d['letter'] == hit.text) {
                     infoText = "distribution: '${d['letter']}' - "
                                "value: ${d['frequency']}";
                  return true;
                  }
                return false;
                })
              .style['visibility'] = 'visible';
          }

          activeElement = hit;
        }

        else {
          barTexts.style['visibility'] = 'hidden';
          resetInfo();
          activeElement = null;
          }
      });
    }
    d3.event.preventDefault();
  }


  type(d) {
    d['frequency'] = double.parse(d['frequency']);
    return d;
  }
}