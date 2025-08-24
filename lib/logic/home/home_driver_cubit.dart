import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_driver_state.dart';

class HomeDriverCubit extends Cubit<HomeDriverState> {
  HomeDriverCubit() : super(const HomeDriverState());

  Future<void> init() async {
    emit(state.copyWith(status: HomeDriverStatus.loading));
    try {
      // TODO: load driver profile, available rides, location
      emit(state.copyWith(status: HomeDriverStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: HomeDriverStatus.error, error: e.toString()));
    }
  }
}

