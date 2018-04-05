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
        var resp = await _graphqlClient.runQuery(query, {
          "token": jwt,
        });
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
            } else {
              throw new AssertionError("No bookings returned");
            }
          } else {
            throw new AssertionError("No data returned");
          }
        });
      }
    } catch (error, stack) {
      Scaffold.of(context).showSnackBar(
            new SnackBar(
              content: new Text("Something went wrong"),
            ),
          );
      if (const bool.fromEnvironment("dart.vm.product")) {
        await sentry.captureException(
          exception: error,
          stackTrace: stack,
        );
      }
    }
  }

  @override
  initState() {
    super.initState();

    _getBookings();
  }

  Widget build(BuildContext context) {
    var cards = [];

    _bookings.forEach((v) {
      cards.add(
        new GestureDetector(
          child: new BookingCard(v),
        ),
      );
    });

    return new RefreshIndicator(
      onRefresh: _getBookings,
      child: new SafeArea(
        child: new ListView(
          children: cards,
        ),
      ),
    );
  }
}

class BookingCard extends StatefulWidget {
  final Booking booking;

  BookingCard(this.booking);

  @override
  BookingCardState createState() => new BookingCardState();
}

class BookingCardState extends State<BookingCard>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _makeBookingCard(Booking booking) {
    Widget formatDate(DateTime start, DateTime end) {
      var format = new DateFormat("yMMMEd");
      var startText = format.format(start);
      var endText = format.format(end);

      return new Text(startText + " - " + endText);
    }

    Size screenSize = MediaQuery.of(context).size;

    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          new Hero(
            tag: 'booking_' + booking.id.toString(),
            child: new Image.asset(
              "images/hotel.jpg",
              height: screenSize.height / 3,
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
                  onPressed: _openBooking,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openBooking() {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (_) => new BookingPage(
            booking: widget.booking,
          ),
        ),
      );
  }

  Widget build(BuildContext context) {
    final animation = new Tween(
            begin: const Offset(0.0, 0.0), end: const Offset(-0.2, 0.0))
        .animate(new CurveTween(curve: Curves.decelerate).animate(_controller));
    return new GestureDetector(
      onHorizontalDragUpdate: (data) {
        setState(() {
          _controller.value -= data.primaryDelta / context.size.width;
        });
      },
      onHorizontalDragEnd: (data) {
        if (data.primaryVelocity > 2500) {
          _controller.animateTo(.0);
        } else if (_controller.value >= .5 || data.primaryVelocity < -2500) {
          _controller.animateTo(1.0);
          _openBooking();
        } else {
          _controller.animateTo(.0);
        }
      },
      child: new SlideTransition(
          position: animation, child: _makeBookingCard(widget.booking)),
    );
  }
}
