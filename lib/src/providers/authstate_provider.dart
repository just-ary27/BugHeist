import 'package:bugheist/src/util/api/user_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './login_provider.dart';
import '../models/user_model.dart';
import '../routes/routing.dart';
import '../global/variables.dart';
import '../util/api/auth_api.dart';
import '../util/enums/authstate_type.dart';
import '../util/enums/login_type.dart';

/// The provider which exposes the state management for user authentication.
final authStateNotifier =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier(ref.read);
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  final Reader read;
  AsyncValue<AuthState>? previousState;

  AuthNotifier(this.read, [AsyncValue<AuthState>? authstate])
      : super(
          authstate ?? const AsyncValue.data(AuthState.loggedOut),
        );

  /// Do a guest type authentication.
  void guestLogin() {
    state = AsyncValue.data(AuthState.loggedIn);
    currentUser = guestUser;
    read(loginProvider.notifier).setGuestLogin();
  }

  /// Do a user type authentication.
  Future<void> userLogin(
      Map<String, String?> userCreds, BuildContext parentContext) async {
    state = AsyncValue.data(AuthState.authenticating);
    SnackBar authSnack = SnackBar(
      content: Text("Authenticating ..."),
      duration: Duration(minutes: 1),
    );
    ScaffoldMessenger.of(parentContext).showSnackBar(authSnack);
    try {
      User? authenticatedUser = await AuthApiClient.login(userCreds);
      if (authenticatedUser != null) {
        currentUser = authenticatedUser;
        await UserApiClient.getUserInfo(currentUser!);

        state = AsyncValue.data(AuthState.loggedIn);
        read(loginProvider.notifier).setUserLogin();

        ScaffoldMessenger.of(parentContext).clearSnackBars();
        Navigator.of(parentContext).pushReplacementNamed(
          RouteManager.homePage,
        );
      } else {
        ScaffoldMessenger.of(parentContext).clearSnackBars();
        SnackBar errorSnack = SnackBar(
          content: Text("There was some error, please try again!"),
        );
        ScaffoldMessenger.of(parentContext).showSnackBar(errorSnack);
      }
    } catch (e) {}
  }

  /// Do a logout for both guest and user type authentications.
  Future<void> logout() async {
    LoginType loginType = read(loginProvider.notifier).loginType;
    if (loginType == LoginType.guest) {
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(AuthState.loggedOut);
      read(loginProvider.notifier).logout();
      currentUser = null;
    } else if (loginType == LoginType.user) {
      if (await AuthApiClient.logout()) {
        await Future.delayed(const Duration(seconds: 1));
        state = AsyncValue.data(AuthState.loggedOut);
        read(loginProvider.notifier).logout();
        currentUser = null;
      }
    }
  }

  Future<void> signup() async {}
}
