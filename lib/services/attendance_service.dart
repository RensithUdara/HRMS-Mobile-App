import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/attendance_model.dart';
import '../services/firestore_service.dart';
import '../utils/exceptions.dart';

/// Attendance service for managing employee attendance
class AttendanceService {
  final FirestoreService _firestoreService = FirestoreService();

  // Office location coordinates (example: Colombo, Sri Lanka)
  static const double officeLatitude = 6.9271;
  static const double officeLongitude = 79.8612;
  static const double allowedDistanceMeters = 100.0; // 100 meters radius

  /// Check-in employee
  Future<AttendanceModel> checkIn({
    required String employeeId,
    required String employeeName,
    AttendanceMethod method = AttendanceMethod.manual,
    String? qrCode,
    bool isWorkFromHome = false,
  }) async {
    try {
      // Check if already checked in today
      final todayAttendance =
          await _firestoreService.getTodayAttendance(employeeId);
      if (todayAttendance != null && todayAttendance.checkInTime != null) {
        throw const BusinessLogicException('Already checked in today');
      }

      Position? position;
      String? location;

      if (!isWorkFromHome && method == AttendanceMethod.gps) {
        // Get location for GPS check-in
        position = await _getCurrentLocation();
        location = await _getLocationName(position);

        // Verify location is within office premises
        if (!_isWithinOfficeRadius(position)) {
          throw const LocationException(
              'You are not within the office premises');
        }
      }

      final now = DateTime.now();
      final attendanceRecord = AttendanceModel(
        id: '${employeeId}_${now.year}_${now.month}_${now.day}',
        employeeId: employeeId,
        employeeName: employeeName,
        date: DateTime(now.year, now.month, now.day),
        checkInTime: now,
        checkInMethod: method,
        checkInLocation: location,
        checkInLatitude: position?.latitude,
        checkInLongitude: position?.longitude,
        status: _determineAttendanceStatus(now, isWorkFromHome),
        isWorkFromHome: isWorkFromHome,
        breaks: const [],
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      if (todayAttendance == null) {
        await _firestoreService.createAttendanceRecord(attendanceRecord);
      } else {
        final updatedRecord = todayAttendance.copyWith(
          checkInTime: now,
          checkInMethod: method,
          checkInLocation: location,
          checkInLatitude: position?.latitude,
          checkInLongitude: position?.longitude,
          status: _determineAttendanceStatus(now, isWorkFromHome),
          isWorkFromHome: isWorkFromHome,
          updatedAt: now,
        );
        await _firestoreService.updateAttendanceRecord(updatedRecord);
        return updatedRecord;
      }

      return attendanceRecord;
    } catch (e) {
      if (e is BusinessLogicException || e is LocationException) {
        rethrow;
      }
      throw Exception('Failed to check in: $e');
    }
  }

  /// Check-out employee
  Future<AttendanceModel> checkOut({
    required String employeeId,
    AttendanceMethod method = AttendanceMethod.manual,
    String? qrCode,
  }) async {
    try {
      // Get today's attendance record
      final todayAttendance =
          await _firestoreService.getTodayAttendance(employeeId);
      if (todayAttendance == null || todayAttendance.checkInTime == null) {
        throw const BusinessLogicException('Please check in first');
      }

      if (todayAttendance.checkOutTime != null) {
        throw const BusinessLogicException('Already checked out today');
      }

      Position? position;
      String? location;

      if (!todayAttendance.isWorkFromHome && method == AttendanceMethod.gps) {
        position = await _getCurrentLocation();
        location = await _getLocationName(position);

        // Verify location is within office premises
        if (!_isWithinOfficeRadius(position)) {
          throw const LocationException(
              'You are not within the office premises');
        }
      }

      final now = DateTime.now();
      final workingMinutes =
          now.difference(todayAttendance.checkInTime!).inMinutes;
      final breakMinutes = _calculateTotalBreakMinutes(todayAttendance.breaks);
      final actualWorkingMinutes = workingMinutes - breakMinutes;

      // Calculate overtime (assuming 8 hours = 480 minutes standard)
      const standardWorkingMinutes = 480;
      final overtimeMinutes = actualWorkingMinutes > standardWorkingMinutes
          ? actualWorkingMinutes - standardWorkingMinutes
          : 0;

      final updatedRecord = todayAttendance.copyWith(
        checkOutTime: now,
        checkOutMethod: method,
        checkOutLocation: location,
        checkOutLatitude: position?.latitude,
        checkOutLongitude: position?.longitude,
        workingMinutes: actualWorkingMinutes,
        breakMinutes: breakMinutes,
        overtimeMinutes: overtimeMinutes,
        status: _determineCheckoutStatus(todayAttendance, now),
        updatedAt: now,
      );

      await _firestoreService.updateAttendanceRecord(updatedRecord);
      return updatedRecord;
    } catch (e) {
      if (e is BusinessLogicException || e is LocationException) {
        rethrow;
      }
      throw Exception('Failed to check out: $e');
    }
  }

  /// Start break
  Future<AttendanceModel> startBreak({
    required String employeeId,
    String? reason,
  }) async {
    try {
      final todayAttendance =
          await _firestoreService.getTodayAttendance(employeeId);
      if (todayAttendance == null || todayAttendance.checkInTime == null) {
        throw const BusinessLogicException('Please check in first');
      }

      if (todayAttendance.checkOutTime != null) {
        throw const BusinessLogicException('Cannot start break after checkout');
      }

      // Check if there's an ongoing break
      final ongoingBreak =
          todayAttendance.breaks.where((b) => b.endTime == null).toList();
      if (ongoingBreak.isNotEmpty) {
        throw const BusinessLogicException('Break already in progress');
      }

      final now = DateTime.now();
      final newBreak = BreakRecord(
        id: '${employeeId}_${now.millisecondsSinceEpoch}',
        startTime: now,
        reason: reason,
      );

      final updatedBreaks = List<BreakRecord>.from(todayAttendance.breaks)
        ..add(newBreak);
      final updatedRecord = todayAttendance.copyWith(
        breaks: updatedBreaks,
        updatedAt: now,
      );

      await _firestoreService.updateAttendanceRecord(updatedRecord);
      return updatedRecord;
    } catch (e) {
      if (e is BusinessLogicException) {
        rethrow;
      }
      throw Exception('Failed to start break: $e');
    }
  }

  /// End break
  Future<AttendanceModel> endBreak({required String employeeId}) async {
    try {
      final todayAttendance =
          await _firestoreService.getTodayAttendance(employeeId);
      if (todayAttendance == null || todayAttendance.checkInTime == null) {
        throw const BusinessLogicException('Please check in first');
      }

      // Find ongoing break
      final ongoingBreakIndex =
          todayAttendance.breaks.indexWhere((b) => b.endTime == null);
      if (ongoingBreakIndex == -1) {
        throw const BusinessLogicException('No ongoing break found');
      }

      final now = DateTime.now();
      final updatedBreaks = List<BreakRecord>.from(todayAttendance.breaks);
      final ongoingBreak = updatedBreaks[ongoingBreakIndex];
      final breakDuration = now.difference(ongoingBreak.startTime).inMinutes;

      updatedBreaks[ongoingBreakIndex] = BreakRecord(
        id: ongoingBreak.id,
        startTime: ongoingBreak.startTime,
        endTime: now,
        reason: ongoingBreak.reason,
        durationMinutes: breakDuration,
      );

      final updatedRecord = todayAttendance.copyWith(
        breaks: updatedBreaks,
        breakMinutes: _calculateTotalBreakMinutes(updatedBreaks),
        updatedAt: now,
      );

      await _firestoreService.updateAttendanceRecord(updatedRecord);
      return updatedRecord;
    } catch (e) {
      if (e is BusinessLogicException) {
        rethrow;
      }
      throw Exception('Failed to end break: $e');
    }
  }

  /// Check-in with QR code
  Future<AttendanceModel> checkInWithQR({
    required String employeeId,
    required String employeeName,
    required String qrData,
  }) async {
    // Validate QR code
    if (!_isValidOfficeQR(qrData)) {
      throw const ValidationException('Invalid QR code');
    }

    return await checkIn(
      employeeId: employeeId,
      employeeName: employeeName,
      method: AttendanceMethod.qrCode,
      qrCode: qrData,
    );
  }

  /// Check-out with QR code
  Future<AttendanceModel> checkOutWithQR({
    required String employeeId,
    required String qrData,
  }) async {
    // Validate QR code
    if (!_isValidOfficeQR(qrData)) {
      throw const ValidationException('Invalid QR code');
    }

    return await checkOut(
      employeeId: employeeId,
      method: AttendanceMethod.qrCode,
      qrCode: qrData,
    );
  }

  /// Get current location
  Future<Position> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException('Location services are disabled');
      }

      // Check location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException('Location permission permanently denied');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      if (e is LocationException) {
        rethrow;
      }
      throw LocationException('Failed to get location: $e');
    }
  }

  /// Get location name from coordinates
  Future<String> _getLocationName(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.name}, ${place.locality}, ${place.country}';
      }

      return 'Unknown location';
    } catch (e) {
      return 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
    }
  }

  /// Check if position is within office radius
  bool _isWithinOfficeRadius(Position position) {
    final distance = Geolocator.distanceBetween(
      officeLatitude,
      officeLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= allowedDistanceMeters;
  }

  /// Validate office QR code
  bool _isValidOfficeQR(String qrData) {
    // Implement your QR code validation logic
    // For example, check if it contains a specific company identifier
    return qrData.contains('HR_APP_OFFICE') || qrData.contains('COMPANY_QR');
  }

  /// Determine attendance status based on check-in time
  AttendanceStatus _determineAttendanceStatus(
      DateTime checkInTime, bool isWorkFromHome) {
    if (isWorkFromHome) {
      return AttendanceStatus.workFromHome;
    }

    // Standard office hours: 9:00 AM
    final standardTime = DateTime(
      checkInTime.year,
      checkInTime.month,
      checkInTime.day,
      9,
      0,
    );

    if (checkInTime.isAfter(standardTime)) {
      return AttendanceStatus.late;
    }

    return AttendanceStatus.present;
  }

  /// Determine status after checkout
  AttendanceStatus _determineCheckoutStatus(
      AttendanceModel attendance, DateTime checkOutTime) {
    if (attendance.isWorkFromHome) {
      return AttendanceStatus.workFromHome;
    }

    if (attendance.status == AttendanceStatus.late) {
      return AttendanceStatus.late;
    }

    // Standard checkout time: 6:00 PM
    final standardCheckOut = DateTime(
      checkOutTime.year,
      checkOutTime.month,
      checkOutTime.day,
      18,
      0,
    );

    if (checkOutTime.isBefore(standardCheckOut)) {
      return AttendanceStatus.earlyLeave;
    }

    return AttendanceStatus.present;
  }

  /// Calculate total break minutes
  int _calculateTotalBreakMinutes(List<BreakRecord> breaks) {
    int totalMinutes = 0;
    for (final breakRecord in breaks) {
      if (breakRecord.endTime != null) {
        totalMinutes += breakRecord.actualDurationMinutes;
      }
    }
    return totalMinutes;
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    try {
      final status = await Permission.location.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }

  /// Get attendance summary for employee
  Future<Map<String, dynamic>> getAttendanceSummary({
    required String employeeId,
    required int year,
    required int month,
  }) async {
    try {
      return await _firestoreService.getMonthlyAttendanceSummary(
          employeeId, year, month);
    } catch (e) {
      throw Exception('Failed to get attendance summary: $e');
    }
  }

  /// Get employee attendance records
  Stream<List<AttendanceModel>> getEmployeeAttendance({
    required String employeeId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestoreService.getEmployeeAttendance(
        employeeId, startDate, endDate);
  }

  /// Get today's attendance
  Future<AttendanceModel?> getTodayAttendance(String employeeId) async {
    return await _firestoreService.getTodayAttendance(employeeId);
  }

  /// Manual attendance entry (for HR/Manager)
  Future<AttendanceModel> createManualAttendance({
    required String employeeId,
    required String employeeName,
    required DateTime date,
    required DateTime checkInTime,
    DateTime? checkOutTime,
    String? reason,
    required String approverUserId,
  }) async {
    try {
      final attendanceId =
          '${employeeId}_${date.year}_${date.month}_${date.day}';

      // Check if attendance already exists
      final existingAttendance =
          await _firestoreService.getAttendanceRecord(attendanceId);
      if (existingAttendance != null) {
        throw const BusinessLogicException(
            'Attendance record already exists for this date');
      }

      int? workingMinutes;
      if (checkOutTime != null) {
        workingMinutes = checkOutTime.difference(checkInTime).inMinutes;
      }

      final attendanceRecord = AttendanceModel(
        id: attendanceId,
        employeeId: employeeId,
        employeeName: employeeName,
        date: DateTime(date.year, date.month, date.day),
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        checkInMethod: AttendanceMethod.manual,
        checkOutMethod: checkOutTime != null ? AttendanceMethod.manual : null,
        status: _determineAttendanceStatus(checkInTime, false),
        workingMinutes: workingMinutes,
        notes: reason,
        managerApproval: 'approved',
        approvedAt: DateTime.now(),
        approvedBy: approverUserId,
        breaks: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.createAttendanceRecord(attendanceRecord);
      return attendanceRecord;
    } catch (e) {
      if (e is BusinessLogicException) {
        rethrow;
      }
      throw Exception('Failed to create manual attendance: $e');
    }
  }

  /// Update attendance record (for corrections)
  Future<AttendanceModel> updateAttendanceRecord({
    required AttendanceModel attendance,
    required String approverUserId,
    String? reason,
  }) async {
    try {
      final updatedRecord = attendance.copyWith(
        managerApproval: 'approved',
        approvedAt: DateTime.now(),
        approvedBy: approverUserId,
        notes: reason ?? attendance.notes,
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateAttendanceRecord(updatedRecord);
      return updatedRecord;
    } catch (e) {
      throw Exception('Failed to update attendance record: $e');
    }
  }

  /// Calculate distance from office
  Future<double> getDistanceFromOffice() async {
    try {
      final position = await _getCurrentLocation();
      return Geolocator.distanceBetween(
        officeLatitude,
        officeLongitude,
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      throw LocationException('Failed to calculate distance from office: $e');
    }
  }

  /// Check if employee can check in from current location
  Future<bool> canCheckInFromCurrentLocation() async {
    try {
      final distance = await getDistanceFromOffice();
      return distance <= allowedDistanceMeters;
    } catch (e) {
      return false;
    }
  }
}
