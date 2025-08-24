# Theme Migration Guide

## Mapping từ AppTheme cũ sang Theme mới

### Colors
| AppTheme cũ | Theme mới |
|-------------|-----------|
| `AppTheme.passengerPrimary` | `ThemeManager.getPrimaryColorForRole('PASSENGER')` |
| `AppTheme.driverPrimary` | `ThemeManager.getPrimaryColorForRole('DRIVER')` |
| `AppTheme.getPrimaryColor(role)` | `ThemeManager.getPrimaryColorForRole(role)` |
| `AppTheme.getSecondaryColor(role)` | `ThemeManager.getPrimaryColorForRole(role).withOpacity(0.8)` |
| `AppTheme.getAccentColor(role)` | `ThemeManager.getPrimaryColorForRole(role).withOpacity(0.6)` |
| `AppTheme.getBackgroundColor(role)` | `ThemeManager.getBackgroundColorForRole(role)` |
| `AppTheme.getGradient(role)` | `LinearGradient(colors: [ThemeManager.getPrimaryColorForRole(role), ThemeManager.getPrimaryColorForRole(role).withOpacity(0.8)])` |
| `AppTheme.surface` | `Colors.white` |
| `AppTheme.background` | `Colors.grey[50]` |
| `AppTheme.textPrimary` | `const Color(0xFF212121)` |
| `AppTheme.textSecondary` | `const Color(0xFF757575)` |
| `AppTheme.textHint` | `const Color(0xFF9E9E9E)` |
| `AppTheme.error` | `const Color(0xFFE53E3E)` |
| `AppTheme.success` | `const Color(0xFF38A169)` |
| `AppTheme.warning` | `const Color(0xFFD69E2E)` |
| `AppTheme.info` | `const Color(0xFF3182CE)` |

### Typography
| AppTheme cũ | Theme mới |
|-------------|-----------|
| `AppTheme.headingLarge` | `context.headlineStyle` |
| `AppTheme.headingMedium` | `context.titleStyle` |
| `AppTheme.headingSmall` | `context.subtitleStyle` |
| `AppTheme.bodyLarge` | `context.bodyStyle` |
| `AppTheme.bodyMedium` | `context.bodyStyle` |
| `AppTheme.bodySmall` | `context.captionStyle` |
| `AppTheme.labelLarge` | `context.labelStyle` |
| `AppTheme.labelMedium` | `context.labelStyle` |
| `AppTheme.labelSmall` | `context.captionStyle` |

### Spacing
| AppTheme cũ | Theme mới |
|-------------|-----------|
| `AppTheme.spacingXs` | `4.0` |
| `AppTheme.spacingS` | `8.0` |
| `AppTheme.spacingM` | `16.0` |
| `AppTheme.spacingL` | `24.0` |
| `AppTheme.spacingXl` | `32.0` |
| `AppTheme.spacingXxl` | `48.0` |

### Border Radius
| AppTheme cũ | Theme mới |
|-------------|-----------|
| `AppTheme.radiusS` | `8.0` |
| `AppTheme.radiusM` | `12.0` |
| `AppTheme.radiusL` | `16.0` |
| `AppTheme.radiusXl` | `20.0` |
| `AppTheme.radiusRound` | `50.0` |

### Shadows
| AppTheme cũ | Theme mới |
|-------------|-----------|
| `AppTheme.shadowLight` | `[BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: Offset(0, 2))]` |
| `AppTheme.shadowMedium` | `[BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: Offset(0, 4))]` |
| `AppTheme.shadowHeavy` | `[BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: Offset(0, 8))]` |

## Cách sử dụng Theme mới

### Trong Widget
```dart
// Thay vì
Text('Hello', style: AppTheme.headingMedium)

// Sử dụng
Text('Hello', style: context.titleStyle)

// Hoặc
Text('Hello', style: Theme.of(context).textTheme.titleMedium)
```

### Trong Container/BoxDecoration
```dart
// Thay vì
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.getGradient(role),
    borderRadius: BorderRadius.circular(AppTheme.radiusM),
  ),
)

// Sử dụng
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ThemeManager.getPrimaryColorForRole(role),
        ThemeManager.getPrimaryColorForRole(role).withOpacity(0.8),
      ],
    ),
    borderRadius: BorderRadius.circular(12),
  ),
)
```

### Trong Button
```dart
// Thay vì
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.getPrimaryColor(role),
  ),
)

// Sử dụng
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: ThemeManager.getPrimaryColorForRole(role),
  ),
)
```

## Files cần cập nhật

Các file sau đây cần được cập nhật để sử dụng theme mới:

1. `lib/presentation/widgets/trip/driver_avatar_button.dart`
2. `lib/presentation/widgets/trip/trip_summary_section.dart`
3. `lib/presentation/widgets/splash_content.dart`
4. `lib/presentation/widgets/trip/trip_seat_selection_section.dart`
5. `lib/presentation/widgets/trip/trip_review_section.dart`
6. `lib/presentation/widgets/trip/trip_map_section.dart`
7. `lib/presentation/widgets/booking/vehicle_seat_selection_bloc.dart`
8. `lib/presentation/pages/authflow/login_page.dart`
9. `lib/presentation/pages/profile/profile_page.dart`
10. `lib/presentation/pages/trip/trip_detail_page.dart`
11. Và nhiều file khác...

## Quy trình cập nhật

1. Thay thế import: `import 'package:sharexev2/config/role_theme.dart'` → `import 'package:sharexev2/config/theme.dart'`
2. Thay thế các reference `AppTheme.` theo mapping table ở trên
3. Sử dụng `context.` extension methods khi có thể
4. Test để đảm bảo UI hiển thị đúng
