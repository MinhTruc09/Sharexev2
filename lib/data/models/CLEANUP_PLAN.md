# Models Directory Cleanup Plan

## Issues Found:
1. **Duplicate Booking Models**: `booking.dart` vs `booking_entity.dart`
2. **Duplicate Chat Message Models**: `chat_message.dart` vs `chat_message_entity.dart`
3. **Duplicate Booking Status**: Two different `booking_status.dart` files
4. **Duplicate Ride Models**: `ride.dart` vs `ride_entity.dart`
5. **Empty API directory**: `auth/api/` is empty
6. **Inconsistent naming**: Some files use `Entity` suffix, others don't
7. **Legacy files**: Old model files that should be removed

## Cleanup Actions:

### 1. Remove Duplicate Files
- [ ] Remove `lib/data/models/booking/entities/booking.dart` (keep `booking_entity.dart`)
- [ ] Remove `lib/data/models/chat/entities/chat_message.dart` (keep `chat_message_entity.dart`)
- [ ] Remove `lib/data/models/ride/ride.dart` (keep `ride_entity.dart`)
- [ ] Remove `lib/data/models/booking/dtos/booking_status.dart` (keep main `booking_status.dart`)
- [ ] Remove empty `lib/data/models/auth/api/` directory

### 2. Standardize Naming Convention
- [ ] Ensure all entity files use `Entity` suffix
- [ ] Ensure all DTO files use `Dto` suffix
- [ ] Ensure all mapper files use `Mapper` suffix

### 3. Update Index Files
- [ ] Update all `index.dart` files to export only the correct files
- [ ] Update main `index.dart` to remove references to deleted files

### 4. Verify Consistency
- [ ] Check all imports are working correctly
- [ ] Ensure no broken references
- [ ] Test compilation

## Final Structure:
```
lib/data/models/
├── index.dart
├── auth/
│   ├── entities/
│   ├── dtos/
│   ├── mappers/
│   └── value_objects/
├── booking/
│   ├── entities/
│   ├── dtos/
│   └── mappers/
├── chat/
│   ├── entities/
│   ├── dtos/
│   └── mappers/
├── notification/
│   ├── entities/
│   ├── dtos/
│   └── mappers/
├── ride/
│   ├── entities/
│   ├── dtos/
│   └── mappers/
└── tracking/
    ├── entities/
    ├── dtos/
    └── mappers/
```
