part of "main.dart";

Future<http.Response> callBackend(path, params) async {
  Uri apiUrl = new Uri(
      scheme: 'http',
      host: '127.0.0.1',
      path: "api/mobility-platform/" + path,
      queryParameters: params);

  print(apiUrl);

  return await http.post(apiUrl, body: params);
}

acceptOffer(offerId) async {
  var resp =
      await callBackend('mobile/accept-proposed-offer', {offerId: offerId});
  return json.decode(resp.body);
}

declineOffer(offerId) async {
  var resp =
      await callBackend('mobile/decline-proposed-offer', {offerId: offerId});
  return json.decode(resp.body);
}

startUsage(offerId) async {
  var resp =
      await callBackend('mobile/decline-proposed-offer', {offerId: offerId});
  return json.decode(resp.body);
}
