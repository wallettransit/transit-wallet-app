import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupRideDraft {
  final String pickupLocation;
  final String destination;
  final int capacity;
  final double farePerPerson;

  GroupRideDraft({
    this.pickupLocation = '',
    this.destination = '',
    this.capacity = 4,
    this.farePerPerson = 0.0,
  });

  GroupRideDraft copyWith({
    String? pickupLocation,
    String? destination,
    int? capacity,
    double? farePerPerson,
  }) {
    return GroupRideDraft(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destination: destination ?? this.destination,
      capacity: capacity ?? this.capacity,
      farePerPerson: farePerPerson ?? this.farePerPerson,
    );
  }
}

class GroupRideDraftNotifier extends StateNotifier<GroupRideDraft> {
  GroupRideDraftNotifier() : super(GroupRideDraft());

  void setPickup(String location) {
    state = state.copyWith(pickupLocation: location);
  }

  void setDestination(String location) {
    state = state.copyWith(destination: location);
  }

  void setCapacity(int capacity) {
    state = state.copyWith(capacity: capacity);
  }

  void setFare(double fare) {
    state = state.copyWith(farePerPerson: fare);
  }
  
  void reset() {
    state = GroupRideDraft();
  }
}

final groupRideDraftProvider = StateNotifierProvider<GroupRideDraftNotifier, GroupRideDraft>((ref) {
  return GroupRideDraftNotifier();
});
