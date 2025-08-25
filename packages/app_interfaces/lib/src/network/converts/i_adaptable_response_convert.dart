import '../../../app_interfaces.dart';

abstract class IAdaptableResponseConvert<T> {

  Result<T> convert<T>(dynamic response, T Function(dynamic) fromJson);
}