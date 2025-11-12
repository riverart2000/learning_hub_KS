'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "35982c9e81a15f99227cda79dd8bf476",
"version.json": "8523ea1602ad82c7852671723789aa1c",
"index.html": "4767280cc5cd4f0fa8a585ba0894d86d",
"/": "4767280cc5cd4f0fa8a585ba0894d86d",
"main.dart.js": "6eae1adfce65dab514655b0247c9b26a",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"favicon.png": "a2a75d04e88df9f423b53f3b3b923442",
"icons/Icon-192.png": "35e845ab929f8975a3d3516800d74865",
"icons/Icon-maskable-192.png": "35e845ab929f8975a3d3516800d74865",
"icons/Icon-maskable-512.png": "3390dc9d9dd87494e54bbc6c6d9904fc",
"icons/Icon-512.png": "3390dc9d9dd87494e54bbc6c6d9904fc",
"manifest.json": "edba5b395f411135e6a11c6e1c9d0aac",
"firebase-config.js": "542d4a15c5f52aafb52fdc450d01d1a6",
"assets/AssetManifest.json": "2d87fc057a0b22c061621fd05e3da673",
"assets/NOTICES": "cea0e879a23ef793196ca99fa4bd7421",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "928b81cdf20e2e9d922059a847518916",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "f1316216d134cf287659553f34028d3e",
"assets/fonts/MaterialIcons-Regular.otf": "da5e361374b636238b021513deb9b531",
"assets/assets/data/kashmir_shaivism_36_tattvas_advanced.json": "677625742cadf93d127c692aabc39059",
"assets/assets/data/tantra_yoga_chakras.json": "909d611a6c2c8e32d6c571f3fbe91b00",
"assets/assets/data/kashmir_shaivism_sanskrit_advanced.json": "639f7be57571bb7d3154fc4b6f3ed413",
"assets/assets/data/kashmir_shaivism_sanskrit_terms_advanced.json": "16b2e923933387bd87838cb6554beba7",
"assets/assets/data/tantra_yoga_sanskrit_asana_names.json": "15ae721a39570237664e3b1ca39f0d4f",
"assets/assets/data/motivational_quotes.json": "e6c79555e942fb47792f648434396136",
"assets/assets/data/kashmir_shaivism_anavopaya.json": "a7b021ee7b288160e84d187758019a25",
"assets/assets/data/kashmir_shaivism_sambhavopaya.json": "655d1120eb458003bbe9a18b004f0efc",
"assets/assets/data/tantra_yoga_fundamentals.json": "0e4c9f11b3a64a8ce1dbbef4bd3cd456",
"assets/assets/data/kashmir_shaivism_sanskrit_terms.json": "201e7683d7e72cb9157fdb676653badf",
"assets/assets/data/tantra_yoga_philosophy.json": "7390d78749896aa3221c646112987757",
"assets/assets/data/manifest.json": "84f5a7d9aeb75628ba5586fb9bb65497",
"assets/assets/data/kashmir_shaivism_saktopaya.json": "d4a37ce75a56ed0b5600dfbe3c676529",
"assets/assets/data/kashmir_shaivism_anupaya.json": "b8a811e9d05b5864d3ec0918d1977256",
"assets/assets/data/kashmir_shaivism_36_tattvas_fundamentals.json": "43e6bed9b123ace61fdeb00617b74119",
"assets/assets/data/LearninghubLogo.png": "17159a916b11b54b2e602dc6445bd1d9",
"assets/assets/data/kashmir_shaivism_sanskrit_fundamentals.json": "252347e617ee2c99e1c5de7703ddf860",
"assets/assets/data/google-services.json": "2031e1155c144fca1fbc4bc39ce71564",
"assets/assets/data/tantra_yoga_asanas.json": "2a5e3166e9d22f883e6815e3929c8d7a",
"assets/assets/data/app_config.json": "96b0bb4a7186de1c6ef6b2d7f9e1ad51",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
