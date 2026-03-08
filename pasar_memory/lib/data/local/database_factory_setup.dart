import 'database_factory_setup_stub.dart'
    if (dart.library.html) 'database_factory_setup_web.dart'
    if (dart.library.io) 'database_factory_setup_native.dart';

Future<void> configureDatabaseFactory() => configureDatabaseFactoryImpl();