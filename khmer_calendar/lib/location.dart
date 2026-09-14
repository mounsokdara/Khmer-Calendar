import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'i18n.dart';
import 'store.dart';
import 'weather.dart';

enum GpsResult { added, already, denied, disabled, failed }

String gpsMessage(Lang lang, GpsResult result) {
  switch (result) {
    case GpsResult.added:
    case GpsResult.already:
      return t(lang, 'locAdded');
    case GpsResult.denied:
      return t(lang, 'permDenied');
    case GpsResult.disabled:
    case GpsResult.failed:
      return t(lang, 'noLocation');
  }
}

LocationSettings _gpsSettings() {
  const limit = Duration(seconds: 15);
  if (kIsWeb) {
    return const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: limit);
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return AndroidSettings(
        accuracy: LocationAccuracy.medium,
        forceLocationManager: true,
        timeLimit: limit,
      );
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return AppleSettings(accuracy: LocationAccuracy.medium, timeLimit: limit);
    default:
      return const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: limit);
  }
}

/// Requests OS location (like original `toggleGps()`), then adds the nearest
/// city. Always reports [GpsResult.already] / [GpsResult.added] so the user
/// gets feedback even when Phnom Penh is already in the list.
///
/// On Android devices without Play Services (common in Cambodia) Fused Location
/// times out — [AndroidSettings.forceLocationManager] uses the OS GPS provider.
Future<GpsResult> requestNearbyCity(AppStore store) async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return GpsResult.disabled;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return GpsResult.denied;
    }
    Position? last;
    try {
      last = await Geolocator.getLastKnownPosition();
    } catch (_) {}
    late final Position pos;
    try {
      pos = await Geolocator.getCurrentPosition(locationSettings: _gpsSettings());
    } catch (_) {
      if (last == null) return GpsResult.failed;
      pos = last;
    }
    final city = nearestCity(pos.latitude, pos.longitude);
    final existed = store.weatherCities.contains(city.id);
    store.addWeatherCity(city.id);
    store.setLocationOn(true);
    return existed ? GpsResult.already : GpsResult.added;
  } catch (_) {
    return GpsResult.failed;
  }
}

void showGpsSnack(BuildContext context, Lang lang, GpsResult result) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(gpsMessage(lang, result))));
}
