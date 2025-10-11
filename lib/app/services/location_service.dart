import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Checks if location services are enabled and requests permissions if needed
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled, prompt user to enable them
      return false;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, prompt user to enable them
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, we cannot request permissions
      return false;
    }

    return true;
  }

  /// Gets the current position of the device
  Future<Position> getCurrentPosition() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permissions are denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } on LocationServiceDisabledException {
      throw Exception('Location services are disabled');
    } on PermissionDeniedException {
      throw Exception('Location permissions are denied');
    } on Exception catch (e) {
      throw Exception('Could not get location: $e');
    }
  }

  /// Gets the current location with address
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final position = await getCurrentPosition();
      final address = await getAddressFromCoordinates(
          position.latitude, position.longitude);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp.millisecondsSinceEpoch,
      };
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Gets the address from coordinates
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = <String>[];

        if (place.street != null && place.street!.isNotEmpty)
          addressParts.add(place.street!);
        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add(place.locality!);
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty)
          addressParts.add(place.administrativeArea!);
        if (place.country != null && place.country!.isNotEmpty)
          addressParts.add(place.country!);

        return addressParts.isNotEmpty
            ? addressParts.join(', ')
            : 'Unknown Location';
      }
      return 'Unknown Location';
    } catch (e) {
      if (e.toString().contains('NoResultAvailableException')) {
        return 'No address found for this location';
      }
      print('Error getting address from coordinates: $e');
      return 'Could not get address';
    }
  }
}
