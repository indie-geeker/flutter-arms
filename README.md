# Flutter Arms

Flutter_arms is a simple and easy-to-use development template for Flutter applications. It provides a solid foundation for building scalable and maintainable apps with a clean architecture.

## Getting Started

git clone flutter_arms

cd flutter_arms/app

flutter create YOUR_APP_NAME

cd ..
### if you don't have melos installed, run:
dart pub global activate melos
### then run:
melos bootstrap

cd YOUR_APP_NAME

add the following to YOUR_APP_NAME/pubspec.yaml:

```yaml
dependencies:
  app_interfaces: 
    path: ../app_interfaces
  app_network:
    path: ../app_network
  app_storage:
    path: ../app_storage
  app_logger:
    path: ../app_logger
```

flutter pub get

flutter run

