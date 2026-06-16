import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../mock_db.dart';
import '../widgets/cotejo_sheet.dart';

class ScannerScreen extends StatefulWidget {
  final Function(Product product, int physicalCount) onSaveCount;

  const ScannerScreen({
    super.key,
    required this.onSaveCount,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;
  bool _isTorchOn = false;

  late AnimationController _animationController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    final Product? product = MockDatabase.findBySku(rawValue);

    if (product != null) {
      // Product found! Show premium Cotejo Sheet
      _scannerController.stop(); // Optional: pause camera feed
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CotejoSheet(
          product: product,
          onSave: (physicalCount) {
            widget.onSaveCount(product, physicalCount);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Conteo guardado para: ${product.name}',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color(0xFF6366F1),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ).then((_) {
        // Resume scanning when modal closes
        _scannerController.start();
        setState(() {
          _isProcessing = false;
        });
      });
    } else {
      // Product not found, show elegant notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Código no registrado: $rawValue',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      // Delay slightly before allowing another scan to avoid spam
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // 2. Custom Tech Design Overlay
          AnimatedBuilder(
            animation: _scanLineAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: ScannerOverlayPainter(
                  scanLinePosition: _scanLineAnimation.value,
                  scanAreaSize: 260.0,
                ),
              );
            },
          ),

          // 3. UI Controls Overlay (Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back button
                _buildCircularButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // Screen Title
                Text(
                  'ESCANEO DE PRODUCTO',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                // Flash button
                _buildCircularButton(
                  icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  onPressed: () {
                    _scannerController.toggleTorch();
                    setState(() {
                      _isTorchOn = !_isTorchOn;
                    });
                  },
                  color: _isTorchOn ? Colors.amber.withOpacity(0.3) : null,
                  iconColor: _isTorchOn ? Colors.amber : Colors.white,
                ),
              ],
            ),
          ),

          // 4. Instructions Card (Bottom)
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2F).withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Color(0xFF818CF8),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apunta al código',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Posiciona el código de barras o QR dentro de la retícula',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    Color iconColor = Colors.white,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color ?? Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// Custom Painter to draw target frame, blur outside, and moving laser line
class ScannerOverlayPainter extends CustomPainter {
  final double scanLinePosition;
  final double scanAreaSize;

  ScannerOverlayPainter({
    required this.scanLinePosition,
    required this.scanAreaSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    // Calculate bounding rect of the scan area (centered)
    final double left = (screenWidth - scanAreaSize) / 2;
    final double top = (screenHeight - scanAreaSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // 1. Draw darker background outside of scan area
    final Paint maskPaint = Paint()..color = Colors.black.withOpacity(0.65);
    final Path maskPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight))
      ..addRect(scanRect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight)), Path()..addRect(scanRect)),
      maskPaint,
    );

    // 2. Draw modern Tech Grid Borders around Scan Area
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30.0;

    // Bottom Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.top + cornerLength)
        ..lineTo(scanRect.left, scanRect.top)
        ..lineTo(scanRect.left + cornerLength, scanRect.top),
      borderPaint,
    );

    // Top Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top)
        ..lineTo(scanRect.right, scanRect.top + cornerLength),
      borderPaint,
    );

    // Bottom Left Corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.left, scanRect.bottom - cornerLength)
        ..lineTo(scanRect.left, scanRect.bottom)
        ..lineTo(scanRect.left + cornerLength, scanRect.bottom),
      borderPaint,
    );

    // Bottom Right Corner
    canvas.drawPath(
      Path()
        ..moveTo(scanRect.right - cornerLength, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom)
        ..lineTo(scanRect.right, scanRect.bottom - cornerLength),
      borderPaint,
    );

    // Draw a thin inner border
    final Paint innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(scanRect, innerBorderPaint);

    // 3. Draw scanning laser line
    final double lineY = scanRect.top + (scanRect.height * scanLinePosition);
    final Paint laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF6366F1).withOpacity(0.0),
          const Color(0xFF818CF8),
          const Color(0xFF6366F1).withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(scanRect.left, lineY - 2, scanRect.right, lineY + 2));

    canvas.drawRect(
      Rect.fromLTRB(scanRect.left + 4, lineY - 2, scanRect.right - 4, lineY + 2),
      laserPaint,
    );

    // Laser glow overlay
    final Paint glowPaint = Paint()
      ..color = const Color(0xFF818CF8).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
      Rect.fromLTRB(scanRect.left + 8, lineY - 6, scanRect.right - 8, lineY + 6),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
