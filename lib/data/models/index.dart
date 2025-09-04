// Models Index - Clean Architecture Export

// ========== ENTITIES (Business Objects) ==========
export 'auth/entities/index.dart';
export 'booking/entities/index.dart';
export 'chat/entities/index.dart';
export 'notification/entities/index.dart';
export 'ride/entities/index.dart';
export 'tracking/entities/index.dart';

// ========== DTOs (Data Transfer Objects) ==========
export 'auth/dtos/index.dart';
export 'booking/dtos/booking_dto.dart';
export 'booking/dtos/vehicle_dto.dart';
export 'booking/dtos/passenger_info_dto.dart';
export 'chat/dtos/chat_message_dto.dart';
export 'chat/dtos/chat_room_dto.dart';
export 'notification/dtos/notification_dto.dart';
export 'tracking/dtos/location_dto.dart';
export 'tracking/dtos/tracking_payload_dto.dart';

// ========== MAPPERS (DTO ↔ Entity Conversion) ==========
export 'auth/mappers/index.dart';
export 'booking/mappers/index.dart';
export 'chat/mappers/index.dart';
export 'notification/mappers/index.dart';
export 'ride/mappers/index.dart';
export 'tracking/mappers/index.dart';

// ========== VALUE OBJECTS ==========
export 'auth/value_objects/email.dart';
export 'auth/value_objects/phone_number.dart';

// ========== LEGACY (Backward Compatibility) ==========
export 'auth/app_user.dart';
