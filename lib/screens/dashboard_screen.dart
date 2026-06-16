import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mock_db.dart';
import 'scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Key represents the SKU, value is the physical count
  final Map<String, int> _counts = {};

  // Track the history order of scans
  final List<String> _scanHistory = [];

  void _registerCount(Product product, int physicalCount) {
    setState(() {
      if (!_counts.containsKey(product.sku)) {
        _scanHistory.insert(0, product.sku); // Add to start of history
      }
      _counts[product.sku] = physicalCount;
    });
  }

  void _clearCounts() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2F),
        title: Text(
          '¿Reiniciar Inventario?',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Se eliminarán todos los conteos físicos registrados en esta sesión.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.plusJakartaSans(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _counts.clear();
                _scanHistory.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Reiniciar',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Computations
    final totalCounted = _counts.length;
    int discrepancies = 0;
    int perfectMatches = 0;

    _counts.forEach((sku, physical) {
      final product = MockDatabase.findBySku(sku);
      if (product != null) {
        if (physical == product.theoreticalStock) {
          perfectMatches++;
        } else {
          discrepancies++;
        }
      }
    });

    final accuracy = totalCounted == 0
        ? 100.0
        : (perfectMatches / totalCounted) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Ultra premium deep space black/blue
      body: Stack(
        children: [
          // Background Gradient Orbs for glassmorphism layout
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFEC4899).withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),

          // Main Content Scrollable
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Premium App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESCANER MÓVIL',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF818CF8),
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Conteo de Inventario',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        // Reset button
                        if (_counts.isNotEmpty)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _clearCounts,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 2. Dashboard Statistics Panels
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      children: [
                        // Large Accuracy Glass Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.06),
                                Colors.white.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRECISIÓN DE CONCILIACIÓN',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white38,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${accuracy.toStringAsFixed(1)}%',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      totalCounted == 0
                                          ? 'Sin productos escaneados'
                                          : '$perfectMatches de $totalCounted productos cuadran exactamente',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Custom Radial Progress Indicator
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CircularProgressIndicator(
                                      value: accuracy / 100,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white.withOpacity(0.06),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        accuracy == 100.0 && totalCounted > 0
                                            ? Colors.green.shade400
                                            : accuracy > 75.0
                                                ? const Color(0xFF6366F1)
                                                : Colors.orange.shade400,
                                      ),
                                    ),
                                    Center(
                                      child: Icon(
                                        accuracy == 100.0 && totalCounted > 0
                                            ? Icons.verified_user_outlined
                                            : Icons.analytics_outlined,
                                        color: Colors.white70,
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Two smaller boxes for detailed stats
                        Row(
                          children: [
                            // Items Counted Box
                            Expanded(
                              child: _buildSmallStatCard(
                                title: 'ESCANEO TOTAL',
                                value: '$totalCounted',
                                subtitle: 'Productos',
                                icon: Icons.assignment_turned_in_outlined,
                                iconColor: const Color(0xFF818CF8),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Discrepancies Box
                            Expanded(
                              child: _buildSmallStatCard(
                                title: 'DIFERENCIAS',
                                value: '$discrepancies',
                                subtitle: discrepancies == 0 ? 'Sin desvíos' : 'Por corregir',
                                icon: Icons.error_outline,
                                iconColor: discrepancies == 0 ? Colors.green.shade400 : Colors.orange.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Section Title - History
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 24.0, bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actividad Reciente',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (_scanHistory.isNotEmpty)
                          Text(
                            'Historial de Conteo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 4. Scanned List (History)
                if (_scanHistory.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: Colors.white.withOpacity(0.07),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Historial vacío',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pulsa el botón flotante para escanear',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final sku = _scanHistory[index];
                        final product = MockDatabase.findBySku(sku)!;
                        final physical = _counts[sku]!;
                        final diff = physical - product.theoreticalStock;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.02),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icon based on status
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: diff == 0
                                      ? Colors.green.withOpacity(0.08)
                                      : diff < 0
                                          ? Colors.orange.withOpacity(0.08)
                                          : Colors.blue.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  diff == 0
                                      ? Icons.check
                                      : diff < 0
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                  color: diff == 0
                                      ? Colors.green.shade400
                                      : diff < 0
                                          ? Colors.orange.shade400
                                          : Colors.blue.shade400,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Name & Category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Físico: $physical | Teórico: ${product.theoreticalStock}',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Difference Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: diff == 0
                                      ? Colors.green.withOpacity(0.1)
                                      : diff < 0
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  diff == 0
                                      ? 'OK'
                                      : diff < 0
                                          ? '$diff'
                                          : '+$diff',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: diff == 0
                                        ? Colors.green.shade400
                                        : diff < 0
                                            ? Colors.orange.shade400
                                            : Colors.blue.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: _scanHistory.length,
                    ),
                  ),

                // Space at bottom for floating action button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
          ),

          // 5. FAB Centered Glow trigger for camera scanner screen
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: const Color(0xFF6366F1),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ScannerScreen(
                            onSaveCount: _registerCount,
                          ),
                        ),
                      );
                    },
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white38,
                  letterSpacing: 1.0,
                ),
              ),
              Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
