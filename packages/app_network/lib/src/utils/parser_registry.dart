import 'package:app_interfaces/app_interfaces.dart';
// unused
class ParserRegistry {

  ParserRegistry._();

  static final ParserRegistry _instance = ParserRegistry._();

  static final Map<String, ResponseParser Function()> _factories = {};

  static void register(String key, ResponseParser Function() factory){
    _factories[key] = factory;
  }

  static ParserRegistry getInstance(){
    return _instance;
  }

  static ResponseParser of(String key){
    final factory = _factories[key];
    if (factory == null) {
      throw StateError('No parser registered for key: $key');
    }
    return factory();
  }

  static List<String> getKeys(){
    final keys = _factories.keys.toList();
    if (keys.isEmpty) {
      throw StateError('No parser registered, please register a parser first');
    }
    return keys;
  }

  static void clear(){
    _factories.clear();
  }
}
