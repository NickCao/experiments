var encodings = {
  '\+': "%2B",
  '\!': "%21",
  '\"': "%22",
  '\#': "%23",
  '\$': "%24",
  '\&': "%26",
  '\'': "%27",
  '\(': "%28",
  '\)': "%29",
  '\*': "%2A",
  '\,': "%2C",
  '\:': "%3A",
  '\;': "%3B",
  '\=': "%3D",
  '\?': "%3F",
  '\@': "%40",
};

function encodeS3URI(filename) {
  return encodeURI(filename)
    .replace(/(\+|!|"|#|\$|&|'|\(|\)|\*|\+|,|:|;|=|\?|@)/img,
      function (match) { return encodings[match]; });
}

exports.handler = async (event, context, callback) => {
  const request = event.Records[0].cf.request;
  if (request.uri.endsWith("/")) {
    request.uri += "index.html"
  }
  request.uri = encodeS3URI(request.uri)
  callback(null, request);
};