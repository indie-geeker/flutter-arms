import 'package:flutter_arms/app/app_env.dart';
import 'package:flutter_arms/app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(flavor: AppFlavor.prod);
}
