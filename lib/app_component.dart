// Copyright (c) 2017, Rick Berger. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:html';

import 'package:angular2/core.dart';
import 'package:ng_bootstrap/ng_bootstrap.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular2/router.dart';

import 'package:dartd3_demos/lightbox_component.dart';
import 'package:dartd3_demos/platform_responsive_policy_service.dart';

import 'package:dartd3_demos/charts_grid_component.dart';
import 'package:dartd3_demos/about_component.dart';

@Component(
  selector: 'my-app',
  templateUrl: 'app_component.html',
  styleUrls: const ['aph_navbar.css'],
  directives: const [BS_DIRECTIVES, LightBoxComponent,ROUTER_DIRECTIVES, 
                     materialDirectives],
  providers: const [PlatformResponsivePolicyService, ROUTER_PROVIDERS, materialProviders]
)

@RouteConfig(const [
  const Route(path: '/', name: 'ChartsGridRoute', component: ChartsGridComponent,
              useAsDefault: true ),
  const Route(path: '/about', name: 'AboutRoute', component:AboutComponent),
])

class AppComponent implements OnInit {
  @ViewChild('lightBox') LightBoxComponent lightBox;

  Router _router;

  PlatformResponsivePolicyService _responsivePolicy;
  PlatformResponsivePolicyService get responsivePolicy => _responsivePolicy;

  AppComponent(PlatformResponsivePolicyService this._responsivePolicy,
               Router this._router);

  void onAboutClicked() {
    _router.navigate(['AboutRoute']);
    
    /*
    lightBox.show = true;
    new Future.delayed(new Duration()).then((_){
      lightBox.setContent(title:'About', componentType:AboutComponent);
    });
    */
  }

  void onHomeClicked() {
    _router.navigate(['ChartsGridRoute']);
  }

  void highlightItem(Event evt) {
  }

  void ngOnInit() {
    responsivePolicy.checkSetForcePortrait();
  }
}
