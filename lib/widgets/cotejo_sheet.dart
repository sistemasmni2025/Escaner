import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mock_db.dart';

class CotejoSheet extends StatefulWidget {
  final FolioItem folioItem;
  final int physicalCount;
  final VoidCallback onSave;

  const CotejoSheet({
    super.key,
    required this.folioItem,
    required this.physicalCount,
    required this.onSave,
  });

  @override
  State<CotejoSheet> createState() => _CotejoSheetState();
}

class _CotejoSheetState extends State<CotejoSheet> {
  late int _physicalCount;

  @override
  void initState() {
    super.initState();
    _physicalCount = widget.physicalCount;
  }

  @override
  Widget build(BuildContext context) {
    final difference = _physicalCount - widget.folioItem.theoreticalQty;

    // Define colors and styles based on the status (System iOS colors)
    Color statusColor;
    String statusText;
    IconData statusIcon;
    Color statusBgColor;

    if (difference == 0) {
      statusColor = const Color(0xFF34C759); // iOS System Green
      statusBgColor = const Color(0xFFE4F9E9); // Very light green tint
      statusText = 'Inventario Cuadrado';
      statusIcon = Icons.check_circle_outline;
    } else if (difference < 0) {
      statusColor = const Color(0xFFFF9500); // iOS System Orange
      statusBgColor = const Color(0xFFFFF2E0); // Very light orange tint
      statusText = 'Faltante: ${difference.abs()} u';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = const Color(0xFF007AFF); // iOS System Blue
      statusBgColor = const Color(0xFFE5F1FF); // Very light blue tint
      statusText = 'Excedente: +$difference u';
      statusIcon = Icons.add_circle_outline_rounded;
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)), // Apple style modal radius
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA), // Apple light gray separator
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Product Header Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7), // System Gray 6
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Color(0xFF007AFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.folioItem.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'MSPN: ${widget.folioItem.mspn}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF8E8E93),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quantities Row (Teórico vs Físico) with Vertical Separator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Theoretical Col
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'TEÓRICO',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF8E8E93),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${widget.folioItem.theoreticalQty}',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF3A3A3C),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'uds',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF8E8E93),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  const VerticalDivider(
                    color: Color(0xFFE5E5EA),
                    thickness: 0.5,
                    width: 1,
                  ),

                  // Physical Col
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'FÍSICO',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF007AFF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$_physicalCount',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF007AFF),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'uds',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF8E8E93),
                                fontWeight: FontWeight.w500,
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
          ),
          const SizedBox(height: 16),

          // Comparison status banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor.withOpacity(0.2), width: 0.5),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save Action Button
          ElevatedButton(
            onPressed: () {
              widget.folioItem.physicalQty = _physicalCount;
              widget.onSave();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF), // Apple Blue
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Guardar Conteo',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
