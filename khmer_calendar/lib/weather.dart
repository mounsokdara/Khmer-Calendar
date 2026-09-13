import 'dart:convert';

import 'package:http/http.dart' as http;

class City {
  const City({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
    required this.photo,
  });
  final String id;
  final String name;
  final String nameEn;
  final double latitude;
  final double longitude;
  final String photo;
}

class HourlyWx {
  const HourlyWx(this.time, this.temp, this.code);
  final String time;
  final int temp;
  final int code;
}

class DailyWx {
  const DailyWx(this.date, this.high, this.low, this.code);
  final String date;
  final int high;
  final int low;
  final int code;
}

class WeatherSnap {
  const WeatherSnap({
    required this.temp,
    required this.high,
    required this.low,
    required this.code,
    required this.humidity,
    required this.wind,
    required this.uv,
    required this.apparent,
    required this.hourly,
    required this.daily,
    required this.cachedAt,
  });
  final int temp;
  final int high;
  final int low;
  final int code;
  final int humidity;
  final double wind;
  final double uv;
  final int apparent;
  final List<HourlyWx> hourly;
  final List<DailyWx> daily;
  final String cachedAt;
}

const cities = [
  City(id: 'phnom-penh', name: 'ភ្នំពេញ', nameEn: 'Phnom Penh', latitude: 11.5564, longitude: 104.9282, photo: 'assets/weather/phnom-penh.jpg'),
  City(id: 'banteay-meanchey', name: 'បន្ទាយមានជ័យ', nameEn: 'Banteay Meanchey', latitude: 13.5859, longitude: 102.9737, photo: 'assets/weather/banteay.jpg'),
  City(id: 'battambang', name: 'បាត់ដំបង', nameEn: 'Battambang', latitude: 13.0957, longitude: 103.2022, photo: 'assets/weather/battambang.jpg'),
  City(id: 'kampong-cham', name: 'កំពង់ចាម', nameEn: 'Kampong Cham', latitude: 11.9934, longitude: 105.4635, photo: 'assets/weather/kampong-cham.jpg'),
  City(id: 'kampong-chhnang', name: 'កំពង់ឆ្នាំង', nameEn: 'Kampong Chhnang', latitude: 12.25, longitude: 104.6667, photo: 'assets/weather/kampot.jpg'),
  City(id: 'kampong-speu', name: 'កំពង់ស្ពឺ', nameEn: 'Kampong Speu', latitude: 11.4533, longitude: 104.519, photo: 'assets/weather/kampot.jpg'),
  City(id: 'kampong-thom', name: 'កំពង់ធំ', nameEn: 'Kampong Thom', latitude: 12.7111, longitude: 104.8889, photo: 'assets/weather/banteay.jpg'),
  City(id: 'kampot', name: 'កំពត', nameEn: 'Kampot', latitude: 10.6104, longitude: 104.181, photo: 'assets/weather/kampot-river.jpg'),
  City(id: 'kandal', name: 'កណ្ដាល', nameEn: 'Kandal', latitude: 11.4833, longitude: 104.95, photo: 'assets/weather/phnom-penh-alt.jpg'),
  City(id: 'koh-kong', name: 'កោះកុង', nameEn: 'Koh Kong', latitude: 11.6153, longitude: 102.9839, photo: 'assets/weather/sihanoukville.jpg'),
  City(id: 'kratie', name: 'ក្រចេះ', nameEn: 'Kratie', latitude: 12.4881, longitude: 106.0188, photo: 'assets/weather/kratie.jpg'),
  City(id: 'mondulkiri', name: 'មណ្ឌលគិរី', nameEn: 'Mondulkiri', latitude: 12.4558, longitude: 107.1906, photo: 'assets/weather/mondulkiri.jpg'),
  City(id: 'pailin', name: 'ប៉ៃលិន', nameEn: 'Pailin', latitude: 12.8489, longitude: 102.6093, photo: 'assets/weather/battambang.jpg'),
  City(id: 'preah-vihear', name: 'ព្រះវិហារ', nameEn: 'Preah Vihear', latitude: 13.807, longitude: 104.978, photo: 'assets/weather/preah-vihear.jpg'),
  City(id: 'prey-veng', name: 'ព្រៃវែង', nameEn: 'Prey Veng', latitude: 11.485, longitude: 105.325, photo: 'assets/weather/kampong-cham.jpg'),
  City(id: 'pursat', name: 'ពោធិ៍សាត់', nameEn: 'Pursat', latitude: 12.5388, longitude: 103.9192, photo: 'assets/weather/kampot.jpg'),
  City(id: 'ratanakiri', name: 'រតនគិរី', nameEn: 'Ratanakiri', latitude: 13.7395, longitude: 106.9873, photo: 'assets/weather/mondulkiri.jpg'),
  City(id: 'siem-reap', name: 'សៀមរាប', nameEn: 'Siem Reap', latitude: 13.3633, longitude: 103.8564, photo: 'assets/weather/siem-reap.jpg'),
  City(id: 'sihanoukville', name: 'ព្រះសីហនុ', nameEn: 'Sihanoukville', latitude: 10.6271, longitude: 103.5222, photo: 'assets/weather/sihanoukville.jpg'),
  City(id: 'stung-treng', name: 'ស្ទឹងត្រែង', nameEn: 'Stung Treng', latitude: 13.5259, longitude: 105.9683, photo: 'assets/weather/kratie.jpg'),
  City(id: 'svay-rieng', name: 'ស្វាយរៀង', nameEn: 'Svay Rieng', latitude: 11.0879, longitude: 105.7993, photo: 'assets/weather/kampong-cham.jpg'),
  City(id: 'takeo', name: 'តាកែវ', nameEn: 'Takeo', latitude: 10.9908, longitude: 104.785, photo: 'assets/weather/kampot-river.jpg'),
  City(id: 'oddar-meanchey', name: 'ឧត្តរមានជ័យ', nameEn: 'Oddar Meanchey', latitude: 14.1817, longitude: 103.5176, photo: 'assets/weather/banteay.jpg'),
  City(id: 'kep', name: 'កែប', nameEn: 'Kep', latitude: 10.4826, longitude: 104.3167, photo: 'assets/weather/sihanoukville.jpg'),
  City(id: 'tboung-khmum', name: 'ត្បូងឃ្មុំ', nameEn: 'Tboung Khmum', latitude: 11.911, longitude: 105.658, photo: 'assets/weather/kampong-cham.jpg'),
];

City? cityById(String id) {
  for (final c in cities) {
    if (c.id == id) return c;
  }
  return null;
}

City nearestCity(double lat, double lon) {
  var best = cities.first;
  var dist = double.infinity;
  for (final c in cities) {
    final d = (c.latitude - lat) * (c.latitude - lat) + (c.longitude - lon) * (c.longitude - lon);
    if (d < dist) {
      dist = d;
      best = c;
    }
  }
  return best;
}

class WxMeta {
  const WxMeta(this.en, this.km, this.kind);
  final String en;
  final String km;
  final String kind;
}

WxMeta wmoOf(int code) {
  if (code <= 0) return const WxMeta('clear sky', 'ថ្ងៃថ្លា', 'clear');
  if (code <= 1) return const WxMeta('mainly clear', 'ស្ទើរតែថ្លា', 'clear');
  if (code <= 2) return const WxMeta('partly cloudy', 'មានពពកបន្តិច', 'cloudy');
  if (code <= 3) return const WxMeta('overcast clouds', 'ពពកអស់មេឃ', 'cloudy');
  if (code <= 48) return const WxMeta('fog', 'អ័ព្ទ', 'cloudy');
  if (code <= 57) return const WxMeta('drizzle', 'ភ្លៀងសើម', 'rain');
  if (code <= 67) return const WxMeta('rain', 'ភ្លៀង', 'rain');
  if (code <= 77) return const WxMeta('snow', 'ព្រិល', 'rain');
  if (code <= 82) return const WxMeta('rain showers', 'ភ្លៀងផ្កាឈូក', 'rain');
  if (code <= 86) return const WxMeta('snow showers', 'ព្រិល', 'rain');
  return const WxMeta('thunderstorm', 'ព្យុះផ្គររន្ទះ', 'storm');
}

Future<WeatherSnap> fetchWeather(City city) async {
  final url = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=${city.latitude}&longitude=${city.longitude}'
    '&current=temperature_2m,weather_code,relative_humidity_2m,wind_speed_10m,apparent_temperature,uv_index'
    '&hourly=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=Asia%2FPhnom_Penh',
  );
  final res = await http.get(url);
  if (res.statusCode != 200) throw Exception('Http ${res.statusCode}');
  final j = jsonDecode(res.body) as Map<String, dynamic>;
  final hourlyTimes = (j['hourly']?['time'] as List?) ?? [];
  final dailyTimes = (j['daily']?['time'] as List?) ?? [];
  final hourly = <HourlyWx>[];
  for (var i = 0; i < hourlyTimes.length && i < 12; i++) {
    hourly.add(HourlyWx(
      hourlyTimes[i] as String,
      ((j['hourly']['temperature_2m'][i] as num).round()),
      (j['hourly']['weather_code'][i] as num).toInt(),
    ));
  }
  final daily = <DailyWx>[];
  for (var i = 0; i < dailyTimes.length && i < 7; i++) {
    daily.add(DailyWx(
      dailyTimes[i] as String,
      (j['daily']['temperature_2m_max'][i] as num).round(),
      (j['daily']['temperature_2m_min'][i] as num).round(),
      (j['daily']['weather_code'][i] as num).toInt(),
    ));
  }
  final current = j['current'] as Map<String, dynamic>;
  return WeatherSnap(
    temp: (current['temperature_2m'] as num).round(),
    high: daily.isNotEmpty ? daily.first.high : (current['temperature_2m'] as num).round(),
    low: daily.isNotEmpty ? daily.first.low : (current['temperature_2m'] as num).round(),
    code: (current['weather_code'] as num).toInt(),
    humidity: (current['relative_humidity_2m'] as num).round(),
    wind: (current['wind_speed_10m'] as num).toDouble(),
    uv: (current['uv_index'] as num?)?.toDouble() ?? 0,
    apparent: (current['apparent_temperature'] as num).round(),
    hourly: hourly,
    daily: daily,
    cachedAt: DateTime.now().toIso8601String(),
  );
}
