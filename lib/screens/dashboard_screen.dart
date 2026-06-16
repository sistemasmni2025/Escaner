import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mock_db.dart';
import 'scanner_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Folio folio;

  const DashboardScreen({super.key, required this.folio});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _onItemUpdated() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int totalTheoretical = 0;
    int totalPhysical = 0;

    for (var item in widget.folio.items) {
      totalTheoretical += item.theoreticalQty;
      totalPhysical += item.physicalQty;
    }

    final realPercentage = totalTheoretical == 0
        ? 0.0
        : (totalPhysical / totalTheoretical) * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Apple System Gray 6
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF007AFF), size: 20), // iOS style back arrow
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.folio.id,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xFFE5E5EA), // Apple thin separator
            width: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Inset Grouped Header Card (Apple style)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10), // iOS corners
                border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REFERENCIA',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF8E8E93),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.folio.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Metrics Block (Teórico vs Real) with macOS Dividers
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Teórico Col
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
                          Text(
                            '100%',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF3A3A3C),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalTheoretical uds en total',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF8E8E93),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Thin vertical separator line (macOS style)
                    const VerticalDivider(
                      color: Color(0xFFE5E5EA),
                      thickness: 0.5,
                      width: 1,
                    ),

                    // Real Col
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'REAL',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF007AFF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${realPercentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: realPercentage == 100.0
                                  ? const Color(0xFF34C759) // iOS System Green
                                  : const Color(0xFF007AFF), // iOS System Blue
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalPhysical de $totalTheoretical uds',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF8E8E93),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Table Header label (Sobria iOS style)
            Padding(
              padding: const EdgeInsets.only(left: 28.0, bottom: 6.0),
              child: Text(
                'PRODUCTOS EN ESTA REFERENCIA',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF8E8E93),
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // 3. Products List in Inset Grouped layout (iOS list tile group)
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.folio.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.folio.items[index];
                      final isMatched = item.physicalQty == item.theoreticalQty;

                      return Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ScannerScreen(
                                      folioItem: item,
                                      onSaveCount: _onItemUpdated,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                                child: Row(
                                  children: [
                                    // MSPN / Code
                                    Container(
                                      constraints: const BoxConstraints(minWidth: 72),
                                      child: Text(
                                        item.mspn,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Description Column
                                    Expanded(
                                      child: Text(
                                        item.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF3A3A3C),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Quantity Pill Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isMatched
                                            ? const Color(0xFFE4F9E9) // Very soft iOS green tint
                                            : const Color(0xFFE5F1FF), // Very soft iOS blue tint
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${item.physicalQty}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: isMatched
                                                  ? const Color(0xFF34C759) // iOS System Green
                                                  : const Color(0xFF007AFF), // iOS System Blue
                                            ),
                                          ),
                                          Text(
                                            ' / ${item.theoreticalQty}',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF8E8E93),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios, // iOS style navigation indicator
                                      color: Color(0xFFC7C7CC),
                                      size: 13,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // iOS fine separator lines
                          if (index < widget.folio.items.length - 1)
                            const Divider(
                              color: Color(0xFFE5E5EA),
                              height: 0.5,
                              thickness: 0.5,
                              indent: 16, // iOS indentation style
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
