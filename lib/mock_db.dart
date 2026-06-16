class FolioItem {
  final String mspn;
  final String description;
  final int theoreticalQty;
  int physicalQty;

  FolioItem({
    required this.mspn,
    required this.description,
    required this.theoreticalQty,
    this.physicalQty = 0,
  });
}

class Folio {
  final String id;
  final String name;
  final List<FolioItem> items;

  Folio({
    required this.id,
    required this.name,
    required this.items,
  });
}

class MockDatabase {
  static final List<Folio> _folios = [
    Folio(
      id: '98000',
      name: 'Recepción Llantas & Suspensión Celaya',
      items: [
        FolioItem(
          mspn: '123456789012',
          description: 'Llanta Michelin Primacy 4 205/55R16',
          theoreticalQty: 8,
        ),
        FolioItem(
          mspn: '987654321098',
          description: 'Amortiguador Gabriel Delantero Premium',
          theoreticalQty: 4,
        ),
        FolioItem(
          mspn: '111111111111',
          description: 'Batería LTH HI-TEC H-24R 12V',
          theoreticalQty: 6,
        ),
      ],
    ),
    Folio(
      id: '999',
      name: 'Auditoría de Inventario Rápido',
      items: [
        FolioItem(
          mspn: '222222222222',
          description: 'Balatas Delanteras TRW Cerámica',
          theoreticalQty: 12,
        ),
        FolioItem(
          mspn: '7501055310014',
          description: 'Coca-Cola Original 600ml',
          theoreticalQty: 24,
        ),
        FolioItem(
          mspn: '00000000',
          description: 'Producto Demo de Cotejo Rápido',
          theoreticalQty: 10,
        ),
      ],
    ),
  ];

  static Folio? findFolioById(String id) {
    try {
      return _folios.firstWhere(
        (f) => f.id.trim().toUpperCase() == id.trim().toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}
