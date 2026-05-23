import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:learn_craft/features/auth/presentation/bloc/auth_bloc.dart';

class RouterNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription<AuthState> _sub;

  RouterNotifier(this._authBloc) {
    _sub = _authBloc.stream.listen((_) => notifyListeners());
  }

  AuthState get authState => _authBloc.state;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
