/// Booking status chung cho cả Booking và PassengerInfo
enum BookingStatus {
  pending,
  accepted,
  inProgress,
  passengerConfirmed,
  driverConfirmed,
  completed,
  cancelled,
  rejected,
}

extension BookingStatusX on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return "PENDING";
      case BookingStatus.accepted:
        return "ACCEPTED";
      case BookingStatus.inProgress:
        return "IN_PROGRESS";
      case BookingStatus.passengerConfirmed:
        return "PASSENGER_CONFIRMED";
      case BookingStatus.driverConfirmed:
        return "DRIVER_CONFIRMED";
      case BookingStatus.completed:
        return "COMPLETED";
      case BookingStatus.cancelled:
        return "CANCELLED";
      case BookingStatus.rejected:
        return "REJECTED";
    }
  }

  /// parse từ string sang enum
  static BookingStatus fromString(String status) {
    switch (status) {
      case "PENDING":
        return BookingStatus.pending;
      case "ACCEPTED":
        return BookingStatus.accepted;
      case "IN_PROGRESS":
        return BookingStatus.inProgress;
      case "PASSENGER_CONFIRMED":
        return BookingStatus.passengerConfirmed;
      case "DRIVER_CONFIRMED":
        return BookingStatus.driverConfirmed;
      case "COMPLETED":
        return BookingStatus.completed;
      case "CANCELLED":
        return BookingStatus.cancelled;
      case "REJECTED":
        return BookingStatus.rejected;
      default:
        return BookingStatus.pending; // fallback
    }
  }
}
