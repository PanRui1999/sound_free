import 'package:lua_dardo/lua.dart';

class LuaEngineN {
  static final List<LuaEngineN> _instances = [];
  final String key;
  final LuaState _stateMachine = LuaState.newState();

  LuaEngineN._(this.key);

  factory LuaEngineN(String key) {
    var eng = LuaEngineN(key);
    eng._stateMachine.openLibs();
    _instances.add(eng);
    return eng;
  }
}