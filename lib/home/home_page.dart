import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_starter_kit/constants.dart';
import 'package:flutter_starter_kit/home/components/home_body.dart';
import 'package:flutter_starter_kit/home/components/home_footer.dart';
import 'package:flutter_starter_kit/home/components/home_header.dart';
import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var kindeClient = KindeFlutterSDK.instance;

  final ValueNotifier<bool> _loading = ValueNotifier(false);
  final ValueNotifier<UserProfileV2?> _profile = ValueNotifier(null);
  final ValueNotifier<bool> _loggedIn = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kindeClient.isAuthenticate(context).then((value) {
        _loggedIn.value = value;

        if (value) {
          _loading.value = true;
          _getProfile();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.viewPaddingOf(context).top,
            left: 16.w,
            right: 16.w,
            bottom: MediaQuery.viewPaddingOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              ListenableBuilder(
                  listenable: Listenable.merge([_loading, _profile]),
                  builder: (context, _) {
                    return HomeHeader(
                        profile: _profile.value,
                        loading: _loading.value,
                        onLogin: _signIn,
                        onLogout: _signOut,
                        onRegister: _signUp);
                  }),
              verticalSpaceMedium,
              ValueListenableBuilder(
                  valueListenable: _loggedIn,
                  builder: (_, value, __) => HomeBody(loggedIn: value)),
              SizedBox(height: 30),
              const HomeFooter(),
            ],
          ),
        ),
      ),
    );
  }

  _signIn() {
    kindeClient.login(type: AuthFlowType.pkce, context: context).then((token) {
      if (token != null) {
        _loggedIn.value = true;
        _getProfile();
      }
    });
  }

  _signOut() {
    kindeClient.logout().then((value) {
      _loggedIn.value = false;
      _profile.value = null;
    });
  }

  _signUp() {
    kindeClient.register(context: context);
  }

  _getProfile() {
    kindeClient.getUserProfileV2().then((profile) async {
      _profile.value = profile;
    }).whenComplete(() => _loading.value = false);
  }
}
