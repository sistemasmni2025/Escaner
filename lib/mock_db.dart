class Product {
  final String sku;
  final String name;
  final String category;
  final int theoreticalStock;
  final double price;
  final String imageUrl;

  const Product({
    required this.sku,
    required this.name,
    required this.category,
    required this.theoreticalStock,
    required this.price,
    this.imageUrl = '',
  });
}

class MockDatabase {
  static const List<Product> products = [
    Product(
      sku: '7501055310014',
      name: 'Coca-Cola Original 600ml',
      category: 'Bebidas',
      theoreticalStock: 24,
      price: 18.50,
    ),
    Product(
      sku: '7501008023451',
      name: 'Papas Sabritas Sal 110g',
      category: 'Botanas',
      theoreticalStock: 15,
      price: 34.00,
    ),
    Product(
      sku: '7501011115853',
      name: 'Galletas Chokis Clásicas 84g',
      category: 'Galletas',
      theoreticalStock: 18,
      price: 16.50,
    ),
    Product(
      sku: '7500478018306',
      name: 'Leche Entera Lala 1L',
      category: 'Lácteos',
      theoreticalStock: 12,
      price: 26.00,
    ),
    Product(
      sku: '7501020542381',
      name: 'Detergente Ariel Power Liquid 1.2L',
      category: 'Limpieza',
      theoreticalStock: 8,
      price: 65.00,
    ),
    Product(
      sku: '7501031302837',
      name: 'Aceite Vegetal 1-2-3 1L',
      category: 'Abarrotes',
      theoreticalStock: 20,
      price: 42.00,
    ),
    Product(
      sku: '123456789012',
      name: 'Llanta Michelin Primacy 4 205/55R16',
      category: 'Llantas',
      theoreticalStock: 8,
      price: 2450.00,
    ),
    Product(
      sku: '987654321098',
      name: 'Amortiguador Gabriel Delantero',
      category: 'Suspensión',
      theoreticalStock: 4,
      price: 1200.00,
    ),
    Product(
      sku: '111111111111',
      name: 'Batería LTH HI-TEC H-24R',
      category: 'Eléctrico',
      theoreticalStock: 6,
      price: 2800.00,
    ),
    Product(
      sku: '222222222222',
      name: 'Balatas Delanteras TRW Cerámica',
      category: 'Frenos',
      theoreticalStock: 12,
      price: 850.00,
    ),
    Product(
      sku: '00000000', // Test SKU for easy simulation in simulator
      name: 'Producto Demo Premium',
      category: 'Prueba',
      theoreticalStock: 10,
      price: 99.99,
    ),
  ];

  static Product? findBySku(String sku) {
    try {
      return products.firstWhere((p) => p.sku == sku);
    } catch (_) {
      return null;
    }
  }
}
