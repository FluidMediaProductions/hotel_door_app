import 'package:flutter/foundation.dart';

class Booking {
  final int id;
  final DateTime start;
  final DateTime end;
  final Hotel hotel;
  final Room room;

  Booking({@required this.id, this.start, this.end, this.hotel, this.room});
}

class Hotel {
  final int id;
  final String name;
  final DateTime checkIn;
  final String address;

  Hotel({@required this.id, this.name, this.checkIn, this.address});
}

class Room {
  final int id;
  final String name;
  final String floor;

  Room({@required this.id, this.name, this.floor});
}