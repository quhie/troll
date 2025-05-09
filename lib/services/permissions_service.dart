import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Request camera permission for flashlight
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  // Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }
  
  // Request all required permissions at once
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    
    return statuses;
  }
} 