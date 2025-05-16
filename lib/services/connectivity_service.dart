import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Service để theo dõi trạng thái kết nối internet
class ConnectivityService {
  // Singleton pattern
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  // Connectivity instance
  final Connectivity _connectivity = Connectivity();
  
  // Controllers để phát sóng trạng thái kết nối
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  // Stream để lắng nghe trạng thái kết nối
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  // Biến lưu trạng thái kết nối hiện tại
  bool _isConnected = true;
  bool get isConnected => _isConnected;

  // Biến để lưu subscription
  StreamSubscription? _connectivitySubscription;
  
  // Định kỳ kiểm tra kết nối
  Timer? _periodicConnectionCheck;
  
  // Các URL để kiểm tra internet
  final List<String> _connectionCheckUrls = [
    'https://www.google.com',
    'https://www.apple.com',
    'https://www.cloudflare.com',
  ];

  /// Khởi tạo theo dõi kết nối
  void initialize() {
    // Kiểm tra kết nối ban đầu
    checkConnectivity();
    
    // Lắng nghe thay đổi kết nối
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_processConnectivityResults);
    
    // Kiểm tra kết nối thực định kỳ mỗi 30 giây
    _periodicConnectionCheck = Timer.periodic(const Duration(seconds: 30), (_) {
      checkRealConnectivity();
    });
    
    // Kiểm tra kết nối thực ngay lập tức
    checkRealConnectivity();
  }
  
  /// Xử lý kết quả từ connectivity_plus
  void _processConnectivityResults(List<ConnectivityResult> results) {
    // Xử lý kết quả đầu tiên trong danh sách
    if (results.isNotEmpty) {
      // Kiểm tra nếu có bất kỳ loại kết nối nào
      bool hasNetworkConnection = results.any((result) => result != ConnectivityResult.none);
      
      // Nếu có kết nối mạng, kiểm tra thêm internet thực
      if (hasNetworkConnection) {
        checkRealConnectivity();
      } else {
        // Không có kết nối mạng, chắc chắn không có internet
        _updateConnectionStatus(false);
      }
    }
  }

  /// Kiểm tra trạng thái kết nối hiện tại
  Future<void> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _processConnectivityResults(results);
    } catch (e) {
      debugPrint('ConnectivityService: Lỗi kiểm tra kết nối: $e');
      _updateConnectionStatus(false);
    }
  }
  
  /// Kiểm tra kết nối internet thực
  Future<void> checkRealConnectivity() async {
    // Trước tiên, kiểm tra xem có kết nối mạng không
    final networkResults = await _connectivity.checkConnectivity();
    final hasNetworkConnection = networkResults.any((result) => result != ConnectivityResult.none);
    
    if (!hasNetworkConnection) {
      _updateConnectionStatus(false);
      return;
    }
    
    // Bắt đầu kiểm tra kết nối internet thực
    try {
      // Thử kết nối tới một trong các URL kiểm tra
      final url = _connectionCheckUrls[0]; // Sử dụng URL đầu tiên
      
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        // Timeout = không có kết nối
        throw TimeoutException('Connection check timed out');
      });
      
      _updateConnectionStatus(response.statusCode >= 200 && response.statusCode < 300);
    } catch (e) {
      debugPrint('ConnectivityService: Lỗi kiểm tra internet thực: $e');
      
      // Thử kết nối với URL dự phòng
      try {
        final backupUrl = _connectionCheckUrls[1];
        final response = await http.get(Uri.parse(backupUrl))
            .timeout(const Duration(seconds: 3));
        
        _updateConnectionStatus(response.statusCode >= 200 && response.statusCode < 300);
      } catch (_) {
        // Nếu cả hai đều thất bại, coi như không có kết nối
        _updateConnectionStatus(false);
      }
    }
  }

  /// Cập nhật trạng thái kết nối và thông báo nếu thay đổi
  void _updateConnectionStatus(bool hasConnection) {
    // Chỉ cập nhật khi trạng thái thay đổi
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      _connectionStatusController.add(hasConnection);
      debugPrint('ConnectivityService: Trạng thái kết nối thay đổi - ${hasConnection ? 'Đã kết nối' : 'Mất kết nối'}');
    }
  }

  /// Dọn dẹp tài nguyên
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicConnectionCheck?.cancel();
    _connectionStatusController.close();
  }
} 