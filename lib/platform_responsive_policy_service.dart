import 'dart:html' as Html;

import 'package:angular2/core.dart';
import 'platform_info.dart';

@Injectable()
class PlatformResponsivePolicyService {
  PlatformInfo _platformInfo;
  static PlatformResponsivePolicyService _policyService;

  PlatformInfo get platformInfo => _platformInfo;
  Html.Navigator _nav = Html.window.navigator;

  bool get _isMobileOS => _nav.platform == "iPad" || _nav.platform == "iPhone" || _nav.product.contains("Android");

  bool get isMobileRes => _platformInfo.width < 992;
  bool get isDesktopRes => !isMobileRes;

  bool get isMobileMenu => isMobileRes;
  bool get isDesktopMenu => !isMobileMenu;

  bool get gridChartsLive => isDesktopRes && !_isMobileOS;

  bool get chartInteractMobile => isMobileRes;
  bool get chartInteractDesktop => isDesktopRes;

  void checkSetForcePortrait() {
  /*
    --> causing a runtime error in server -- may be preventing
        builds.

    if (Html.window == null)
      print ('window is null');
    else if (Html.window.screen == null)
      print ('window.screen is null');
    else if (Html.window.screen.orientation == null)
      print ('window.screen.orientation is null');

    Html.window?.screen?.orientation?.lock("portrait");
  */
  }

  factory PlatformResponsivePolicyService() {
    if (_policyService == null)
      _policyService = new PlatformResponsivePolicyService._internal();
    return _policyService;
  }

  PlatformResponsivePolicyService._internal()
  {
     _platformInfo = new PlatformInfo();
  }
}