import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/performance_model.dart';

class PerformanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _performanceCollection = 'performance_reviews';
  static const String _goalsCollection = 'goals';

  // Get all performance reviews with optional filters
  Future<List<PerformanceReviewModel>> getAllPerformanceReviews({
    String? employeeId,
    int? year,
    String? period,
  }) async {
    try {
      Query query = _firestore.collection(_performanceCollection);

      // Apply filters
      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (year != null) {
        query = query.where('reviewYear', isEqualTo: year);
      }

      if (period != null) {
        query = query.where('reviewPeriod', isEqualTo: period);
      }

      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch performance reviews: $e');
    }
  }

  // Get performance review by ID
  Future<PerformanceReviewModel?> getPerformanceReviewById(String reviewId) async {
    try {
      final doc = await _firestore
          .collection(_performanceCollection)
          .doc(reviewId)
          .get();

      if (doc.exists) {
        return PerformanceReviewModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch performance review: $e');
    }
  }

  // Create new performance review
  Future<void> createPerformanceReview(PerformanceReviewModel review) async {
    try {
      await _firestore
          .collection(_performanceCollection)
          .doc(review.id)
          .set(review.toJson());
    } catch (e) {
      throw Exception('Failed to create performance review: $e');
    }
  }

  // Update performance review
  Future<void> updatePerformanceReview(PerformanceReviewModel review) async {
    try {
      await _firestore
          .collection(_performanceCollection)
          .doc(review.id)
          .update(review.toJson());
    } catch (e) {
      throw Exception('Failed to update performance review: $e');
    }
  }

  // Delete performance review
  Future<void> deletePerformanceReview(String reviewId) async {
    try {
      await _firestore
          .collection(_performanceCollection)
          .doc(reviewId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete performance review: $e');
    }
  }

  // Submit performance review for approval
  Future<void> submitPerformanceReview(String reviewId) async {
    try {
      await _firestore
          .collection(_performanceCollection)
          .doc(reviewId)
          .update({
        'status': 'submitted',
        'submittedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to submit performance review: $e');
    }
  }

  // Approve performance review
  Future<void> approvePerformanceReview({
    required String performanceId,
    required String approverId,
    required String comments,
  }) async {
    try {
      await _firestore
          .collection(_performanceCollection)
          .doc(performanceId)
          .update({
        'status': 'approved',
        'approvedBy': approverId,
        'approvedAt': Timestamp.now(),
        'approverComments': comments,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to approve performance review: $e');
    }
  }

  // Create goal
  Future<void> createGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection(_goalsCollection)
          .doc(goal.id)
          .set(goal.toJson());
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  // Update goal
  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection(_goalsCollection)
          .doc(goal.id)
          .update(goal.toJson());
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  // Get goals for employee
  Future<List<GoalModel>> getEmployeeGoals(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(_goalsCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('targetDate', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employee goals: $e');
    }
  }

  // Get performance statistics
  Future<Map<String, dynamic>> getPerformanceStatistics({
    String? employeeId,
    int? year,
  }) async {
    try {
      Query query = _firestore.collection(_performanceCollection);

      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (year != null) {
        query = query.where('reviewYear', isEqualTo: year);
      }

      final snapshot = await query.get();
      final reviews = snapshot.docs
          .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Calculate statistics
      double totalScore = 0;
      int completedReviews = 0;
      int pendingReviews = 0;
      int draftReviews = 0;

      for (final review in reviews) {
        totalScore += review.overallScore;
        
        switch (review.status.name) {
          case 'completed':
            completedReviews++;
            break;
          case 'submitted':
            pendingReviews++;
            break;
          case 'draft':
            draftReviews++;
            break;
        }
      }

      final averageScore = reviews.isNotEmpty ? totalScore / reviews.length : 0.0;

      return {
        'totalReviews': reviews.length,
        'completedReviews': completedReviews,
        'pendingReviews': pendingReviews,
        'draftReviews': draftReviews,
        'averageScore': averageScore,
        'reviews': reviews,
      };
    } catch (e) {
      throw Exception('Failed to get performance statistics: $e');
    }
  }

  // Get employee performance history
  Future<List<PerformanceReviewModel>> getEmployeePerformanceHistory(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(_performanceCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('reviewYear', descending: true)
          .orderBy('reviewPeriod', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PerformanceReviewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get employee performance history: $e');
    }
  }

  // Search performance reviews
  Future<List<PerformanceReviewModel>> searchPerformanceReviews({
    required String searchTerm,
    String? employeeId,
    int? year,
  }) async {
    try {
      Query query = _firestore.collection(_performanceCollection);

      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (year != null) {
        query = query.where('reviewYear', isEqualTo: year);
      }

      final snapshot = await query.get();
      final allReviews = snapshot.docs
          .map((doc) => PerformanceReviewModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter results based on search term
      return allReviews.where((review) {
        final searchLower = searchTerm.toLowerCase();
        return review.employeeName.toLowerCase().contains(searchLower) ||
               review.reviewPeriod.toLowerCase().contains(searchLower) ||
               review.goals.any((goal) => goal.title.toLowerCase().contains(searchLower));
      }).toList();
    } catch (e) {
      throw Exception('Failed to search performance reviews: $e');
    }
  }
}
