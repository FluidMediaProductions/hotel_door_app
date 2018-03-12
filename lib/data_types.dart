class Booking {
  final int id;
  final DateTime start;
  final DateTime end;
  final Hotel hotel;

  Booking({this.id, this.start, this.end, this.hotel});
}

class Hotel {
  final int id;
  final String name;
  final DateTime checkIn;
  final String address;

  Hotel({this.id, this.name, this.checkIn, this.address});
}