addEventListener("fetch", event => {
    event.respondWith(handler(event.request));
});

String.prototype.fixScheme = function () {
    return this.replace(/(?<=^https?:)\/(?!\/)/, '//')
};

async function handler(request) {
    let origin = (new URL(request.url)).origin
    let real_url = request.url.substr(origin.length + 1).fixScheme()

    response = await fetch(real_url, request);
    if (response.status == 302 || response.status == 301) {
        let target_url = (new URL(response.headers.get("Location"), real_url)).href
        return Response.redirect(origin + '/' + target_url, 302)
    }

    response = new Response(response.body, response)
    response.headers.set('Access-Control-Allow-Origin', '*')
    response.headers.set('X-REQUEST-URL', request.url)
    response.headers.set('X-REAL-URL', real_url)
    return response;
}

