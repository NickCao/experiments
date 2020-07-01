addEventListener("fetch", event => {
  event.respondWith(handler(event));
});

async function handler(event) {
  let src
  try {
    src = new URL((new URL(event.request.url)).searchParams.get('src'))
  }
  catch (e) {
    return new Response("invalid or missing query param: src", { status: 400 })
  }
  response = await fetch(src, event.request);
  if (response.status == 302 || response.status == 301) {
    return Response.redirect(new URL(response.headers.get("Location"), src), 302);
  }
  response = new Response(response.body, response)
  response.headers.set('Access-Control-Allow-Origin', '*')
  return response;
}

