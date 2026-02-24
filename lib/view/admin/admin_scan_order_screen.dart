import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_shop/controllers/admin_order_controller.dart';
import 'package:smart_shop/view/admin/admin_order_detail_screen.dart';

class AdminScanOrderScreen extends StatefulWidget {
  const AdminScanOrderScreen({super.key});

  @override
  State<AdminScanOrderScreen> createState() => _AdminScanOrderScreenState();
}

class _AdminScanOrderScreenState extends State<AdminScanOrderScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  late final TextEditingController _manualOrderIdController;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _manualOrderIdController = TextEditingController();
  }

  @override
  void dispose() {
    _manualOrderIdController.dispose();
    _scannerController.dispose();
    super.dispose();
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

    await _scannerController.stop();
    if (!mounted) return;

    Get.off(() => AdminOrderDetailScreen(orderId: orderId));
  }

  Future<void> _openManualOrder() async {
    final raw = _manualOrderIdController.text.trim();
    if (raw.isEmpty) return;
    await _handleRawValue(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner une commande'),
        actions: [
          IconButton(
            tooltip: 'Activer/Désactiver flash',
            onPressed: () => _scannerController.toggleTorch(),
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
          IconButton(
            tooltip: 'Changer caméra',
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Placez le QR de la commande dans le cadre',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  if (_isResolving)
                    Container(
                      color: Colors.black45,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
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
                        child: const Text('Ouvrir'),
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
