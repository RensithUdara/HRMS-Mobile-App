import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  // Get all employees
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      return querySnapshot.docs
          .map((doc) => EmployeeModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  // Get employee by ID
  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(employeeId).get();
      if (docSnapshot.exists) {
        return EmployeeModel.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch employee: $e');
    }
  }

  // Create new employee
  Future<String> createEmployee(EmployeeModel employee) async {
    try {
      final docRef = await _firestore.collection(_collection).add(employee.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  // Update employee
  Future<void> updateEmployee(EmployeeModel employee) async {
    try {
      await _firestore.collection(_collection).doc(employee.id).update(employee.toJson());
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  // Delete employee (soft delete by setting isActive to false)
  Future<void> deleteEmployee(String employeeId) async {
    try {
      await _firestore.collection(_collection).doc(employeeId).update({
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  // Search employees by name, email, or employee ID
  Future<List<EmployeeModel>> searchEmployees(String query) async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final allEmployees = querySnapshot.docs
          .map((doc) => EmployeeModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      // Filter employees based on search query
      return allEmployees.where((employee) {
        final firstName = employee.firstName.toLowerCase();
        final lastName = employee.lastName.toLowerCase();
        final email = employee.email.toLowerCase();
        final searchQuery = query.toLowerCase();

        return firstName.contains(searchQuery) ||
            lastName.contains(searchQuery) ||
            email.contains(searchQuery) ||
            employee.id.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search employees: $e');
    }
  }

  // Filter employees by department, position, or active status
  Future<List<EmployeeModel>> filterEmployees({
    String? department,
    String? position,
    bool? isActive,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Apply filters
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      final querySnapshot = await query.get();
      final employees = querySnapshot.docs
          .map((doc) => EmployeeModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Apply additional filters that can't be done in Firestore query
      return employees.where((employee) {
        bool matchesDepartment = true;
        bool matchesPosition = true;

        if (department != null) {
          matchesDepartment = employee.department.name == department;
        }

        if (position != null) {
          matchesPosition = employee.designation == position;
        }

        return matchesDepartment && matchesPosition;
      }).toList();
    } catch (e) {
      throw Exception('Failed to filter employees: $e');
    }
  }

  // Get employees by department
  Future<List<EmployeeModel>> getEmployeesByDepartment(String department) async {
    return filterEmployees(department: department);
  }

  // Get active employees count
  Future<int> getActiveEmployeesCount() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();
      return querySnapshot.size;
    } catch (e) {
      throw Exception('Failed to get active employees count: $e');
    }
  }

  // Stream of all employees (for real-time updates)
  Stream<List<EmployeeModel>> employeesStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => EmployeeModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }
}
