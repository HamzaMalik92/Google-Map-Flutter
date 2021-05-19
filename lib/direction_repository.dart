import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_map_practice/direction.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_map_practice/.env.dart';

class DirectionRespository {
  static const String _baseURL="https://maps.googleapis.com/maps/api/directions/json?";

  Dio _dio;

  DirectionRespository({Dio dio}):_dio=dio?? Dio();

  Future getDirection(
   { @required LatLng origin,  
    @required LatLng destination}
  )
  async{
    final response=await _dio.get(
      _baseURL,
      queryParameters: {
        'origin':'${origin.latitude},${origin.longitude}',
        'destination':'${destination.latitude},${destination.longitude}',
        "key":googleAPIkey
      }

    );


    print("Map Api Response");
    print(response.statusCode);   
    print("Map Api Response Data");
    print(response.data);

    if(response.statusCode==200){
      return Directions.fromMap(response.data);
    }

    return null;
  }
}