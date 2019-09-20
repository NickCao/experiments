addEventListener("fetch", event => {
  let url = new URL(event.request.url);
  url.hostname = event.request.headers.get('X-BOUNCER-HOST');
  request = new Request(url, event.request);
  event.respondWith(fetch(request));
})
