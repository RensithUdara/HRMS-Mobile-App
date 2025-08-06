import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../utils/exceptions.dart';

/// Firebase Storage service for file management
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Storage paths
  static const String employeeDocuments = 'employee_documents';
  static const String profilePhotos = 'profile_photos';
  static const String certificates = 'certificates';
  static const String payslips = 'payslips';
  static const String leaveDocuments = 'leave_documents';
  static const String companyDocuments = 'company_documents';

  /// Upload profile photo
  Future<String> uploadProfilePhoto(String employeeId, XFile imageFile) async {
    try {
      final fileName =
          'profile_${employeeId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('$profilePhotos/$fileName');

      final uploadTask = await ref.putFile(File(imageFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to upload profile photo: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload profile photo: $e');
    }
  }

  /// Upload employee document (CV, NIC, etc.)
  Future<String> uploadEmployeeDocument(
    String employeeId,
    String documentType,
    File file,
  ) async {
    try {
      final fileName =
          '${documentType}_${employeeId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref =
          _storage.ref().child('$employeeDocuments/$employeeId/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException('Failed to upload document: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload document: $e');
    }
  }

  /// Upload certificate
  Future<String> uploadCertificate(
    String employeeId,
    String certificateName,
    File file,
  ) async {
    try {
      final fileName =
          '${certificateName}_${employeeId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('$certificates/$employeeId/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to upload certificate: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload certificate: $e');
    }
  }

  /// Upload payslip PDF
  Future<String> uploadPayslip(
    String employeeId,
    int year,
    int month,
    Uint8List pdfBytes,
  ) async {
    try {
      final fileName =
          'payslip_${employeeId}_${year}_${month.toString().padLeft(2, '0')}.pdf';
      final ref = _storage.ref().child('$payslips/$employeeId/$year/$fileName');

      final uploadTask = await ref.putData(
          pdfBytes, SettableMetadata(contentType: 'application/pdf'));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException('Failed to upload payslip: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload payslip: $e');
    }
  }

  /// Upload leave supporting document
  Future<String> uploadLeaveDocument(
    String employeeId,
    String leaveId,
    File file,
  ) async {
    try {
      final fileName =
          'leave_${leaveId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('$leaveDocuments/$employeeId/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to upload leave document: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload leave document: $e');
    }
  }

  /// Upload company policy document
  Future<String> uploadCompanyDocument(
    String documentName,
    File file,
  ) async {
    try {
      final fileName =
          '${documentName}_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('$companyDocuments/$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to upload company document: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload company document: $e');
    }
  }

  /// Delete file by URL
  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException('Failed to delete file: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to delete file: $e');
    }
  }

  /// Delete employee's profile photo
  Future<void> deleteProfilePhoto(String downloadUrl) async {
    try {
      await deleteFile(downloadUrl);
    } catch (e) {
      throw StorageException('Failed to delete profile photo: $e');
    }
  }

  /// Delete all employee documents
  Future<void> deleteAllEmployeeDocuments(String employeeId) async {
    try {
      final ref = _storage.ref().child('$employeeDocuments/$employeeId');
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to delete employee documents: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to delete employee documents: $e');
    }
  }

  /// Get download URL for file
  Future<String> getDownloadUrl(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to get download URL: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to get download URL: $e');
    }
  }

  /// Get file metadata
  Future<FullMetadata> getFileMetadata(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      return await ref.getMetadata();
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to get file metadata: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to get file metadata: $e');
    }
  }

  /// List files in directory
  Future<List<Reference>> listFiles(String directoryPath) async {
    try {
      final ref = _storage.ref().child(directoryPath);
      final result = await ref.listAll();
      return result.items;
    } on FirebaseException catch (e) {
      throw StorageException('Failed to list files: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to list files: $e');
    }
  }

  /// Upload with progress tracking
  Future<String> uploadWithProgress(
    String filePath,
    File file,
    Function(double progress)? onProgress,
  ) async {
    try {
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException('Failed to upload file: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload file: $e');
    }
  }

  /// Upload compressed image
  Future<String> uploadCompressedImage(
    String filePath,
    File imageFile, {
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      // Note: You would need to implement image compression here
      // using packages like flutter_image_compress
      final ref = _storage.ref().child(filePath);
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(
          'Failed to upload compressed image: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to upload compressed image: $e');
    }
  }

  /// Get file size
  Future<int> getFileSize(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } on FirebaseException catch (e) {
      throw StorageException('Failed to get file size: ${e.message}', e.code);
    } catch (e) {
      throw StorageException('Failed to get file size: $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      await ref.getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      throw StorageException(
          'Failed to check file existence: ${e.message}', e.code);
    } catch (e) {
      return false;
    }
  }

  /// Helper methods for file picking

  /// Pick image from gallery or camera
  Future<XFile?> pickImage({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      return await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      throw StorageException('Failed to pick image: $e');
    }
  }

  /// Pick multiple images
  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final picker = ImagePicker();
      return await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } catch (e) {
      throw StorageException('Failed to pick multiple images: $e');
    }
  }

  /// Pick file
  Future<PlatformFile?> pickFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      return result?.files.first;
    } catch (e) {
      throw StorageException('Failed to pick file: $e');
    }
  }

  /// Pick multiple files
  Future<List<PlatformFile>?> pickMultipleFiles({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      return result?.files;
    } catch (e) {
      throw StorageException('Failed to pick multiple files: $e');
    }
  }

  /// Get file extension from path
  String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Check if file is image
  bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension);
  }

  /// Check if file is PDF
  bool isPdfFile(String filePath) {
    return getFileExtension(filePath) == '.pdf';
  }

  /// Check if file is document
  bool isDocumentFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['.pdf', '.doc', '.docx', '.txt', '.rtf'].contains(extension);
  }

  /// Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
