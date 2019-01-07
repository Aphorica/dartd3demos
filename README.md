# Dart Angular/D3 Demo
### Rick Berger, Aphorica Inc ( [gbergeraph@gmail.com](mailto:gbergeraph@gmail.com) )
----
This demo contains the set of d3 demos initially ported
by Richard Lincoln in his port of d3 to dart.

See the help panel for a description of each chart and general
behavior.

## Implementation Highlights

* Requires 'aphorica_dartutils' and 'dartd3tooltips' packages. 
  I'm doing more refactoring, and there will be more dependencies 
  as I do this.  Items to be factored out:
  * LightBoxComponent
  * SidePanelComponent
  * PlatformInfo/PlatformResponsivePolicyService

* Charts are dynamically instantiated and loaded. See the
  ChartLoader class for details.

* On desktop, the the plots in aggregate initial view are
  individually active and will support interaction in this
  view (unless interaction is not supported or otherwise
  turns into an issue.)

* The application is mobile capable, and (where interaction
  is supported), will respond to touch events.  On mobile,
  only the lightbox view supports interactions.

* Some of the charts have been heavily modified, mainly to
  allow better interaction on mobile.  See the 'Modified Demo
  Charts' section below for details.

* I'm relying on _ng\_bootstrap_ to provide _Bootstrap_ support, 
  but this is unevenly implemented (no navbar).  I'm trying to
  move over to Google's _Material Design_ paradigm, but that
  isn't completely implemented for _Dart_ yet, either (no navbar...)
  I think ultimately losing _Bootstrap_ is going to be the way to go, 
  though.

* The navbar is homegrown due to the above-mentioned non-support
  in the respective packages. It is minimalistic, at best.

* Beyond the basic _Bootstrap_ responsive support, responsive
  flagging is provided in these two classes: 
    * _PlatformInfo_ -- provides basic platform information,
    * _PlatformResponsivePolicyService_ -- the idea here is
      to provide policy based on the embedded PlatformInfo
      characteristics and the application requirements.  This
      would be derived by the app to provide whatever policy
      info is needed by the app, with perhaps a few default
      configurations.
  These classes are implemented as singletons with a factory 
  constructor, so they can be 'instantiated' almost anywhere.
  This is a somewhat crude implementation, so far.  I expect 
  to flesh this out.  Meanwhile, it's serving well enough to 
  support this demo app.

## Adapting Demo to Work in App

For the most part, the demos aren't operationally modified.
However, there are a few structural modifications to get them
to scale properly in the different display modes.

These are mainly:

* Embed in a class that declares the test as a component,
  mixes in the _ChartController_ mixin class and implements
  _ChartInterface_.  Most of the application-specific
  functionality is implemented in the _ChartController_
  mixin.

* In the _@Component_ section, set the 'selector' to some
  characteristic name, and create a minimal template containing
  a single div.
  The div must have the classes 'chart-cell' and a class
  specific to this chart.

* At the top, call `ChartController.init()`, which sets:
    * the plotsize for further scaling,
    * the full selector to get to the plot for further
      operations and,
    * sets up resize handlers.

* The 'svg' root node is moved out as a member of the class.
  On instantiation, all of the sizing and other attributes
  are removed.  Instead, `ChartController.setupTransform()`
  is called with the 'scale_about' point.  From this point
  on, the _ChartController_ is responsible for sizing and
  scaling the chart.

* `ChartController.setupTransform()` interposes a scaling
  node as a (usually) only child of svg.  All other 'svg'
  references in the plot are replaced with 'scaleNode'
  references, which now becomes their new parent.

* The chart-specific class name, title and help info
  are added to the 'chartList' member in the
  _FetchChartInfoService_ class.  The app uses this
  information to instantiate the plot.

With these mods, the plot should come up in both the main page as
a panel and as a lightbox member.  There may be further tweaks
necessary if the plot uses some more esoteric d3 aspects (and if
you want more differentiated mobile behavior, but for the most
part, it should be working.

## Modified Charts

The following charts have been modified/enhanced to provide
better interaction -- especially in the Mobile vs Desktop
environments.  They illustrate some things that are possible
with further development.  (I'd like to do more, but I need
to get on to other things.)

#### BarChart
Enhanced hover/swipe behavior:

* On desktop, hovering displays the bar value over the
  hovered bar.

* On mobile, an info panel is displayed.  Swiping over
  the bars displays both the bar value over the swiped
  bar and the value information in the info panel.

#### Force
This one has been heavily modified to provide highly
differentiated interaction:

* On both desktop and mobile, the swiped/hovered dot is expanded
  to highlight that it has been touched.
  
* On desktop, hovering over a node displays a tooltip
  with a pointer to the hovered node.  Lifting your
  finger will leave the node highlighted and the
  info in the info panel.

* On mobile, an info panel is displayed.  Swiping
  over a node will display the node's information in
  the info panel.
