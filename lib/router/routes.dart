import 'package:auto_route/auto_route.dart';
import 'package:final_login/router/routes.gr.dart';


@AutoRouterConfig()
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
    CustomRoute(page: LoginRoute.page, path: '/login',initial: true),
    CustomRoute(page: RegisterRoute.page, path: '/register_page1',),
    CustomRoute(page: ProfileRoute.page, path: '/profile'),
  ];
}