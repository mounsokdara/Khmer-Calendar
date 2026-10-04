import 'package:flutter/material.dart';

import '../home_screen.dart';
import '../i18n.dart';
import '../location.dart';
import '../net.dart';
import '../store.dart';
import '../theme.dart';
import '../weather.dart';
import '../widgets/overlay_page.dart';
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
  bool _gpsBusy = false;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStore);
    NetStatus.online.addListener(_onStore);
    _refresh();
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStore);
    NetStatus.online.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  Future<void> _refresh() async {
    if (NetStatus.isOffline) {
      if (mounted) setState(() => _loading = false);
      return;
    }
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
    await pushWeatherList(widget.store, _cache);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return WatchStore(
      store: widget.store,
      builder: (context, store) {
        final lang = store.lang;
        if (NetStatus.isOffline) {
          return _WeatherOffline(
            lang: lang,
            onRetry: () {
              setState(() {});
              _refresh();
            },
          );
        }
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
                onPressed: _gpsBusy ? null : _nearMe,
                icon: _gpsBusy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        if (_loading) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: store.weatherCities.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(t(lang, 'noCity'), textAlign: TextAlign.center),
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
                          onOpen: () {
                            pushWeatherList(widget.store, _cache, selectId: id);
                            _openCity(city, snap);
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
        );
      },
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
    setState(() => _gpsBusy = true);
    final r = await requestNearbyCity(widget.store);
    if (!mounted) return;
    setState(() => _gpsBusy = false);
    if (!context.mounted) return;
    showGpsSnack(context, widget.store.lang, r);
    if (r == GpsResult.added || r == GpsResult.already) await _refresh();
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
                  child: SizedBox(height: 140, width: double.infinity, child: CloudPhoto(city: city)),
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
                    height: 108,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final h in snap.hourly)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Text(h.time.substring(11, 16)),
                                Image.network(
                                  wmoIconUrl(h.code),
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (_, _, _) => Icon(wxMaterialIcon(h.code), size: 28),
                                ),
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
                      leading: Image.network(
                        wmoIconUrl(d.code),
                        width: 36,
                        height: 36,
                        errorBuilder: (_, _, _) => Icon(wxMaterialIcon(d.code), size: 32),
                      ),
                      title: Text(d.date),
                      subtitle: Text(lang == Lang.en ? wmoOf(d.code).en : wmoOf(d.code).km),
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
            Positioned.fill(child: CloudPhoto(city: city)),
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
                  Text(snap == null ? '-' : '${snap!.temp}°', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600)),
                  if (snap != null)
                    Image.network(
                      wmoIconUrl(snap!.code),
                      width: 48,
                      height: 48,
                      errorBuilder: (_, _, _) => Icon(wxMaterialIcon(snap!.code), size: 40, color: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData wxMaterialIcon(int code) {
  if (code <= 1) return Icons.wb_sunny;
  if (code <= 3) return Icons.cloud;
  if (code <= 48) return Icons.dehaze;
  if (code <= 86) return Icons.umbrella;
  return Icons.flash_on;
}

class CloudPhoto extends StatelessWidget {
  const CloudPhoto({super.key, required this.city});
  final City city;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: cityPhotoUrl(city),
      builder: (context, snap) {
        final url = snap.data;
        if (url == null || url.isEmpty) {
          return Container(
            color: const Color(0xFF38618D),
            alignment: Alignment.center,
            child: const Icon(Icons.location_city, color: Colors.white54, size: 48),
          );
        }
        return Image.network(
          url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => Container(color: const Color(0xFF38618D)),
        );
      },
    );
  }
}

class _WeatherOffline extends StatelessWidget {
  const _WeatherOffline({required this.lang, required this.onRetry});
  final Lang lang;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: cs.outline),
            const SizedBox(height: 16),
            Text(t(lang, 'wxOfflineTitle'), style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(t(lang, 'wxOfflineBody'), textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onRetry, child: Text(t(lang, 'wxRetry'))),
          ],
        ),
      ),
    );
  }
}

