import 'dart:html';
import 'dart:math' as Math;
import 'dart:async';

import 'package:dartd3_demos/platform_responsive_policy_service.dart';
import 'package:dartd3tooltips/d3_toolip.dart';

/// Mixin class used to consolidate and separate scaling operations 
/// from the chart classes.
typedef void AnimStarter ();

class InfoBox {
  final String _resetString;

  var _infoText;
  void set infoText(String text) { _infoText.text = text; }

  InfoBox(var svg, String this._resetString, 
          Rectangle geom, Point textOffset) {

    var infoPanel = svg.append('g')
      ..attr['transform'] = 'translate(5, 5)';

    infoPanel
      .append('rect')
        ..attr['x'] = geom.left
        ..attr['y'] = geom.top 
        ..attr['rx'] = 5
        ..attr['ry'] = 5
        ..attr['width'] = geom.width
        ..attr['height'] = geom.height
        ..attr['class'] = 'info-box';

    _infoText = infoPanel.append('text')
      ..attr['x'] = 12
      ..attr['y'] = 25
      ..attr['class'] = 'info-box-content'
      ..text = _resetString;

  }

  void reset() { _infoText.text = _resetString; }
}

abstract class ChartController {
/// used to manage hover behavior
/// 
   PlatformResponsivePolicyService _responsivePolicy;
   PlatformResponsivePolicyService get responsivePolicy => _responsivePolicy;

   D3Tooltip _tooltip;
   D3Tooltip get tooltip => _tooltip;

   String _activeElementClass;
   void set activeElementClass(String s) { _activeElementClass = s; }
   var _activeElement;
   dynamic get activeElement => _activeElement;
   void set activeElement(el) {
     if (el != _activeElement) {
        if (_activeElement != null) {
            _activeElement.classes.remove(_activeElementClass);
            _activeElement = null;
          }
          else {
            _activeElement = el;
            if (_activeElement != null) {
              _activeElement.classes.add(_activeElementClass);
            }
          }
     }
  }
 
  AnimStarter animStarter;
  void startAnim(int delaySecs) {
    if (animStarter != null) {
      new Future.delayed(new Duration(seconds:delaySecs)).then((_){
        animStarter();
      });
    }
  }

  InfoBox _infoBox;

  void set infoText(String text) { _infoBox?.infoText = text; }
  void resetInfo() { _infoBox?.reset(); }

  /// allow the info box to show.
  bool __showInfoBox;
  bool get _showInfoBox => __showInfoBox && allowInteractionFlag;
  bool __showTooltip;
  bool get _showTooltip => __showTooltip;
  void showInfo(bool flag) { 
    _responsivePolicy = new PlatformResponsivePolicyService();
    __showTooltip = __showInfoBox = false;
    if (_responsivePolicy.chartInteractDesktop) {
      __showTooltip = flag;
    }
    else {
      __showInfoBox = flag;
    }
  }

  /// turned off on mobile main page
  bool allowInteractionFlag = false;
  void allowInteraction(bool allow) { allowInteractionFlag = allow; }

  /// assign this value in the associated class constructor
  String _selector;
  String get selector =>_selector;

  /// assign this if using D3/js (in the chart operant code)
  bool _isD3js = false;

  /// disable/enable auto height fixup
  bool allowFixDivHeightFlag = true;
  void allowFixDivHeight(allow) { allowFixDivHeightFlag = allow; }

  
  /// These are the nodes we hang on to and change attributes on.
  /// Note they are 'vars' intentionally.  Depending on whether the
  /// chart uses D3 Dart or D3 JS they will be different types.
  var svg, preScaleNode, scaleNode;
  int _plotSize;
  int get plotSize => _plotSize;

  /// This is the transform pivot point
  Math.Point transformAbout;

  void init(int plotSizeIn, String parentSelectorIn, String chartSelectorIn,
            [bool isD3js=false]) {
    _plotSize = plotSizeIn;
    _selector = '$parentSelectorIn $chartSelectorIn';
    _isD3js = isD3js;
    fixDivHeight();
    setupSizeListener();
  }

  double get scale {
    Element el = querySelector(selector);
    if (el != null)
      return el.clientWidth / plotSize;

    return 1.0;
  }

  void updateGeometry() {
    _setXFormAtts();
  }

  void _setXFormAtts() {
    var newSize = (plotSize * scale).toInt();
    String translateStr = "translate(${scale * transformAbout.x}, "
                                "${scale * transformAbout.y})";
    String scaleStr = "scale($scale, $scale)";                             
                                
    if (_isD3js) {
        // different form for assigning attributes to these
        // types
      svg.attr('width', newSize);
      svg.attr('height', newSize);
      preScaleNode.attr("transform", translateStr);
      scaleNode.attr("transform", scaleStr);    
    }
    
    else {
        // new form for dart types
      svg.attr['width'] = '${newSize}';
      svg.attr['height'] = '${newSize}';
      preScaleNode.attr["transform"] = translateStr;
      scaleNode.attr["transform"] = scaleStr;    
    }
  }

  void setupSizeListener() {
    // set an event handler for window resizes
    window.onResize.listen((_) {
       fixDivHeight();
       _setXFormAtts();
       });
  }

  /// Insures the frame is square.
  void fixDivHeight()
  {
    if (allowFixDivHeightFlag) {
      Element el = querySelector(selector);
      if (el != null)
        el.style.height = "${el.clientWidth}px";
    }
  }

  /// Do this after the svg has been created and before any subsequent
  /// nodes have been created.  All subsequent nodes must be children
  /// of scaleNode.
  void setupTransform(num transformAbout_x, num transformAbout_y) {
    transformAbout = new Point(transformAbout_x, transformAbout_y);
    preScaleNode = svg.append("g");
    scaleNode = preScaleNode.append("g");
              // TODO: consolidate transforms to single node, if
              //       possible.

    _setXFormAtts();
  }

  /// Create an info box for displaying hover content, etc.
  /// 
  void createInfoDisplay (String initialText) {
    if (_showInfoBox) {
      new Future.delayed(new Duration()).then((_) {
              // have to do this because IOS doesn't get its sizing
              // together until the next round in the event loop...

      Rectangle infoRect =
        new Rectangle(5, 5,
            Math.min(300, querySelector(selector).offsetWidth - 12), 35);

        Point textOffset = new Point(12, 25);

        _infoBox = new InfoBox(svg, initialText, infoRect, textOffset);
      });
    }
    else if (_showTooltip) {
      _tooltip = new D3Tooltip(svg, standoff: new Point(20, 20));
    }
  }
}