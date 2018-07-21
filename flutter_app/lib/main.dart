import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';

import 'secrets.dart' as secrets;

part 'home.dart';
part 'splash.dart';

var accessToken = '';

getAccessTokenAmadeus() async {
  var response = await http.post(
    'https://test.api.amadeus.com/v1/security/oauth2/token',
    body: {
        "grant_type": "client_credentials",
        "client_id": "xx",
        "client_secret": "xx",
      }
  );
  accessToken = json.decode(response.body)['access_token'];
  print(accessToken);
}

Future<http.Response> callAmadeus(path, params) async {
  Uri apiUrl = new Uri(
      scheme: 'https',
      host: 'test.api.amadeus.com',
      path: path,
      queryParameters: params);

  print(apiUrl);

  return await http.get(
    apiUrl,
    headers: {HttpHeaders.AUTHORIZATION: "Bearer " + accessToken},
  );
}

class AirportResult {
  String code;
  String name;
  int distance;
  double latitude;
  double longitude;

  AirportResult(
      {this.code, this.name, this.distance, this.latitude, this.longitude});
}

Future<double> getFlightPrice(String origin, String destination) async {
  final response = await callAmadeus('v1/shopping/flight-offers', {
    "origin": origin,
    "destination": destination,
    "departureDate": "2018-08-15",
  });

  print(response.body);
  var decoded = json.decode(response.body);

  var offer = decoded['data'][0]['offerItems'][0];
  var price = offer['price']['total'];

  return double.parse(price);
}

Future<AirportResult> fetchAirport(double latitude, double longitude) async {
  final response = await callAmadeus('v1/reference-data/locations/airports', {
    "latitude": latitude.toString(),
    "longitude": longitude.toString(),
    "sort": "relevance",
  });

  print(response.statusCode);
  if (response.statusCode == 200) {
    var decoded = json.decode(response.body);
    var result = decoded['data'][0];
    return new AirportResult(
      code: result['iataCode'],
      name: result['name'],
      distance: result['distance']['value'],
      latitude: result['geoCode']['latitude'],
      longitude: result['geoCode']['longitude'],
    );
  } else {
    throw Exception('Failed to load airport');
  }
}

Future<List<Result>> getResults(
    latitudeStart, longitudeStart, latitudeEnd, longitudeEnd) async {
  final airport1 = await fetchAirport(latitudeStart, longitudeStart);
  final airport2 = await fetchAirport(latitudeEnd, longitudeEnd);

  var flightPrice = await getFlightPrice(airport1.code, airport2.code);

  List<Result> res = [];

  Result start = new Result(
    distanceSoFar: 0,
    distance: airport1.distance,
    title: 'Carsharing zum Flughafen ' + airport1.name,
    price: 0.36 * airport1.distance,
    type: TravelType.carsharing,
  );

  final Distance distance = new Distance();
  var distanceFlight = (distance(
            new LatLng(airport1.latitude, airport1.longitude),
            new LatLng(airport2.latitude, airport2.longitude),
          ) ~/
          1000)
      .toInt();

  Result flight = new Result(
    distanceSoFar: airport1.distance,
    distance: distanceFlight,
    title: 'Flug',
    price: flightPrice,
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

  Result(
      {this.type, this.distanceSoFar, this.distance, this.title, this.price});
}

GoogleMapsPlaces _places = new GoogleMapsPlaces(secrets.googlePlacesApi);

final homeScaffoldKey = new GlobalKey<ScaffoldState>();

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MobiPay',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
       '/home': (BuildContext context) => new MyHomePage(title: 'MobiPay')
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
