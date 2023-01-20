import 'dart:async';

import 'package:drag_marker_in_map/drop_off_location.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickUpLocation extends StatefulWidget {
  String address_name;
  double lattitude;
  double longitude;
  PickUpLocation({
    Key? key,
    required this.address_name,
    required this.lattitude,
    required this.longitude,
  }) : super(key: key);

  @override
  State<PickUpLocation> createState() => _PickUpLocationState();
}

class _PickUpLocationState extends State<PickUpLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late final List<Marker> _markers = <Marker>[
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
          getusercurrentlocation().then((value) async {
            final coordinates = await placemarkFromCoordinates(
                latLng.latitude, latLng.longitude);
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
                position: latLng,
                infoWindow: InfoWindow(title: '${add}')));
            CameraPosition cameraposition = CameraPosition(
                zoom: 14, target: LatLng(latLng.latitude, latLng.longitude));
            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraposition));
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DropOffLocation(
                        address_name: add,
                        lattitude: latLng.latitude,
                        longitude: latLng.longitude)));
            setState(() {});
          });
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
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => PickUpLocation(
          //             address_name: widget.address_name,
          //             lattitude: widget.lattitude,
          //             longitude: widget.longitude)));
          // getusercurrentlocation().then((value) async {
          //   final coordinates =
          //       await placemarkFromCoordinates(value.latitude, value.longitude);
          //   Placemark place = coordinates[0];
          //   print(coordinates);
          //   print(place);
          //   final add =
          //       '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
          //   print("Address: ${add}");

          //   print("my current location");
          //   print(value.latitude.toString() + " " + value.longitude.toString());
          //   _markers.add(Marker(
          //       markerId: MarkerId('1'),
          //       position: LatLng(value.latitude, value.longitude),
          //       infoWindow: InfoWindow(title: '${add}')));
          //   CameraPosition cameraposition = CameraPosition(
          //       zoom: 14, target: LatLng(value.latitude, value.longitude));
          //   final GoogleMapController controller = await _controller.future;
          //   controller
          //       .animateCamera(CameraUpdate.newCameraPosition(cameraposition));
          //   setState(() {});
          // });
        },
        label: const Text('Select Drop-Of Location'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }
}
