///
/// defines common interface to control charts
/// 
abstract class ChartInterface {

  /// Create the chart under the parentClass (div)
  ///
  void createChart(String parentClass);

  /// whether to allow the chart to fix the div heights
  /// on its own (interferes if manually laying out, like
  /// in the lightbox.)
  /// 
  void allowFixDivHeight(bool allow);

  /// update the geometry.  Only useful if allowFixDivHeight is
  /// disabled
  /// 
  void updateGeometry();

  /// allow animations
  /// 
  void startAnim(int delay);

  /// allowInteraction
  /// 
  void allowInteraction(bool allow);

  /// void showInfo on hover -- either box (mobile)
  /// or tooltip (desktop)
  /// 
  void showInfo(bool show);
}