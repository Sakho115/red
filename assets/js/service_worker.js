const CACHE_NAME = 'enghub-offline-v1';
const URLS_TO_CACHE = [
    '/',
    '/assets/app.js',
    '/assets/app.css'
];

self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(URLS_TO_CACHE))
    );
});

self.addEventListener('fetch', event => {
    // Implement offline-first caching strategy
    // Use IndexedDB to sync data modifications made offline back to the Phoenix Server.
    event.respondWith(
        caches.match(event.request)
            .then(response => response || fetch(event.request))
    );
});
