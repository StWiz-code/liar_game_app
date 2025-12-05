import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/nearby_service.dart'; // 여기서 Device, SessionState 등을 다 가져옵니다.
import 'core/theme/app_theme.dart';
// [삭제됨] 외부 패키지 import를 제거하여 이름 충돌 방지
// import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  late final NearbyService _nearbyService;

  @override
  void initState() {
    super.initState();
    _nearbyService = Provider.of<NearbyService>(context, listen: false);
  }

  @override
  void dispose() {
    // 화면이 사라질 때 모든 연결과 탐색을 중지합니다.
    _nearbyService.disconnectAll();
    super.dispose();
  }

  String _getDeviceStateText(SessionState state) {
    switch (state) {
      case SessionState.connected:
        return '연결됨';
      case SessionState.connecting:
        return '연결 중...';
      case SessionState.notConnected:
        return '대기 중';
      // [수정] 모든 케이스를 다루므로 default 절 제거 (Lint 해결)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('함께하기')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '내 기기 이름: ${_nearbyService.myDeviceName}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              // 현재 상태에 따라 다른 UI 표시
              Consumer<NearbyService>(
                builder: (context, service, child) {
                  // [수정] 이제 service는 우리가 만든 NearbyService로 정확히 인식됩니다.
                  if (service.isHosting) {
                    return _buildHostingUI(service);
                  }
                  if (service.isSearching) {
                    return _buildSearchingUI(service);
                  }
                  return _buildInitialUI(service);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 초기 화면 UI (방 만들기 / 참가하기)
  Widget _buildInitialUI(NearbyService service) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientButton(
            onPressed: () => service.startAdvertising(),
            text: '방 만들기',
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: () => service.startBrowsing(),
            text: '게임 참가하기',
          ),
        ],
      ),
    );
  }

  // 방장(Host)일 때의 UI
  Widget _buildHostingUI(NearbyService service) {
    final connectedPlayers = service.devices
        .where((d) => d.state == SessionState.connected)
        .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참가자를 기다리는 중...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: service.devices.length,
              itemBuilder: (context, index) {
                final device = service.devices[index];
                return Card(
                  child: ListTile(
                    title: Text(device.deviceName),
                    trailing: Text(_getDeviceStateText(device.state)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GradientButton(
            onPressed: (connectedPlayers.length + 1) >= 3
                ? () {
                    /* 게임 시작 로직 (2단계에서 구현) */
                  }
                : null,
            text: '게임 시작 (${connectedPlayers.length + 1}명)',
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => service.stopAdvertising(),
            child: const Text('방 닫기'),
          ),
        ],
      ),
    );
  }

  // 참가자일 때의 UI
  Widget _buildSearchingUI(NearbyService service) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참여할 게임을 찾는 중...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: service.devices.isEmpty
                ? const Center(child: Text('발견된 게임이 없습니다.'))
                : ListView.builder(
                    itemCount: service.devices.length,
                    itemBuilder: (context, index) {
                      final device = service.devices[index];
                      final isConnected =
                          device.state == SessionState.connected;

                      return Card(
                        child: ListTile(
                          title: Text(device.deviceName),
                          subtitle: Text(_getDeviceStateText(device.state)),
                          trailing: isConnected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                              : const Icon(Icons.login),
                          onTap: isConnected
                              ? null
                              : () => service.connect(device),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => service.stopBrowsing(),
            child: const Text('찾기 중단'),
          ),
        ],
      ),
    );
  }
}
