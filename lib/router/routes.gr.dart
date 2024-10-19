import 'package:auto_route/auto_route.dart' as _i7;
import 'package:final_login/screen/login.dart' as _i1;
import 'package:final_login/screen/register_page1.dart' as _i2;
import 'package:final_login/screen/profile.dart' as _i3;

abstract class $AppRouter extends _i7.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i7.PageFactory> pagesMap = {
    LoginRoute.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i1.LoginPage(),
      );
    },
    RegisterRoute.name: (routeData) {
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.RegisterPage1(),
      );
    },
    ProfileRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileRouteArgs>();
      return _i7.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i3.ProfilePage(userId: args.userId),
      );
    },
  };
}

/// generated route for
/// [_i1.LoginPage]
class LoginRoute extends _i7.PageRouteInfo<void> {
  const LoginRoute({List<_i7.PageRouteInfo>? children})
      : super(
        LoginRoute.name,
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// [_i2.RegisterPage1]
class RegisterRoute extends _i7.PageRouteInfo<void> {
  const RegisterRoute({List<_i7.PageRouteInfo>? children})
      : super(
        RegisterRoute.name,
        initialChildren: children,
      );

  static const String name = 'RegisterRoute';

  static const _i7.PageInfo<void> page = _i7.PageInfo<void>(name);
}

/// [_i3.ProfilePage]
class ProfileRoute extends _i7.PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    required int userId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
        ProfileRoute.name,
        args: ProfileRouteArgs(userId: userId),
        initialChildren: children,
      );

  static const String name = 'ProfileRoute';

  static const _i7.PageInfo<ProfileRouteArgs> page = _i7.PageInfo<ProfileRouteArgs>(name);
}

class ProfileRouteArgs {
  final int userId;

  ProfileRouteArgs({required this.userId});
}
