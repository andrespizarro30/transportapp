import 'package:geolocator/geolocator.dart';

abstract class GeolocationState {}

class GeolocationInitial extends GeolocationState {}

class GeolocationLoading extends GeolocationState {}

class GeolocationSuccess extends GeolocationState {
  final Position position;
  GeolocationSuccess(this.position);
}

class GeolocationFailure extends GeolocationState {
  final String error;

  GeolocationFailure(this.error);
}