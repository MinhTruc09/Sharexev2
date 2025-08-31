/// Booking Status Enum - Clean Architecture
enum BookingStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.accepted:
        return 'Đã chấp nhận';
      case BookingStatus.rejected:
        return 'Đã từ chối';
      case BookingStatus.inProgress:
        return 'Đang diễn ra';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.cancelled:
        return 'Đã hủy';
    }
  }

  /// API value for backend communication
  String get value {
    switch (this) {
      case BookingStatus.pending:
        return 'PENDING';
      case BookingStatus.accepted:
        return 'ACCEPTED';
      case BookingStatus.rejected:
        return 'REJECTED';
      case BookingStatus.inProgress:
        return 'IN_PROGRESS';
      case BookingStatus.completed:
        return 'COMPLETED';
      case BookingStatus.cancelled:
        return 'CANCELLED';
    }
  }

  /// Create from API value
  static BookingStatus fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return BookingStatus.pending;
      case 'ACCEPTED':
        return BookingStatus.accepted;
      case 'REJECTED':
        return BookingStatus.rejected;
      case 'IN_PROGRESS':
        return BookingStatus.inProgress;
      case 'COMPLETED':
        return BookingStatus.completed;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        throw ArgumentError('Unknown booking status: $value');
    }
  }

  /// Business logic helpers
  bool get isPending => this == BookingStatus.pending;
  bool get isAccepted => this == BookingStatus.accepted;
  bool get isRejected => this == BookingStatus.rejected;
  bool get isInProgress => this == BookingStatus.inProgress;
  bool get isCompleted => this == BookingStatus.completed;
  bool get isCancelled => this == BookingStatus.cancelled;
  
  bool get isActive => isAccepted || isInProgress;
  bool get isFinished => isCompleted || isCancelled || isRejected;
  bool get canBeCancelled => isPending || isAccepted;
}

/// Extension for BookingStatus
extension BookingStatusX on BookingStatus {
  /// Convert to API value
  String toApiValue() => value;
  
  /// Check if status can transition to another status
  bool canTransitionTo(BookingStatus newStatus) {
    switch (this) {
      case BookingStatus.pending:
        return [BookingStatus.accepted, BookingStatus.rejected, BookingStatus.cancelled].contains(newStatus);
      case BookingStatus.accepted:
        return [BookingStatus.inProgress, BookingStatus.cancelled].contains(newStatus);
      case BookingStatus.inProgress:
        return [BookingStatus.completed, BookingStatus.cancelled].contains(newStatus);
      case BookingStatus.completed:
      case BookingStatus.cancelled:
      case BookingStatus.rejected:
        return false; // Final states
    }
  }
}
