import 'package:angular2/core.dart';
import 'package:observable/observable.dart';
//
// beg import supported charts
//
import 'examples/barchart/barchart_component.dart';
import 'examples/bundle/bundle_component.dart';
import 'examples/chord/chord_component.dart';
import 'examples/collapsible/collapsible_component.dart';
import 'examples/draggable/draggable_component.dart';
import 'examples/force/force_component.dart';
import 'examples/map1/map1_component.dart';
import 'examples/panzoom/panzoom_component.dart';
import 'examples/point_along_path/point_along_path_component.dart';
import 'examples/stroke_dash_interp/stroke_dash_interp_component.dart';
//
// end import supported charts
//
import 'empty_chart_component.dart';
import 'chartinfo.dart';

@Injectable()
class FetchChartInfoService extends Object with ChangeNotifier {
  int _ix = -1;

  int get selectedItemIX => _ix;

  void selectItem(int newIx) {
       assert(newIx > -2 && newIx < chartList.length);
       _ix = newIx;
       notifyChange(new ChangeRecord());
       }

  ///
  /// The data model
  /// 
  static List<ChartInfo> chartList = <ChartInfo>[
      new ChartInfo(title:"Bar", chartClass:BarChartComponent,
          helpTitle: "Simple bar Chart",
          helpText: "Bars will highight as you move over them."),
      new ChartInfo(title:"Bundle", chartClass:BundleComponent,
          helpTitle: "Shows Complex Relationships",
          helpText: "Mouse over the labels to see the relationship "
                    "connections."),
      new ChartInfo(title:"Chord", chartClass:ChordComponent,
          helpTitle: "Shows Grouping Relationships",
          helpText: "(No interaction)"),
      new ChartInfo(title:"Collapsible", chartClass:CollapsibleChartComponent,
          helpTitle: "Dynamic Tree Display",
          helpText: "Click on a node to expand its leaf."),
      new ChartInfo(title:"Draggable", chartClass:DraggableChartComponent,
          helpTitle: "Move Points or Groups of Points",
          helpText: "<p>Points must be selected before dragging.</p>"
                    "<p>This "
                    "is best done by dragging a rectangle encompassing "
                    "the points you want to move.</p>"
                    "<p>Points can then be moved with the mouse, or "
                    "using the arrow keys.</p>"),
      new ChartInfo(title:"Force", chartClass:ForceChartComponent,
          helpTitle: "Display a Force Graph",
          helpText: "<p>Each node represents a character in 'Les Miserables'. "
                    "Hovering over a node will display that character's name.</p>"
                    "<p>The forces are calculated from the number of times "
                    "they appear together in a chapter.</p>"
                    "<p>No interaction other than the hover behavior.</p>" ),
      new ChartInfo(title:"Map1", chartClass:Map1ChartComponent,
                    helpTitle:"Simple Map Country Outlines",
                    helpText:"You can click to zoom in or out, or pan "
                             "with the mouse."),
      new ChartInfo(title:"Pan-Zoom", chartClass:PanZoomChartComponent,
                    helpTitle:"Zoom and Pan Plot Area, With Adjusting Axes",
                    helpText: "Click or use gestures to zoom in and out, "
                              "observe the axes labels and lines adjusting."),
      new ChartInfo(title:"Point Along Path", chartClass:PointAlongPathComponent,
                    helpTitle:"Animated Point Following a Path",
                    helpText: "Animation will start briefly in panel, instantly in lightbox."),
      new ChartInfo(title:"Stroke/Dash Interpolation", chartClass:StrokeDashInterpComponent,
                    helpTitle:"Animated line following dashed stroke",
                    helpText: "Animation will start briefly in panel, instantly in lightbox."),
      new ChartInfo(title:"", chartClass:EmptyChartComponent),
      new ChartInfo(title:"", chartClass:EmptyChartComponent)
  ]; 

  List<ChartInfo> getChartsInfoList() => chartList;
}