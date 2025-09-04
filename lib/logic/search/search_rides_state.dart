part of 'search_rides_cubit.dart';

enum SearchRidesStatus { initial, loading, loaded, error }

class SearchRidesState extends Equatable {
  final SearchRidesStatus status;
  final List<RideEntity> rides;
  final String? error;
  final bool hasSearched;

  const SearchRidesState({
    this.status = SearchRidesStatus.initial,
    this.rides = const [],
    this.error,
    this.hasSearched = false,
  });

  SearchRidesState copyWith({
    SearchRidesStatus? status,
    List<RideEntity>? rides,
    String? error,
    bool? hasSearched,
  }) {
    return SearchRidesState(
      status: status ?? this.status,
      rides: rides ?? this.rides,
      error: error,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props => [status, rides, error, hasSearched];
}
