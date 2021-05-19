import 'package:flutter/material.dart';
import 'package:flutter_google_map_practice/direction_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'direction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DisplayMaps(),
    );
  }
}

class DisplayMaps extends StatefulWidget {
  @override
  _DisplayMapsState createState() => _DisplayMapsState();
}

class _DisplayMapsState extends State<DisplayMaps> {
  
  static const _initialCameraPosition = CameraPosition(
    target: LatLng(32.1877, 74.1945),
    zoom: 11.5,
  );

  GoogleMapController _googleMapController;

  Marker _origin;
  Marker _destination;

  Directions _info;

  @override
  void dispose() {
    _googleMapController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text("Google Map"),

        // show user to destination/origin location in map
        actions: [
          if (_origin != null)
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: TextButton(
                child: Text("Origin"),
                onPressed: () {
                  _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                    zoom: 14.5,
                    target: _origin.position,
                    tilt: 50,
                  )));
                },
                style: TextButton.styleFrom(primary: Colors.white),
              ),
            ),
          if (_destination != null)
            Padding(
              padding: const EdgeInsets.only(right:8.0),
              child: TextButton(
                child: Text("Dest"),
                onPressed: () {
                  _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                    zoom: 14.5,
                    target: _destination.position,
                    tilt: 50,
                  )));
                },
                style: TextButton.styleFrom(primary: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
              GoogleMap(
            mapToolbarEnabled: false, // disable map direction icon
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,
            markers: {
              if (_origin != null) _origin,
              if (_destination != null) _destination,
            },
            onLongPress: _addMarker,  // add marker in screen when user longpress a location in map

            polylines: { // draw line from origin to destination
              if(_info!=null)
              Polyline(polylineId: PolylineId("overview_polyline"),
              color: Colors.red,
              width: 5,
              points: _info.polylinePoints.map((e) => LatLng(e.latitude,e.longitude)).toList()

                
              )
            },
          ),

          if (_info != null)
            Positioned( // show a distance & duration from origin to destination to user 
              top: 20.0,
              child: Container(
                child: Text(
                  '${_info.totalDistance},${_info.totalDuration}',
                  style: TextStyle(
                    fontSize:18,
                    fontWeight:FontWeight.w600,
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0)
                    ]),
              ),
            ),
      
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _info != null
              ? _googleMapController.animateCamera(
                  CameraUpdate.newLatLngBounds(_info.bounds, 100.0))
              : _googleMapController.animateCamera(
                  CameraUpdate.newCameraPosition(_initialCameraPosition));
        },
        child: Icon(
          Icons.center_focus_strong,
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Origin is not set or both origin and destination are set
      // set origin
      _origin = Marker(
          markerId: MarkerId("origin"),
          infoWindow: InfoWindow(title: "Origin"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          position: pos);
      // reset destination
      _destination = null;
      setState(() {
        // reset info
        _info = null;
      });
    } else {
      // origin is alreay setted
      // set destination
      setState(() {
        _destination = Marker(
            markerId: MarkerId("destination"),
            infoWindow: InfoWindow(title: "Destination"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: pos);
      });

      // set info
      Directions directions = await DirectionRespository()
          .getDirection(origin: _origin.position, destination: pos);
      setState(() {
        _info = directions;
      });
    }
  }
}
