import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _initialPosition = CameraPosition(
    target:  LatLng(16.7087, 74.2795),
    zoom: 14.4746,
    bearing: 45, // <-- KEY: Rotate to trigger compass
  );

  final List<Marker> _markers = [
    Marker(
      markerId: MarkerId("1"),
      position:  LatLng(16.7087, 74.2795),
      infoWindow: InfoWindow(title: "My Location"),
    ),
  ];


  Future<Position> getUserCurrentLocation()async{
    await Geolocator.requestPermission().then((onValue){

    }).onError((error, stackTrace) {
      print(error.toString());
    },);
    return await Geolocator.getCurrentPosition();
  }


  loadData(){
    getUserCurrentLocation().then((value)async{
      setState(() {

      });
      _markers.add(
        Marker(markerId: MarkerId("3"),
            position: LatLng(value.latitude,value.longitude),
            infoWindow: InfoWindow(
                title: "Current Location"
            )
        ),
      );

      CameraPosition cameraposition=CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 15
      );

      final GoogleMapController controller=await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraposition));
      //  print(value.latitude.toString()+" "+value.longitude.toString());
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Map Compass Test")),
      body: SafeArea(
        child: GoogleMap(
          initialCameraPosition: _initialPosition,
          markers: Set<Marker>.of(_markers),
          mapType: MapType.normal,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: ()async{
        getUserCurrentLocation().then((value)async{
          setState(() {

          });
          _markers.add(
            Marker(markerId: MarkerId("3"),
                position: LatLng(value.latitude,value.longitude),
                infoWindow: InfoWindow(
                    title: "Current Location"
                )
            ),
          );

          CameraPosition cameraposition=CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 15
          );

          final GoogleMapController controller=await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(cameraposition));
          //  print(value.latitude.toString()+" "+value.longitude.toString());
        });
      },
        child: Icon(Icons.location_disabled_outlined),
      ),
    );
  }
}
