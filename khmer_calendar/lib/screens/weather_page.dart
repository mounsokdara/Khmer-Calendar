import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../i18n.dart';
import '../store.dart';
import '../theme.dart';
import '../weather.dart';
import '../widgets/swipe_delete.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key, required this.store});
  final AppStore store;

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _cache = <String, WeatherSnap>{};
  final _err = <String, String>{};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
    _refresh();
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    for (final id in widget.store.weatherCities) {
      final city = cityById(id);
      if (city == null) continue;
      try {
        _cache[id] = await fetchWeather(city);
        _err.remove(id);
      } catch (_) {
        _err[id] = 'fail';
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final lang = store.lang;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text(t(lang, 'weather'), style: Theme.of(context).textTheme.headlineSmall)),
              IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
              IconButton(
                tooltip: t(lang, 'addCity'),
                onPressed: () => _addCity(context),
                icon: const Icon(Icons.add),
              ),
              IconButton(
                tooltip: t(lang, 'permLocation'),
                onPressed: () => _nearMe(),
                icon: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: store.weatherCities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t(lang, 'noCity')),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: () => _addCity(context), child: Text(t(lang, 'addCity'))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.sizeOf(context).width >= xlBreak
                          ? 3
                          : MediaQuery.sizeOf(context).width >= mediumBreak
                              ? 2
                              : 1,
                      mainAxisExtent: 168,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: store.weatherCities.length,
                    itemBuilder: (ctx, i) {
                      final id = store.weatherCities[i];
                      final city = cityById(id);
                      if (city == null) return const SizedBox.shrink();
                      final snap = _cache[id];
                      final err = _err[id];
                      return swipeToDelete(
                        context: context,
                        key: 'wx-$id',
                        lang: lang,
                        onDelete: () => store.removeWeatherCity(id),
                        child: _CityCard(
                          city: city,
                          snap: snap,
                          error: err != null,
                          lang: lang,
                          onOpen: () => _openCity(city, snap),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _addCity(BuildContext context) async {
    final lang = widget.store.lang;
    final q = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            final query = q.text.toLowerCase();
            final list = cities.where((c) {
              if (widget.store.weatherCities.contains(c.id)) return false;
              if (query.isEmpty) return true;
              return c.name.contains(q.text) || c.nameEn.toLowerCase().contains(query);
            }).toList();
            return SizedBox(
              height: 480,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: q,
                      decoration: InputDecoration(hintText: t(lang, 'findCity'), prefixIcon: const Icon(Icons.search)),
                      onChanged: (_) => setSt(() {}),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final c in list)
                          ListTile(
                            title: Text(lang == Lang.en ? c.nameEn : c.name),
                            subtitle: Text(lang == Lang.en ? c.name : c.nameEn),
                            onTap: () {
                              widget.store.addWeatherCity(c.id);
                              Navigator.pop(ctx);
                              _refresh();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _nearMe() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(timeLimit: Duration(seconds: 8)));
      final city = nearestCity(pos.latitude, pos.longitude);
      widget.store.addWeatherCity(city.id);
      widget.store.setLocationOn(true);
      await _refresh();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(widget.store.lang, 'noLocation'))));
      }
    }
  }

  Future<void> _openCity(City city, WeatherSnap? snap) async {
    final lang = widget.store.lang;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final meta = snap == null ? null : wmoOf(snap.code);
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, sc) {
            return ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(city.photo, height: 140, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text(lang == Lang.en ? city.nameEn : city.name, style: Theme.of(ctx).textTheme.headlineSmall),
                if (snap != null) ...[
                  Text('${snap.temp}°', style: Theme.of(ctx).textTheme.displaySmall),
                  Text(lang == Lang.en ? meta!.en : meta!.km),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _chip(ctx, t(lang, 'humidity'), '${snap.humidity}%'),
                      _chip(ctx, t(lang, 'wind'), '${snap.wind.round()} ${t(lang, 'kmh')}'),
                      _chip(ctx, t(lang, 'uv'), '${snap.uv.round()}'),
                      _chip(ctx, t(lang, 'feels'), '${snap.apparent}°'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(t(lang, 'hourly'), style: Theme.of(ctx).textTheme.titleMedium),
                  SizedBox(
                    height: 88,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final h in snap.hourly)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Text(h.time.substring(11, 16)),
                                Text('${h.temp}°', style: const TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(t(lang, 'weekly'), style: Theme.of(ctx).textTheme.titleMedium),
                  for (final d in snap.daily)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(d.date),
                      trailing: Text('${d.high}° / ${d.low}°'),
                    ),
                ] else
                  Text(t(lang, 'weatherError')),
              ],
            );
          },
        );
      },
    );
  }

  Widget _chip(BuildContext ctx, String k, String v) {
    return Chip(label: Text('$k  $v'));
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({
    required this.city,
    required this.snap,
    required this.error,
    required this.lang,
    required this.onOpen,
  });
  final City city;
  final WeatherSnap? snap;
  final bool error;
  final Lang lang;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final meta = snap == null ? null : wmoOf(snap!.code);
    return Material(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onOpen,
        child: Stack(
          children: [
            Image.asset(city.photo, height: 168, width: double.infinity, fit: BoxFit.cover),
            Container(
              height: 168,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(lang == Lang.en ? city.nameEn : city.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                          error ? t(lang, 'weatherError') : (snap == null ? t(lang, 'loading') : (lang == Lang.en ? meta!.en : meta!.km)),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Text(snap == null ? '—' : '${snap!.temp}°', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
