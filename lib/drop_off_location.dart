import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DropOffLocation extends StatefulWidget {
  String address_name;
  double lattitude;
  double longitude;
  DropOffLocation({
    Key? key,
    required this.address_name,
    required this.lattitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<DropOffLocation> createState() => _DropOffLocationState();
}

class _DropOffLocationState extends State<DropOffLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late List<Marker> _markers = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(widget.lattitude, widget.longitude),
        infoWindow: InfoWindow(title: widget.address_name))
  ];

  Future<Position> getusercurrentlocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print(error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onTap: (LatLng latLng) async {
          final coordinates =
              await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
          Placemark place = coordinates[0];
          print(coordinates);
          print(place);
          final add =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          print("Address: ${add}");

          print("my current location");
          print(latLng.latitude.toString() + " " + latLng.longitude.toString());
          _markers.add(Marker(
              markerId: MarkerId('2'),
              position: latLng,
              infoWindow: InfoWindow(title: '${add}')));
          CameraPosition cameraposition = CameraPosition(
              zoom: 14, target: LatLng(latLng.latitude, latLng.longitude));
          final GoogleMapController controller = await _controller.future;
          controller
              .animateCamera(CameraUpdate.newCameraPosition(cameraposition));
          setState(() {});

          print(latLng);
          setState(() {});
        },
        markers: Set<Marker>.of(_markers),
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.lattitude, widget.longitude),
          zoom: 14.4746,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          getusercurrentlocation().then((value) async {
            final coordinates =
                await placemarkFromCoordinates(value.latitude, value.longitude);
            Placemark place = coordinates[0];
            print(coordinates);
            print(place);
            final add =
                '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
            print("Address: ${add}");

            print("my current location");
            print(value.latitude.toString() + " " + value.longitude.toString());
            _markers.add(Marker(
                markerId: MarkerId('1'),
                position: LatLng(value.latitude, value.longitude),
                infoWindow: InfoWindow(title: '${add}')));
            CameraPosition cameraposition = CameraPosition(
                zoom: 14, target: LatLng(value.latitude, value.longitude));
            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraposition));
            setState(() {});
          });
        },
        label: const Text('Current location'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}
