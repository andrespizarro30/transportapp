part of 'map_requests_cubit.dart';

sealed class MapRequestsState {
  const MapRequestsState();

  @override
  List<Object> get props => [];
}

class MapRequestsInitial extends MapRequestsState {}


class MapRequestsDirectionsSuccess extends MapRequestsState {
  final List<Routes> routes;
  const MapRequestsDirectionsSuccess(this.routes);
}

class MapRequestsDirectionsFailed extends MapRequestsState {}


class MapRequestsAddressSuccess extends MapRequestsState {
  final Address address;
  const MapRequestsAddressSuccess(this.address);
}

class MapRequestsAddressFailed extends MapRequestsState {}


class MapRequestsPredictionsSuccess extends MapRequestsState {
  final List<Predictions> predictions;
  const MapRequestsPredictionsSuccess(this.predictions);
}

class MapRequestsPredictionsFailed extends MapRequestsState {}


class MapRequestsInfoModelSuccess extends MapRequestsState {
  final PlacesInfoModel placesInfoModel;
  const MapRequestsInfoModelSuccess(this.placesInfoModel);
}

class MapRequestsInfoModelFailed extends MapRequestsState {}
