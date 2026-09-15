'use strict';

const CACHE = 'khmer-calendar-web-v1';
const PRECACHE = [
  './',
  './index.html',
  './main.dart.js',
  './flutter.js',
  './flutter_bootstrap.js',
  './manifest.json',
  './favicon.png',
  './version.json',
  './offline.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE)
      .then((cache) => cache.addAll(PRECACHE))
      .then(() => self.skipWaiting())
      .catch(() => self.skipWaiting()),
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

function isWeather(url) {
  return url.hostname.endsWith('open-meteo.com');
}

function isCanvasKit(url) {
  return url.hostname === 'www.gstatic.com' && url.pathname.includes('flutter-canvaskit');
}

function shouldHandle(url) {
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return false;
  if (url.hostname === 'grok.com') return false;
  return url.origin === self.location.origin || isCanvasKit(url) || isWeather(url);
}

async function cacheFirst(request, fallbackIndex) {
  const cached = await caches.match(request);
  if (cached) {
    fetchAndStore(request);
    return cached;
  }
  try {
    const res = await fetch(request);
    store(request, res);
    return res;
  } catch (e) {
    if (fallbackIndex) {
      const index = await caches.match('./index.html');
      if (index) return index;
      const root = await caches.match('./');
      if (root) return root;
    }
    throw e;
  }
}

async function networkFirst(request) {
  try {
    const res = await fetch(request);
    store(request, res);
    return res;
  } catch (e) {
    const cached = await caches.match(request);
    if (cached) return cached;
    throw e;
  }
}

function store(request, res) {
  if (!res || !(res.ok || res.type === 'opaque')) return;
  const copy = res.clone();
  caches.open(CACHE).then((cache) => cache.put(request, copy)).catch(() => {});
}

function fetchAndStore(request) {
  fetch(request)
    .then((res) => store(request, res))
    .catch(() => {});
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (!shouldHandle(url)) return;
  if (isWeather(url)) {
    event.respondWith(networkFirst(request));
    return;
  }
  const nav = request.mode === 'navigate' || url.pathname === '/' || url.pathname.endsWith('/index.html');
  event.respondWith(cacheFirst(request, nav));
});
