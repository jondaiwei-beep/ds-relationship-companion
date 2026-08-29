import 'package:dio/dio.dart';

/// Android and desktop send cookies by default and have no browser policy to
/// opt into, so there is nothing to configure.
void configureCredentials(Dio dio) {}
