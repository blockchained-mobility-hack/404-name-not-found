import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

part 'home.dart';

Future<http.Response> callAmadeus(path, params) async {
  Uri apiUrl = new Uri(
      scheme: 'https',
      host: 'test.api.amadeus.com',
      path: path,
      queryParameters: params);

  return await http.get(
    apiUrl,
    headers: {HttpHeaders.AUTHORIZATION: "Bearer xx"},
  );
}

class AirportResult {
  String code;
  String name;
  int distance;

  AirportResult({this.code, this.name, this.distance});
}

Future<AirportResult> fetchAirport(double latitude, double longitude) async {
  final response = await callAmadeus('v1/reference-data/locations/airports', {
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "sort": "relevance",
  });

  if (response.statusCode == 200) {
    var decoded = json.decode(response.body);
    var result = decoded['data'][0];
    return new AirportResult(
        code: result['iataCode'],
        name: result['name'],
        distance: result['distance']['value']);
  } else {
    throw Exception('Failed to load airport');
  }
}

Future<List<Result>> getResults(latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) async {
  final airport1 = await fetchAirport(latitudeStart, longitudeStart);
  final airport2 = await fetchAirport(latitudeEnd, longitudeEnd);

  List<Result> res = [];

  Result start = new Result(
    distanceSoFar: 0,
    distance: airport1.distance,
    title: 'Carsharing zum Flughafen ' + airport1.name,
    price: 0.36 * airport1.distance,
    type: TravelType.carsharing,
  );
  
  Result flight = new Result(
    distanceSoFar: airport1.distance,
    distance: 567,
    title: 'Flug',
    price: 1337.0,
    type: TravelType.plane,
  );

  Result end = new Result(
    distanceSoFar: start.distance + flight.distance,
    distance: airport2.distance,
    title: 'Carsharing vom Flughafen ' + airport2.name,
    price: 0.36 * airport2.distance,
    type: TravelType.carsharing,
  );

  res.add(start);
  res.add(flight);
  res.add(end);
  
  return res;
}

enum TravelType { carsharing, plane }

class Result {
  TravelType type;
  int distanceSoFar;
  int distance;
  String title;
  double price;

  Result({this.type, this.distanceSoFar, this.distance, this.title, this.price});
}

const kGoogleApiKey = "AIzaSyA0TtT66-MIIYTqFBadycf-DfNd-J9lXe0";
GoogleMapsPlaces _places = new GoogleMapsPlaces(kGoogleApiKey);

final homeScaffoldKey = new GlobalKey<ScaffoldState>();

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo hHome Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}



Future<Null> displayPrediction(Prediction p, ScaffoldState scaffold) async {
  if (p != null) {
    // get detail (lat/lng)
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    scaffold.showSnackBar(
        new SnackBar(content: new Text("${p.description} - $lat/$lng")));
  }
}
