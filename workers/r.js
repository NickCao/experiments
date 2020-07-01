addEventListener("fetch", event => {
    event.respondWith(handler(event.request));
});

async function handler(request) {
    let url
    try {
        url = new URL((new URL(request.url)).pathname.substr(1).replace(/(?<=^https?:)\/(?!\/)/, '//'))
    } catch {
        return new Response('invalid url', { status: 400 })
    }

    response = await fetch(url, request);
    if (response.status == 302 || response.status == 301) {
        return Response.redirect((new URL(request.url)).origin.
            concat('/').
            concat(new URL(response.headers.get("Location"), url), 302))
    }
    response = new Response(response.body, response)
    response.headers.set('Access-Control-Allow-Origin', '*')
    response.headers.set('X-REAL-URL', url)
    return response;
}

