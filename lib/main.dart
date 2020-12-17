import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/directions.dart' as direction;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Harita(),
    );
  }
}

class Harita extends StatefulWidget {
  @override
  _HaritaState createState() => _HaritaState();
}

class _HaritaState extends State<Harita> {
  bool izinAlindi = false;
  List<Polyline> polyLines;
  List<LatLng> noktalar;
  GoogleMap map =
      GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(0, 0)));
  direction.GoogleMapsDirections directions = direction.GoogleMapsDirections(
      apiKey: "AIzaSyC2TRVqnMgCx5b2pFm3Cn88io8lsp6NGu4");
  @override
  void initState() {
    super.initState();

    polyLines = List<Polyline>();
    noktalar = List<LatLng>();

    polyLines.add(Polyline(
        polylineId: PolylineId("ilk"),
        color: Colors.blue,
        width: 5,
        geodesic: true,
        points: noktalar));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Harita"),
      ),
      body: GoogleMap(
        initialCameraPosition:
            CameraPosition(target: LatLng(40.2, 28.8), zoom: 9),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: Set<Polyline>.of(polyLines),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          direction.Waypoint waypoint =
              direction.Waypoint.fromAddress("Antalya");
          List<direction.Waypoint> waypointListe = List<direction.Waypoint>();
          waypointListe.add(waypoint);

          directions
              .directionsWithAddress("Bursa", "Ağrı", waypoints: waypointListe)
              .then((value) {
            _polyLineCiz(value);
          });
        },
      ),
    );
  }

  void _polyLineCiz(direction.DirectionsResponse value) {
    List<LatLng> keskinNoktalar = List<LatLng>();
    for (var item in value.routes[0].legs[0].steps) {
      keskinNoktalar.addAll(decodeEncodedPolyline(item.polyline.points));
    }
    for (var item in value.routes[0].legs[1].steps) {
      keskinNoktalar.addAll(decodeEncodedPolyline(item.polyline.points));
    }

    setState(() {
      noktalar.addAll(keskinNoktalar);
    });
  }

//decode metodu
  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = new LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }
}
