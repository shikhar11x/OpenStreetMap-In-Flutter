import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class OpenstreetmapScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<OpenstreetmapScreen> createState() => _OpenstreetmapScreenState();
}

class _OpenstreetmapScreenState extends State<OpenstreetmapScreen> {
  final MapController _mapController = MapController();

  final Location _location = Location();

  final TextEditingController _locationController = TextEditingController();

  bool isLoading = true;

  LatLng? _currentLocation;
  LatLng? _destination;

  List<LatLng> _rout = [];

@override
void initState(){
  super.initState();
  _initializeLocation();
}
  Future<void> _initializeLocation() async {
    if (!await _checktheRequestPermission()) return;

    _location.onLocationChanged.listen(
      (LocationData locationData){
        // ignore: unnecessary_null_comparison
        if(locationData.latitude != null && locationData.longitude !=null){
          setState(() {
            _currentLocation=LatLng(locationData.latitude, locationData.longitude);
            isLoading=false;
          });

        }
      }
    );

  }

// Method to fetch co-ordinates for a given location using the openStreetMap Nominatim API

Future <void> fetchCoordinatePoints(String location) async{
  final url=Uri.parse("https://nominatim.openstreetmap.org/search?q=$location&format=json");
  final response =await http.get(url);
  if(response.statusCode==200){
    final data= jsonDecode(response.body);
    if(data.isNotEmpty){
      final lat= double.parse(data[0]['lat']);
      final lon= double.parse(data[0]['lon']);
      setState(() {
        _destination=LatLng(lat, lon);
      });
      await _fetchRoute;
    }
    else{
      er
    }

  }
}


  Future<bool> _checktheRequestPermission() async {
    bool serviceEnable = await _location.serviceEnabled();
    if (!serviceEnable) {
      serviceEnable = await _location.requestService();
      if (!serviceEnable) {
        return false;
      }
    }
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Current location not available")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        title: Text("OpenStreetMap", selectionColor: Colors.blueAccent),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? LatLng(0, 0),
              initialZoom: 2,
              minZoom: 0,
              maxZoom: 100,
            ),

            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              CurrentLocationLayer(
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    child: Icon(Icons.location_pin, color: Colors.white),
                  ),
                  markerSize: Size(35, 35),
                  markerDirection: MarkerDirection.heading,
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _userCurrentLocation,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.my_location, color: Colors.white, size: 30),
      ),
    );
  }
}
