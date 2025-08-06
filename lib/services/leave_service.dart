import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_model.dart';

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'leaves';
  final String _balanceCollection = 'leave_balances';

  // Get all leaves with optional filters
  Future<List<LeaveModel>> getAllLeaves({
    String? employeeId,
    LeaveStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString().split('.').last);
      }

      if (startDate != null) {
        query = query.where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('endDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.orderBy('createdAt', descending: true);

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => LeaveModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leaves: $e');
    }
  }

  // Get leave by ID
  Future<LeaveModel?> getLeaveById(String leaveId) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(leaveId).get();
      if (docSnapshot.exists) {
        return LeaveModel.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch leave: $e');
    }
  }

  // Create new leave request
  Future<String> createLeave(LeaveModel leave) async {
    try {
      // Check leave balance before creating
      final hasBalance = await _checkLeaveBalance(leave.employeeId, leave.leaveType, leave.totalDays);
      if (!hasBalance && leave.leaveType != LeaveType.noPay) {
        throw Exception('Insufficient leave balance for ${leave.leaveType.toString().split('.').last} leave');
      }

      // Check for overlapping leaves
      final hasOverlap = await _checkOverlappingLeaves(leave.employeeId, leave.startDate, leave.endDate);
      if (hasOverlap) {
        throw Exception('Leave dates overlap with existing leave request');
      }

      final docRef = await _firestore.collection(_collection).add(leave.toJson());
      
      // Update leave balance if approved automatically or pending
      if (leave.status == LeaveStatus.approved) {
        await _updateLeaveBalance(leave.employeeId, leave.leaveType, -leave.totalDays);
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create leave: $e');
    }
  }

  // Update leave request
  Future<void> updateLeave(LeaveModel leave) async {
    try {
      await _firestore.collection(_collection).doc(leave.id).update(leave.toJson());
    } catch (e) {
      throw Exception('Failed to update leave: $e');
    }
  }

  // Delete leave request (only if pending)
  Future<void> deleteLeave(String leaveId) async {
    try {
      final leave = await getLeaveById(leaveId);
      if (leave == null) {
        throw Exception('Leave not found');
      }

      if (leave.status != LeaveStatus.pending) {
        throw Exception('Only pending leave requests can be deleted');
      }

      await _firestore.collection(_collection).doc(leaveId).delete();
    } catch (e) {
      throw Exception('Failed to delete leave: $e');
    }
  }

  // Approve leave request
  Future<void> approveLeave({
    required String leaveId,
    required String approverId,
    String? comments,
  }) async {
    try {
      final leave = await getLeaveById(leaveId);
      if (leave == null) {
        throw Exception('Leave not found');
      }

      if (leave.status != LeaveStatus.pending) {
        throw Exception('Leave is not in pending status');
      }

      final approval = LeaveApproval(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverId: approverId,
        approverName: '', // Should be fetched from user data
        level: ApprovalLevel.manager, // Should be determined based on approver role
        status: LeaveStatus.approved,
        comments: comments,
        approvedAt: DateTime.now(),
      );

      final updatedApprovals = [...leave.approvals, approval];
      final updatedLeave = leave.copyWith(
        status: LeaveStatus.approved,
        approvals: updatedApprovals,
        updatedAt: DateTime.now(),
      );

      await updateLeave(updatedLeave);

      // Update leave balance
      await _updateLeaveBalance(leave.employeeId, leave.leaveType, -leave.totalDays);
    } catch (e) {
      throw Exception('Failed to approve leave: $e');
    }
  }

  // Reject leave request
  Future<void> rejectLeave({
    required String leaveId,
    required String approverId,
    required String reason,
  }) async {
    try {
      final leave = await getLeaveById(leaveId);
      if (leave == null) {
        throw Exception('Leave not found');
      }

      if (leave.status != LeaveStatus.pending) {
        throw Exception('Leave is not in pending status');
      }

      final approval = LeaveApproval(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        approverId: approverId,
        approverName: '', // Should be fetched from user data
        level: ApprovalLevel.manager,
        status: LeaveStatus.rejected,
        comments: reason,
        approvedAt: DateTime.now(),
      );

      final updatedApprovals = [...leave.approvals, approval];
      final updatedLeave = leave.copyWith(
        status: LeaveStatus.rejected,
        rejectionReason: reason,
        approvals: updatedApprovals,
        updatedAt: DateTime.now(),
      );

      await updateLeave(updatedLeave);
    } catch (e) {
      throw Exception('Failed to reject leave: $e');
    }
  }

  // Get leave balance for an employee
  Future<Map<LeaveType, int>> getLeaveBalance(String employeeId) async {
    try {
      final docSnapshot = await _firestore.collection(_balanceCollection).doc(employeeId).get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return {
          LeaveType.annual: data['annual'] ?? 14,
          LeaveType.casual: data['casual'] ?? 7,
          LeaveType.sick: data['sick'] ?? 21,
          LeaveType.maternity: data['maternity'] ?? 84,
          LeaveType.paternity: data['paternity'] ?? 7,
          LeaveType.compensatory: data['compensatory'] ?? 0,
          LeaveType.study: data['study'] ?? 0,
          LeaveType.bereavement: data['bereavement'] ?? 3,
          LeaveType.emergency: data['emergency'] ?? 2,
          LeaveType.medical: data['medical'] ?? 7,
        };
      } else {
        // Initialize default leave balance
        return await _initializeLeaveBalance(employeeId);
      }
    } catch (e) {
      throw Exception('Failed to get leave balance: $e');
    }
  }

  // Initialize default leave balance for new employee
  Future<Map<LeaveType, int>> _initializeLeaveBalance(String employeeId) async {
    final defaultBalance = {
      LeaveType.annual: 14,
      LeaveType.casual: 7,
      LeaveType.sick: 21,
      LeaveType.maternity: 84,
      LeaveType.paternity: 7,
      LeaveType.compensatory: 0,
      LeaveType.study: 0,
      LeaveType.bereavement: 3,
      LeaveType.emergency: 2,
      LeaveType.medical: 7,
    };

    final balanceData = {
      'employeeId': employeeId,
      'annual': 14,
      'casual': 7,
      'sick': 21,
      'maternity': 84,
      'paternity': 7,
      'compensatory': 0,
      'study': 0,
      'bereavement': 3,
      'emergency': 2,
      'medical': 7,
      'year': DateTime.now().year,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _firestore.collection(_balanceCollection).doc(employeeId).set(balanceData);
    return defaultBalance;
  }

  // Check if employee has sufficient leave balance
  Future<bool> _checkLeaveBalance(String employeeId, LeaveType leaveType, int requestedDays) async {
    if (leaveType == LeaveType.noPay || leaveType == LeaveType.halfDay) {
      return true; // No balance check for no-pay leave
    }

    final balance = await getLeaveBalance(employeeId);
    final availableBalance = balance[leaveType] ?? 0;
    return availableBalance >= requestedDays;
  }

  // Check for overlapping leave dates
  Future<bool> _checkOverlappingLeaves(String employeeId, DateTime startDate, DateTime endDate) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employeeId)
          .where('status', whereIn: ['pending', 'approved'])
          .get();

      for (final doc in querySnapshot.docs) {
        final leave = LeaveModel.fromJson({...doc.data(), 'id': doc.id});
        
        // Check if dates overlap
        if ((startDate.isBefore(leave.endDate) || startDate.isAtSameMomentAs(leave.endDate)) &&
            (endDate.isAfter(leave.startDate) || endDate.isAtSameMomentAs(leave.startDate))) {
          return true; // Overlap found
        }
      }
      return false; // No overlap
    } catch (e) {
      throw Exception('Failed to check overlapping leaves: $e');
    }
  }

  // Update leave balance
  Future<void> _updateLeaveBalance(String employeeId, LeaveType leaveType, int change) async {
    try {
      final docRef = _firestore.collection(_balanceCollection).doc(employeeId);
      
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        
        if (snapshot.exists) {
          final data = snapshot.data()!;
          final leaveTypeKey = leaveType.toString().split('.').last;
          final currentBalance = data[leaveTypeKey] ?? 0;
          final newBalance = currentBalance + change;
          
          transaction.update(docRef, {
            leaveTypeKey: newBalance >= 0 ? newBalance : 0,
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to update leave balance: $e');
    }
  }

  // Get leave statistics
  Future<Map<String, dynamic>> getLeaveStatistics({
    String? employeeId,
    int? year,
  }) async {
    try {
      final targetYear = year ?? DateTime.now().year;
      final startOfYear = DateTime(targetYear, 1, 1);
      final endOfYear = DateTime(targetYear, 12, 31);

      final leaves = await getAllLeaves(
        employeeId: employeeId,
        startDate: startOfYear,
        endDate: endOfYear,
      );

      final totalRequests = leaves.length;
      final approvedLeaves = leaves.where((l) => l.status == LeaveStatus.approved).length;
      final pendingLeaves = leaves.where((l) => l.status == LeaveStatus.pending).length;
      final rejectedLeaves = leaves.where((l) => l.status == LeaveStatus.rejected).length;

      final totalDaysTaken = leaves
          .where((l) => l.status == LeaveStatus.approved)
          .fold<int>(0, (sum, leave) => sum + leave.totalDays);

      return {
        'totalRequests': totalRequests,
        'approvedLeaves': approvedLeaves,
        'pendingLeaves': pendingLeaves,
        'rejectedLeaves': rejectedLeaves,
        'totalDaysTaken': totalDaysTaken,
        'year': targetYear,
      };
    } catch (e) {
      throw Exception('Failed to get leave statistics: $e');
    }
  }

  // Stream for real-time leave updates
  Stream<List<LeaveModel>> leavesStream({String? employeeId}) {
    Query query = _firestore.collection(_collection);
    
    if (employeeId != null) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => LeaveModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }
}
