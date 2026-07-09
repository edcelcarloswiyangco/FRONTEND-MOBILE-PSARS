export 'network_discovery_stub.dart'
    if (dart.library.io) 'network_discovery_io.dart'
    if (dart.library.html) 'network_discovery_web.dart';
