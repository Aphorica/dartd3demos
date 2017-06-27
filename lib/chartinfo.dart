///
/// Defines the model data
/// 
class ChartInfo {
  static int _id = 0;
  String title, helpTitle, helpText;
  int id;
  Type chartClass;
  ChartInfo({String this.title, Type this.chartClass,
             String this.helpTitle:"", String this.helpText:""}) {
    id = ++_id; }
}