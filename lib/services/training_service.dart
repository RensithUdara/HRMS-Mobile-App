import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/training_model.dart';

class TrainingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _trainingProgramsCollection = 'training_programs';
  static const String _trainingEnrollmentsCollection = 'training_enrollments';

  // Get all training programs with optional filters
  Future<List<TrainingProgramModel>> getAllTrainingPrograms({
    String? employeeId,
    String? status,
    String? category,
  }) async {
    try {
      Query query = _firestore.collection(_trainingProgramsCollection);

      // Apply filters
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      query = query.orderBy('startDate', descending: false);

      final snapshot = await query.get();
      final allPrograms = snapshot.docs
          .map((doc) => TrainingProgramModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // If employeeId is provided, filter based on enrollment status
      if (employeeId != null) {
        final enrollments = await getEmployeeEnrollments(employeeId);
        final enrolledProgramIds = enrollments.map((e) => e.trainingId).toSet();
        
        // You might want to return all programs with enrollment status
        // or only enrolled programs based on your requirements
        return allPrograms;
      }

      return allPrograms;
    } catch (e) {
      throw Exception('Failed to fetch training programs: $e');
    }
  }

  // Get training program by ID
  Future<TrainingProgramModel?> getTrainingProgramById(String programId) async {
    try {
      final doc = await _firestore
          .collection(_trainingProgramsCollection)
          .doc(programId)
          .get();

      if (doc.exists) {
        return TrainingProgramModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch training program: $e');
    }
  }

  // Create new training program
  Future<void> createTrainingProgram(TrainingProgramModel program) async {
    try {
      await _firestore
          .collection(_trainingProgramsCollection)
          .doc(program.id)
          .set(program.toJson());
    } catch (e) {
      throw Exception('Failed to create training program: $e');
    }
  }

  // Update training program
  Future<void> updateTrainingProgram(TrainingProgramModel program) async {
    try {
      await _firestore
          .collection(_trainingProgramsCollection)
          .doc(program.id)
          .update(program.toJson());
    } catch (e) {
      throw Exception('Failed to update training program: $e');
    }
  }

  // Delete training program
  Future<void> deleteTrainingProgram(String programId) async {
    try {
      await _firestore
          .collection(_trainingProgramsCollection)
          .doc(programId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete training program: $e');
    }
  }

  // Enroll employee in training
  Future<void> enrollInTraining({
    required String trainingId,
    required String employeeId,
  }) async {
    try {
      final enrollment = TrainingEnrollmentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        trainingId: trainingId,
        employeeId: employeeId,
        enrolledAt: DateTime.now(),
        status: TrainingStatus.enrolled,
        progress: 0.0,
      );

      await _firestore
          .collection(_trainingEnrollmentsCollection)
          .doc(enrollment.id)
          .set(enrollment.toJson());

      // Update enrollment count in training program
      await _firestore
          .collection(_trainingProgramsCollection)
          .doc(trainingId)
          .update({
        'enrolledCount': FieldValue.increment(1),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to enroll in training: $e');
    }
  }

  // Complete training
  Future<void> completeTraining({
    required String enrollmentId,
    required double score,
    required String feedback,
  }) async {
    try {
      await _firestore
          .collection(_trainingEnrollmentsCollection)
          .doc(enrollmentId)
          .update({
        'status': 'completed',
        'completedAt': Timestamp.now(),
        'score': score,
        'feedback': feedback,
        'progress': 100.0,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to complete training: $e');
    }
  }

  // Upload certificate
  Future<void> uploadCertificate({
    required String enrollmentId,
    required String certificateUrl,
  }) async {
    try {
      await _firestore
          .collection(_trainingEnrollmentsCollection)
          .doc(enrollmentId)
          .update({
        'certificateUrl': certificateUrl,
        'certificateUploadedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to upload certificate: $e');
    }
  }

  // Get employee enrollments
  Future<List<TrainingEnrollmentModel>> getEmployeeEnrollments(String employeeId) async {
    try {
      final snapshot = await _firestore
          .collection(_trainingEnrollmentsCollection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('enrolledAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingEnrollmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employee enrollments: $e');
    }
  }

  // Get training enrollments (for a specific training)
  Future<List<TrainingEnrollmentModel>> getTrainingEnrollments(String trainingId) async {
    try {
      final snapshot = await _firestore
          .collection(_trainingEnrollmentsCollection)
          .where('trainingId', isEqualTo: trainingId)
          .orderBy('enrolledAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TrainingEnrollmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch training enrollments: $e');
    }
  }

  // Get training statistics
  Future<Map<String, dynamic>> getTrainingStatistics({
    String? employeeId,
    int? year,
  }) async {
    try {
      Query enrollmentQuery = _firestore.collection(_trainingEnrollmentsCollection);

      if (employeeId != null) {
        enrollmentQuery = enrollmentQuery.where('employeeId', isEqualTo: employeeId);
      }

      if (year != null) {
        final startOfYear = DateTime(year, 1, 1);
        final endOfYear = DateTime(year + 1, 1, 1);
        enrollmentQuery = enrollmentQuery
            .where('enrolledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
            .where('enrolledAt', isLessThan: Timestamp.fromDate(endOfYear));
      }

      final enrollmentSnapshot = await enrollmentQuery.get();
      final enrollments = enrollmentSnapshot.docs
          .map((doc) => TrainingEnrollmentModel.fromJson(doc.data()))
          .toList();

      // Calculate statistics
      int totalEnrollments = enrollments.length;
      int completedTrainings = 0;
      int inProgressTrainings = 0;
      int notStartedTrainings = 0;
      double totalScore = 0;
      int scoredTrainings = 0;

      for (final enrollment in enrollments) {
        switch (enrollment.status.name) {
          case 'completed':
            completedTrainings++;
            if (enrollment.score != null) {
              totalScore += enrollment.score!;
              scoredTrainings++;
            }
            break;
          case 'inProgress':
            inProgressTrainings++;
            break;
          case 'enrolled':
            notStartedTrainings++;
            break;
        }
      }

      final averageScore = scoredTrainings > 0 ? totalScore / scoredTrainings : 0.0;
      final completionRate = totalEnrollments > 0 ? (completedTrainings / totalEnrollments) * 100 : 0.0;

      return {
        'totalEnrollments': totalEnrollments,
        'completedTrainings': completedTrainings,
        'inProgressTrainings': inProgressTrainings,
        'notStartedTrainings': notStartedTrainings,
        'averageScore': averageScore,
        'completionRate': completionRate,
        'enrollments': enrollments,
      };
    } catch (e) {
      throw Exception('Failed to get training statistics: $e');
    }
  }

  // Search training programs
  Future<List<TrainingProgramModel>> searchTrainingPrograms({
    required String searchTerm,
    String? category,
  }) async {
    try {
      Query query = _firestore.collection(_trainingProgramsCollection);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      final allPrograms = snapshot.docs
          .map((doc) => TrainingProgramModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter results based on search term
      return allPrograms.where((program) {
        final searchLower = searchTerm.toLowerCase();
        return program.title.toLowerCase().contains(searchLower) ||
               program.description.toLowerCase().contains(searchLower) ||
               program.instructor.toLowerCase().contains(searchLower) ||
               program.category.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search training programs: $e');
    }
  }

  // Get upcoming trainings
  Future<List<TrainingProgramModel>> getUpcomingTrainings() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection(_trainingProgramsCollection)
          .where('startDate', isGreaterThan: Timestamp.fromDate(now))
          .where('status', isEqualTo: 'active')
          .orderBy('startDate', descending: false)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => TrainingProgramModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming trainings: $e');
    }
  }

  // Update training progress
  Future<void> updateTrainingProgress({
    required String enrollmentId,
    required double progress,
  }) async {
    try {
      await _firestore
          .collection(_trainingEnrollmentsCollection)
          .doc(enrollmentId)
          .update({
        'progress': progress,
        'updatedAt': Timestamp.now(),
        if (progress > 0 && progress < 100) 'status': 'inProgress',
      });
    } catch (e) {
      throw Exception('Failed to update training progress: $e');
    }
  }
}
