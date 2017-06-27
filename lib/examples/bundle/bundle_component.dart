import 'dart:html';
import 'dart:js';
import 'dart:math' as Math;

import 'package:angular2/core.dart';

import 'package:d3/d3.dart' as d3;
import 'package:d3/js/d3.dart' as d3js;
import 'package:dartd3_demos/chart_controller.dart';

import 'package:dartd3_demos/chart_interface.dart';
import 'package:aphorica_dartutils/utilities.dart' as AphUtils;

@Component (
  selector: 'bundle',
  template: '<div class="chart-cell bundle-chart"></div>'
)

class BundleComponent extends Object with ChartController
                      implements ChartInterface {

  void createChart(String parentClass) {
    init(960, parentClass, ".bundle-chart");
    var diameter = plotSize;
    num radius = diameter / 2;
    var innerRadius = radius - 120;

    var cluster = new d3.Cluster()
      ..size = [360, innerRadius]
      ..sort = null
      ..value = (d) => d['size'];

    var bundle = new d3.Bundle();

    var line = new d3.RadialLine()
      ..interpolate = "bundle"
      ..tension = .85
      ..radiusFn = ((d) => d['y'])
      ..angleFn = ((d) => d['x'] / 180 * Math.PI);

    svg = new d3.Selection(selector).append("svg");
    setupTransform(radius, radius);

    var link = scaleNode.append("g").selectAll(".link");
    var node = scaleNode.append("g").selectAll(".node");

    d3js.json("assets/readme-flare-imports.json", (error, classes) {
      if (error != null) throw error;

      var hierarchy = packageHierarchy(classes);
      var nodes = cluster.nodes(hierarchy);
      var links = packageImports(nodes);

      link = link.data(bundle(links)).enter().append("path")
        ..eachFn((d) {
          d['source'] = d[0];
          d['target'] = d[d.length - 1];
        })
        ..attr["class"] = "link"
        ..attrFn["d"] = line;

      node = node
          .data(nodes
              .where((n) => n['children'] == null || n['children'].length == 0)
              .toList())
          .enter()
          .append("text")
            ..attr["class"] = "node"
            ..attr["dy"] = ".31em"
            ..attrFn["transform"] = ((d) => "rotate(${d['x'] - 90})"
                "translate(${d['y'] + 8},0)"
                "${d['x'] < 180 ? "" : "rotate(180)"}")
            ..styleFn["text-anchor"] = ((d) => d['x'] < 180 ? "start" : "end")
            ..textFn = ((d) => d['key']);

      if (allowInteractionFlag) {
        activeElementClass = 'node-hover';
        node.on("mouseover").listen((s) => mouseovered(node, link, s.data));
        node.on("mouseout").listen((s) => mouseouted(node, link, s.data));
        node.on("touchmove").listen((_) => d3.event.preventDefault());
        node.on("touchstart").listen((s) => mouseovered(node, link, s.data));
        node.on("touchend").listen((s) => mouseouted(node, link, s.data));
      }
    });
  }

  mouseovered(d3.Selection node, d3.Selection link, d) {
    Point touchPoint = AphUtils.getCoordsFromEvent(d3.event);
    if (touchPoint.x != -1) {
      Element touchNode = document.elementFromPoint(touchPoint.x, touchPoint.y);
      if (touchNode.localName == 'text') {
        activeElement = touchNode;
      }
      else {
        activeElement = null;
      }
    }
      
    node.eachFn((n) {
      n['target'] = n['source'] = false;
    });

    link
      ..classedFn["link--target"] = ((l) {
        if (l['target'] == d) return l['source']['source'] = true;
      })
      ..classedFn["link--source"] = ((l) {
        if (l['source'] == d) return l['target']['target'] = true;
      });
    link
        .filterFn((l) => l['target'] == d || l['source'] == d)
        .each((elem, _, __) => elem.parentNode.append(elem));

    node
      ..classedFn["node--target"] = ((n) => n['target'])
      ..classedFn["node--source"] = ((n) => n['source']);
    
    d3.event.preventDefault();
  }

  mouseouted(d3.Selection node, d3.Selection link, d) {
    activeElement = null;
    link
      ..classed["link--target"] = false
      ..classed["link--source"] = false;

    node
      ..classed["node--target"] = false
      ..classed["node--source"] = false;
    
    d3.event.preventDefault();
  }

  // Lazily construct the package hierarchy from class names.
  packageHierarchy(classes) {
    var map = new JsObject.jsify({});

    find(name, data) {
      var i, node = map[name];
      if (node == null) {
        node = map[name] =
            (data ?? new JsObject.jsify({"name": name, "children": []}));
        if (name.length != 0) {
          i = name.lastIndexOf(".");
          node['parent'] = find(name.substring(0, i < 0 ? 0 : i), null);
          node['parent']['children'].add(node);
          node['key'] = name.substring(i + 1);
        }
      }
      return node;
    }

    classes.forEach((d) => find(d['name'], d));

    return map[""];
  }

  // Return a list of imports for the given array of nodes.
  packageImports(nodes) {
    var map = new JsObject.jsify({});
    var imports = [];

    // Compute a map from name to node.
    nodes.forEach((d) {
      map[d['name']] = d;
    });

    // For each import, construct a link from the source to target node.
    nodes.forEach((d) {
      if (d['imports'] != null) {
        d['imports'].forEach((i) {
          imports.add({"source": map[d['name']], "target": map[i]});
        });
      }
    });

    return imports;
  }
}