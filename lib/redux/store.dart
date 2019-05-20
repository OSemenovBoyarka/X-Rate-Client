import 'package:redux/redux.dart';
import 'package:x_rate_monitor/model/repository.dart';
import 'package:x_rate_monitor/redux/middleware.dart';
import 'package:x_rate_monitor/redux/state.dart';

import 'reducers.dart';

Store<AppState> createStore({Repository repository}) {
  repository = repository ?? ApiRepository();
  return Store(
    mainReducer,
    middleware: createMiddleware(repository),
    initialState: AppState.initial(),
  );
}


