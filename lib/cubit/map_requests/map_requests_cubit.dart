import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../common/service_call.dart';
import '../../model/address.dart';
import '../../model/directions_model.dart';
import '../../model/geocoding_model.dart';
import '../../model/place_info_model.dart';
import '../../model/places_model.dart';

part 'map_requests_state.dart';

class MapRequestsCubit extends Cubit<MapRequestsState> {

  MapRequestsCubit() : super(MapRequestsInitial());

  String geoCodingKey = "AIzaSyCBDQ2l_f4ksZaSzkCqhNsOhdHfbU5lKqA";

  void getDirections(LatLng origPos, LatLng destPos, context) async{

    if(origPos != null && destPos != null){

      String directionsURL = "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origPos.latitude},${origPos.longitude}&"
          "destination=${destPos.latitude},${destPos.longitude}&"
          "key=${geoCodingKey}";

      print(directionsURL);

      var response = await ServiceCall.getRequest(Uri.parse(directionsURL));

      if(response != "failed"){

        final directions = DirectionsModel.fromJson(response);

        if(directions.status == "OK"){
          emit(MapRequestsDirectionsSuccess(directions.routes!));
        }else{
          emit(MapRequestsDirectionsFailed());
        }
      }else{
        emit(MapRequestsDirectionsFailed());
      }

    }
  }

  void searchCoordinateAddress(Position position, context) async{

    String placeAddress = "";
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${geoCodingKey}";

    var response = await ServiceCall.getRequest(Uri.parse(url));

    if(response != "failed"){
      final geoCode = GeoCodingModel.fromJson(response);

      for(var address in geoCode.results![0].addressComponents!){
        placeAddress = "${placeAddress}${address.longName} ";
      }

      Address userPickUpAddress = Address(
          placeFormattedAddress: geoCode.results![0].formattedAddress,
          placeName: placeAddress,
          placeId: geoCode.results![0].placeId,
          latitude: position.latitude,
          longitude: position.longitude
      );

      emit(MapRequestsAddressSuccess(userPickUpAddress));

    }else{
      emit(MapRequestsAddressFailed());
    }

  }

  void findPlace(String placeName,context) async{

    if(placeName.length>1){
      String autoCompleteURL="https://maps.googleapis.com/maps/api/place/autocomplete/json?"
          "input=${placeName}&"
          "key=${geoCodingKey}&"
          "components=country:co";

      var response = await ServiceCall.getRequest(Uri.parse(autoCompleteURL));

      if(response != "failed"){

        final placeCode = PlaceModel.fromJson(response);

        if(placeCode.status == "OK"){
          emit(MapRequestsPredictionsSuccess(placeCode.predictions!));
        }else{

        }
      }
    }

    return null;
  }

  void getPlaceDetails(String placeId,context) async{

    if(placeId.length>1){
      String placeDetailURL = "https://maps.googleapis.com/maps/api/place/details/json?"
          "place_id=${placeId}&"
          "key=${geoCodingKey}&"
          "fields=address_components,adr_address,formatted_address,geometry,place_id,type,url,vicinity";

      var response = await ServiceCall.getRequest(Uri.parse(placeDetailURL));

      if(response != "failed"){

        final placeDetails = PlacesInfoModel.fromJson(response);

        if(placeDetails.status == "OK"){
          print(placeDetails.result!.toJson().toString());
        }

        emit(MapRequestsInfoModelSuccess(placeDetails));
      }else{
        emit(MapRequestsInfoModelFailed());
      }

    }
  }

}
