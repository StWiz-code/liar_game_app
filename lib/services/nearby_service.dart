import 'dart:async';
import 'package:flutter/foundation.dart';
// [수정 핵심] 이름 충돌 방지를 위해 'as nearby_sdk' 별칭 사용
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart'
    as nearby_sdk;

// UI에서 사용할 타입들은 그대로 내보냅니다.
export 'package:flutter_nearby_connections/flutter_nearby_connections.dart'
    show Device, SessionState, Strategy;

class NearbyService with ChangeNotifier {
  // [수정] 패키지의 클래스를 사용할 때는 별칭(nearby_sdk)을 붙임
  late final nearby_sdk.NearbyService _nearbyService;
  late StreamSubscription? _stateSubscription;
  late StreamSubscription? _dataSubscription;

  final List<nearby_sdk.Device> _devices = [];
  List<nearby_sdk.Device> get devices => _devices;

  String myDeviceId = '';
  final String myDeviceName;

  bool isHosting = false;
  bool isSearching = false;

  NearbyService() : myDeviceName = "Player_${DateTime.now().second}" {
    _init();
  }

  Future<void> _init() async {
    // [수정] 별칭 사용
    _nearbyService = nearby_sdk.NearbyService();

    await _nearbyService.init(
      serviceType: 'mp-connection',
      strategy: nearby_sdk.Strategy.P2P_STAR,
      callback: (isRunning) async {
        if (isRunning) {
          // 초기화 성공 로직
        }
      },
    );

    _stateSubscription = _nearbyService.stateChangedSubscription(
      callback: (devicesList) {
        _devices.clear();
        _devices.addAll(devicesList);
        notifyListeners();
      },
    );

    _dataSubscription = _nearbyService.dataReceivedSubscription(
      callback: (data) {
        debugPrint("데이터 수신: $data");
      },
    );
  }

  Future<void> startBrowsing() async {
    if (isSearching || isHosting) return;
    try {
      isSearching = true;
      notifyListeners();

      await _nearbyService.stopAdvertisingPeer();
      await _nearbyService.stopBrowsingForPeers();
      await Future.delayed(const Duration(milliseconds: 200));
      await _nearbyService.startBrowsingForPeers();
    } catch (e) {
      isSearching = false;
      notifyListeners();
      debugPrint("탐색 시작 오류: $e");
    }
  }

  Future<void> stopBrowsing() async {
    isSearching = false;
    await _nearbyService.stopBrowsingForPeers();
    notifyListeners();
  }

  Future<void> startAdvertising() async {
    if (isSearching || isHosting) return;
    try {
      isHosting = true;
      notifyListeners();

      await _nearbyService.stopBrowsingForPeers();
      await _nearbyService.stopAdvertisingPeer();
      await Future.delayed(const Duration(milliseconds: 200));
      await _nearbyService.startAdvertisingPeer();
    } catch (e) {
      isHosting = false;
      notifyListeners();
      debugPrint("방 만들기 오류: $e");
    }
  }

  Future<void> stopAdvertising() async {
    isHosting = false;
    await _nearbyService.stopAdvertisingPeer();
    notifyListeners();
  }

  Future<void> connect(nearby_sdk.Device device) async {
    try {
      await _nearbyService.invitePeer(
        deviceID: device.deviceId,
        deviceName: myDeviceName,
      );
    } catch (e) {
      debugPrint("연결 요청 오류: $e");
    }
  }

  Future<void> disconnect(nearby_sdk.Device device) async {
    try {
      await _nearbyService.disconnectPeer(deviceID: device.deviceId);
    } catch (e) {
      debugPrint("연결 해제 오류: $e");
    }
  }

  void disconnectAll() {
    stopAdvertising();
    stopBrowsing();
    _stateSubscription?.cancel();
    _dataSubscription?.cancel();
    _devices.clear();
    notifyListeners();
  }
}
