import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../mock_db.dart';
import '../widgets/cotejo_sheet.dart';

class ScannerScreen extends StatefulWidget {
  final FolioItem folioItem;
  final VoidCallback onSaveCount;

  const ScannerScreen({
    super.key,
    required this.folioItem,
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

    // Match validation: does the scanned barcode match the expected MSPN?
    if (rawValue.trim() == widget.folioItem.mspn.trim()) {
      // MATCH! Open Cotejo Sheet
      _scannerController.stop();
      
      // Calcular la cantidad física incrementada en 1 por el escaneo
      final newPhysicalCount = widget.folioItem.physicalQty + 1;
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CotejoSheet(
          folioItem: widget.folioItem,
          physicalCount: newPhysicalCount,
          onSave: () {
            widget.onSaveCount();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Conteo guardado exitosamente.',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ).then((_) {
        _scannerController.start();
        setState(() {
          _isProcessing = false;
        });
      });
    } else {
      // NO MATCH! Show warning
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Código no coincide con MSPN: $rawValue',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.redAccent.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Brief delay to prevent continuous invalid scans triggering toast spam
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
          // 1. Camera view
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // 2. Custom laser scanner overlay
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

          // 3. Expected item header card (Slate neutral mode styled top card)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nav bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCircularButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'ESCANEAR PRODUCTO',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
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
                const SizedBox(height: 12),

                // Target Product Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withOpacity(0.9), // Slate 800 translucid
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4F46E5).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.qr_code,
                          color: Color(0xFF818CF8),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESPERADO (MSPN: ${widget.folioItem.mspn})',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF818CF8),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.folioItem.description,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Instructions bottom card
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Escanea el código de barras del producto para hacer match',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
          width: 44,
          height: 44,
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
            size: 18,
          ),
        ),
      ),
    );
  }
}

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

    final double left = (screenWidth - scanAreaSize) / 2;
    final double top = (screenHeight - scanAreaSize) / 2;
    final Rect scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    final Paint maskPaint = Paint()..color = Colors.black.withOpacity(0.65);
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight)), Path()..addRect(scanRect)),
      maskPaint,
    );

    final Paint borderPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    const double cornerLength = 30.0;

    // Top Left Corner
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

    final Paint innerBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(scanRect, innerBorderPaint);

    final double lineY = scanRect.top + (scanRect.height * scanLinePosition);
    final Paint laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4F46E5).withOpacity(0.0),
          const Color(0xFF818CF8),
          const Color(0xFF4F46E5).withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTRB(scanRect.left, lineY - 2, scanRect.right, lineY + 2));

    canvas.drawRect(
      Rect.fromLTRB(scanRect.left + 4, lineY - 2, scanRect.right - 4, lineY + 2),
      laserPaint,
    );

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
