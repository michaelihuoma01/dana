import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:location/location.dart';

class LocationService {
  static Future<Address> getUserLocation() async {
    LocationData? currentLocation;
    String error;
    Location location = Location();
    GeoCode geo = GeoCode();
    try {
      currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      currentLocation = null;
    }
    // final coordinates = Coordinates(
    //     latitude: currentLocation.latitude,
    //     longitude: currentLocation.longitude);
    var addresses = await geo.reverseGeocoding(
        latitude: currentLocation!.latitude!,
        longitude: currentLocation.longitude!);

    var first = addresses;
    return first;
  }
}
