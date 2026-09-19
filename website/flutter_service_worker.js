'use strict';

const CACHE = 'khmer-calendar-web-1789803707436';
const PRECACHE = [
  "./_redirects",
  "./assets/AssetManifest.bin",
  "./assets/AssetManifest.bin.json",
  "./assets/FontManifest.json",
  "./assets/NOTICES",
  "./assets/assets/fonts/KantumruyPro.ttf",
  "./assets/assets/icons/apple-touch-icon.png",
  "./assets/assets/icons/icon-192.png",
  "./assets/assets/icons/icon-512.png",
  "./assets/assets/os/android.svg",
  "./assets/assets/os/linux.svg",
  "./assets/assets/os/macos.svg",
  "./assets/assets/os/windows.svg",
  "./assets/assets/zodiac/dog.svg",
  "./assets/assets/zodiac/dragon.svg",
  "./assets/assets/zodiac/goat.svg",
  "./assets/assets/zodiac/horse.svg",
  "./assets/assets/zodiac/monkey.svg",
  "./assets/assets/zodiac/ox.svg",
  "./assets/assets/zodiac/pig.svg",
  "./assets/assets/zodiac/rabbit.svg",
  "./assets/assets/zodiac/rat.svg",
  "./assets/assets/zodiac/rooster.svg",
  "./assets/assets/zodiac/snake.svg",
  "./assets/assets/zodiac/tiger.svg",
  "./assets/fonts/MaterialIcons-Regular.otf",
  "./assets/fonts/fallback/Roboto-Regular.ttf",
  "./assets/packages/cupertino_icons/assets/CupertinoIcons.ttf",
  "./assets/shaders/ink_sparkle.frag",
  "./assets/shaders/stretch_effect.frag",
  "./canvaskit/canvaskit.js",
  "./canvaskit/canvaskit.js.symbols",
  "./canvaskit/canvaskit.wasm",
  "./canvaskit/chromium/canvaskit.js",
  "./canvaskit/chromium/canvaskit.js.symbols",
  "./canvaskit/chromium/canvaskit.wasm",
  "./canvaskit/skwasm.js",
  "./canvaskit/skwasm.js.symbols",
  "./canvaskit/skwasm.wasm",
  "./canvaskit/skwasm_heavy.js",
  "./canvaskit/skwasm_heavy.js.symbols",
  "./canvaskit/skwasm_heavy.wasm",
  "./canvaskit/webparagraph/canvaskit.js",
  "./canvaskit/webparagraph/canvaskit.js.symbols",
  "./canvaskit/webparagraph/canvaskit.wasm",
  "./canvaskit/wimp.js",
  "./canvaskit/wimp.js.symbols",
  "./canvaskit/wimp.wasm",
  "./favicon.png",
  "./flutter.js",
  "./flutter_bootstrap.js",
  "./flutter_service_worker.js",
  "./icons/Icon-192.png",
  "./icons/Icon-512.png",
  "./icons/Icon-maskable-192.png",
  "./icons/Icon-maskable-512.png",
  "./index.html",
  "./main.dart.js",
  "./manifest.json",
  "./offline.js",
  "./og.jpg",
  "./version.json"
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE)
      .then((cache) =>
        Promise.all(
          PRECACHE.map((url) => cache.add(url).catch(() => {})),
        ),
      )
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)));
      await self.clients.claim();
    })(),
  );
});

function isWeatherApi(url) {
  return url.hostname.endsWith('open-meteo.com');
}

function shouldHandle(url) {
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return false;
  if (url.hostname === 'grok.com') return false;
  if (isWeatherApi(url)) return true;
  return url.origin === self.location.origin;
}

async function cacheFirst(request, fallbackIndex) {
  const cached = await caches.match(request, { ignoreSearch: true });
  if (cached) return cached;
  try {
    const res = await fetch(request);
    store(request, res);
    return res;
  } catch (e) {
    if (fallbackIndex) {
      const index = (await caches.match('./index.html')) || (await caches.match('./'));
      if (index) return index;
    }
    throw e;
  }
}

async function networkOnly(request) {
  return fetch(request);
}

function store(request, res) {
  if (!res || !(res.ok || res.type === 'opaque')) return;
  const copy = res.clone();
  caches.open(CACHE).then((cache) => cache.put(request, copy)).catch(() => {});
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (!shouldHandle(url)) return;
  if (isWeatherApi(url)) {
    event.respondWith(networkOnly(request));
    return;
  }
  const nav = request.mode === 'navigate' || url.pathname === '/' || url.pathname.endsWith('/index.html');
  event.respondWith(cacheFirst(request, nav));
});

self.addEventListener('message', (event) => {
  const d = event.data;
  if (!d || d.type !== 'khmer-notify') return;
  event.waitUntil(
    self.registration.showNotification(d.title || 'Khmer Calendar', {
      body: d.body || '',
      icon: './icons/Icon-192.png',
      badge: './favicon.png',
      tag: d.tag || 'khmer-reminder',
    }),
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((list) => {
      for (const c of list) {
        if (c.url && 'focus' in c) return c.focus();
      }
      return self.clients.openWindow('./');
    }),
  );
});
