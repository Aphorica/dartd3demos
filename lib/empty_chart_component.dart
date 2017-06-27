import 'package:angular2/core.dart';

import 'chart_interface.dart';

@Component (
  selector: 'empty',
  template: '<div class="empty-chart"></div>',
  styles: const ['.empty-chart { background-color:#ccc} ']
)

/**
 * Placeholder for when row not completely used -
 * Can't get ng_bootstrap to create hanging column
 * item, so we'll fudge it....
 */
class EmptyChartComponent implements ChartInterface {
  final String elTagName = "#empty-chart";
  
  void createChart(String parent) {}
  void allowFixDivHeight(bool ) {}
  void updateGeometry() {}
  void startAnim(int ) {}
  void allowInteraction(bool) {}
  void showInfo(bool) {}
}