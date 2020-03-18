addEventListener("fetch", event => {
  event.respondWith(handler(event));
});

async function handler(event) {
  response = await fetch(new Request(event.request.url.replace("https://r.nichi.co/", "https://"), event.request));
  if (response.status == 302 || response.status == 301) {
    return Response.redirect(response.headers.get("Location").replace("https://", "https://r.nichi.co/"), 302);
  }
  return response;
}
