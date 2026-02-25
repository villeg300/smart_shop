import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_shop/controllers/admin_order_controller.dart';
import 'package:smart_shop/view/admin/admin_order_detail_screen.dart';

enum AdminScanMode { find, process }

class AdminScanOrderScreen extends StatefulWidget {
  const AdminScanOrderScreen({
    super.key,
    this.mode = AdminScanMode.find,
    this.title,
  });

  final AdminScanMode mode;
  final String? title;

  @override
  State<AdminScanOrderScreen> createState() => _AdminScanOrderScreenState();
}

class _AdminScanOrderScreenState extends State<AdminScanOrderScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late final AdminOrderController _adminOrderController;
  late final TextEditingController _manualOrderIdController;

  PermissionStatus? _cameraPermissionStatus;
  MobileScannerException? _scannerError;
  bool _isResolving = false;

  String get _screenTitle {
    if (widget.title != null && widget.title!.trim().isNotEmpty) {
      return widget.title!.trim();
    }
    return widget.mode == AdminScanMode.process
        ? 'Scanner pour prise en charge'
        : 'Scanner une commande';
  }

  @override
  void initState() {
    super.initState();
    _adminOrderController = Get.isRegistered<AdminOrderController>()
        ? Get.find<AdminOrderController>()
        : Get.put(AdminOrderController());
    _manualOrderIdController = TextEditingController();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _manualOrderIdController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final current = await Permission.camera.status;

    if (current.isGranted) {
      if (!mounted) return;
      setState(() {
        _cameraPermissionStatus = current;
      });
      return;
    }

    final requested = await Permission.camera.request();
    if (!mounted) return;

    setState(() {
      _cameraPermissionStatus = requested;
    });
  }

  Future<void> _handleRawValue(String rawValue) async {
    if (_isResolving) return;

    final orderId = AdminOrderController.extractOrderIdFromScan(rawValue);
    if (orderId == null) {
      Get.snackbar(
        'QR invalide',
        'Ce QR ne correspond pas à une commande SmartShop.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _isResolving = true;
    });

    if (widget.mode == AdminScanMode.process) {
      final processed = await _adminOrderController.markOrderProcessingById(
        orderId,
      );
      if (!processed) {
        if (!mounted) return;
        setState(() {
          _isResolving = false;
        });
        return;
      }
    }

    try {
      await _scannerController.stop();
    } catch (_) {
      // Le flux continue même si le stop échoue.
    }

    if (!mounted) return;
    Get.off(() => AdminOrderDetailScreen(orderId: orderId));
  }

  Future<void> _openManualOrder() async {
    final raw = _manualOrderIdController.text.trim();
    if (raw.isEmpty) return;
    await _handleRawValue(raw);
  }

  void _handleScannerError(MobileScannerException error) {
    if (_scannerError?.errorCode == error.errorCode) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _scannerError = error;
      });
    });
  }

  String _scannerErrorMessage(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Permission caméra refusée. Autorisez la caméra pour scanner.';
      case MobileScannerErrorCode.unsupported:
        return 'Scanner non supporté. Sur émulateur sans caméra, utilisez un appareil réel.';
      case MobileScannerErrorCode.controllerNotAttached:
      case MobileScannerErrorCode.controllerInitializing:
      case MobileScannerErrorCode.controllerUninitialized:
      case MobileScannerErrorCode.controllerAlreadyInitialized:
      case MobileScannerErrorCode.controllerDisposed:
      case MobileScannerErrorCode.genericError:
        return 'Initialisation caméra impossible (${error.errorCode.name}).';
    }
  }

  Widget _buildUnavailableScanner(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _scannerError = null;
                    });
                    _requestCameraPermission();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
                if (_cameraPermissionStatus?.isPermanentlyDenied == true)
                  ElevatedButton.icon(
                    onPressed: openAppSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Paramètres'),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'La saisie manuelle reste disponible ci-dessous.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerArea(BuildContext context) {
    if (_cameraPermissionStatus == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cameraPermissionStatus?.isGranted != true) {
      final text = _cameraPermissionStatus?.isPermanentlyDenied == true
          ? 'Permission caméra bloquée. Activez-la dans les paramètres Android.'
          : 'Permission caméra requise pour scanner.';
      return _buildUnavailableScanner(context, text);
    }

    if (_scannerError != null) {
      return _buildUnavailableScanner(
        context,
        _scannerErrorMessage(_scannerError!),
      );
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final raw = barcode.rawValue;
              if (raw == null || raw.trim().isEmpty) {
                continue;
              }
              _handleRawValue(raw);
              break;
            }
          },
          errorBuilder: (context, error) {
            _handleScannerError(error);
            return _buildUnavailableScanner(
              context,
              _scannerErrorMessage(error),
            );
          },
        ),
        IgnorePointer(
          child: Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.mode == AdminScanMode.process
                  ? 'Scannez pour passer la commande en traitement'
                  : 'Placez le QR de la commande dans le cadre',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        if (_isResolving)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannerEnabled =
        _cameraPermissionStatus?.isGranted == true && _scannerError == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
        actions: [
          IconButton(
            tooltip: 'Activer/Désactiver flash',
            onPressed: scannerEnabled
                ? () => _scannerController.toggleTorch()
                : null,
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
          IconButton(
            tooltip: 'Changer caméra',
            onPressed: scannerEnabled
                ? () => _scannerController.switchCamera()
                : null,
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildScannerArea(context)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ou saisir un ID manuellement',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualOrderIdController,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'SS-ODR-...',
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                          onSubmitted: (_) => _openManualOrder(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _openManualOrder,
                        child: Text(
                          widget.mode == AdminScanMode.process
                              ? 'Prendre en charge'
                              : 'Ouvrir',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
