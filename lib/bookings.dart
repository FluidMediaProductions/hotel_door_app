import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';
import 'graphql.dart';
import 'utils.dart';
import 'consts.dart';
import 'booking.dart';
import 'data_types.dart';

class Bookings extends StatefulWidget {
  @override
  BookingsState createState() => new BookingsState();
}

class BookingsState extends State<Bookings> {
  final _graphqlClient = new GraphQLClient(GRAPHQL_SERVER_URL);

  List<Booking> _bookings = [];

  _getBookings() async {
    try {
    String jwt = await getJwt();
    if (jwt != null) {
      String query = "query (\$token: String!) {\n"
          "  auth(token: \$token) {\n"
          "    self {\n"
          "      bookings {\n"
          "        ID\n"
          "        start\n"
          "        end\n"
          "        hotel {\n"
          "          ID\n"
          "          name\n"
          "        }\n"
          "        room {\n"
          "          ID\n"
          "        }"
          "      }\n"
          "    }\n"
          "  }\n"
          "}";
      _graphqlClient.runQuery(query, {
        "token": jwt,
      }).then((resp) {
        setState(() {
          _bookings = [];

          if (resp["data"]["auth"] != null) {
            List<Map<String, dynamic>> bookings =
                resp["data"]["auth"]["self"]["bookings"];
            if (bookings != null) {
              bookings.forEach((v) {
                var hotel = new Hotel(
                  id: v["hotel"]["ID"],
                  name: v["hotel"]["name"],
                );
                var room = new Room(
                  id: v["room"]["ID"],
                );
                _bookings.add(new Booking(
                  id: v["ID"],
                  start: DateTime.parse(v["start"]),
                  end: DateTime.parse(v["end"]),
                  hotel: hotel,
                  room: room,
                ));
              });
            }
          }
        });
      });
    }

    } catch (error, stack) {
      Scaffold.of(context).showSnackBar(
        new SnackBar(
          content: new Text("Something went wrong"),
        ),
      );
      await sentry.captureException(
        exception: error,
        stackTrace: stack,
      );
    }
  }

  Widget _makeBookingCard(Booking booking) {
    Widget formatDate(DateTime start, DateTime end) {
      var format = new DateFormat("yMMMEd");
      var startText = format.format(start);
      var endText = format.format(end);

      return new Text(startText + " - " + endText);
    }

    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          new Hero(
            tag: 'booking_' + booking.id.toString(),
            child: new Image.asset(
              "images/hotel.jpg",
              height: 150.0,
              fit: BoxFit.cover,
            ),
          ),
          new ListTile(
            title: new Text(booking.hotel.name),
            subtitle: formatDate(booking.start, booking.end),
          ),
          new ButtonTheme.bar(
            child: new ButtonBar(
              children: [
                new FlatButton(
                  child: const Text('VIEW'),
                  onPressed: () {
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (_) =>
                        new BookingPage(
                          booking: booking,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  initState() {
    super.initState();

    _getBookings();
  }

  Widget build(BuildContext context) {
    var cards = [];

    _bookings.forEach((v) {
      cards.add(_makeBookingCard(v));
    });

    return new RefreshIndicator(
      onRefresh: _getBookings,
      child: new ListView(
        children: cards,
      ),
    );
  }
}
