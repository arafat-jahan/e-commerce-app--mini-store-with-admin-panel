import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await seedProducts();
  debugPrint('✅ All 30 products added successfully!');
}

Future<void> seedProducts() async {
  final db = FirebaseFirestore.instance;

  final products = [
    // Electronics
    {'name': 'Wireless Noise-Cancelling Headphones', 'price': 79.99, 'category': 'Electronics', 'stock': 30, 'isActive': true, 'description': 'Premium over-ear headphones with active noise cancellation, 30-hour battery life, and foldable design. Perfect for travel and work.', 'imageUrl': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'},
    {'name': 'Smart Watch Pro', 'price': 129.99, 'category': 'Electronics', 'stock': 20, 'isActive': true, 'description': 'Advanced smartwatch with health tracking, built-in GPS, heart rate monitor, sleep tracking, and 7-day battery life.', 'imageUrl': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400'},
    {'name': 'Portable Bluetooth Speaker', 'price': 49.99, 'category': 'Electronics', 'stock': 35, 'isActive': true, 'description': 'Waterproof IPX7 portable speaker with 360° surround sound, 20-hour playtime, and built-in microphone.', 'imageUrl': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400'},
    {'name': 'Mechanical Keyboard', 'price': 89.99, 'category': 'Electronics', 'stock': 25, 'isActive': true, 'description': 'Compact TKL mechanical keyboard with RGB per-key backlight, tactile blue switches, and aluminum frame.', 'imageUrl': 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=400'},
    {'name': 'Wireless Ergonomic Mouse', 'price': 39.99, 'category': 'Electronics', 'stock': 50, 'isActive': true, 'description': 'Silent wireless mouse with ergonomic vertical design, 6 programmable buttons, and 12-month battery life.', 'imageUrl': 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400'},
    {'name': '4K Webcam', 'price': 99.99, 'category': 'Electronics', 'stock': 18, 'isActive': true, 'description': 'Ultra HD 4K webcam with autofocus, built-in ring light, dual noise-cancelling microphone. Ideal for streaming and video calls.', 'imageUrl': 'https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=400'},
    {'name': 'USB-C 7-in-1 Hub', 'price': 34.99, 'category': 'Electronics', 'stock': 60, 'isActive': true, 'description': 'All-in-one USB-C hub with 4K HDMI, 3x USB 3.0, SD/microSD card reader, and 100W PD fast charging.', 'imageUrl': 'https://images.unsplash.com/photo-1625895197185-efcec01cffe0?w=400'},
    {'name': 'True Wireless Earbuds', 'price': 59.99, 'category': 'Electronics', 'stock': 45, 'isActive': true, 'description': 'Premium TWS earbuds with active noise cancellation, 8-hour playtime (32 hours with case), and IPX5 sweat resistance.', 'imageUrl': 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400'},
    // Clothing
    {'name': 'Premium Cotton T-Shirt', 'price': 19.99, 'category': 'Clothing', 'stock': 150, 'isActive': true, 'description': '100% organic cotton t-shirt with a relaxed fit. Pre-shrunk, breathable, and available in multiple colors.', 'imageUrl': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'},
    {'name': 'Running Shoes', 'price': 75.00, 'category': 'Clothing', 'stock': 45, 'isActive': true, 'description': 'Lightweight responsive running shoes with energy-return foam, breathable mesh upper, and anti-slip outsole.', 'imageUrl': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400'},
    {'name': 'Slim Fit Chino Pants', 'price': 44.99, 'category': 'Clothing', 'stock': 80, 'isActive': true, 'description': 'Versatile slim-fit chino pants made from stretch cotton blend. Perfect for casual and semi-formal occasions.', 'imageUrl': 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400'},
    {'name': 'Hooded Sweatshirt', 'price': 39.99, 'category': 'Clothing', 'stock': 70, 'isActive': true, 'description': 'Cozy heavyweight hoodie with kangaroo pocket, adjustable drawstring, and brushed fleece interior.', 'imageUrl': 'https://images.unsplash.com/photo-1556821840-3a63f15732ce?w=400'},
    {'name': 'Denim Jacket', 'price': 64.99, 'category': 'Clothing', 'stock': 35, 'isActive': true, 'description': 'Classic denim jacket with button front, chest pockets, and slightly distressed finish. A wardrobe essential.', 'imageUrl': 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?w=400'},
    {'name': 'Sports Cap', 'price': 14.99, 'category': 'Clothing', 'stock': 120, 'isActive': true, 'description': 'Breathable 6-panel sports cap with moisture-wicking sweatband and adjustable snapback closure.', 'imageUrl': 'https://images.unsplash.com/photo-1588850561407-ed78c282e89b?w=400'},
    {'name': 'Woolen Scarf', 'price': 22.99, 'category': 'Clothing', 'stock': 90, 'isActive': true, 'description': 'Soft merino wool blend scarf with classic plaid pattern. Warm, lightweight, and stylish.', 'imageUrl': 'https://images.unsplash.com/photo-1520903074185-8128153733ca?w=400'},
    // Home
    {'name': 'Ceramic Coffee Mug Set', 'price': 24.99, 'category': 'Home', 'stock': 100, 'isActive': true, 'description': 'Set of 4 handcrafted ceramic coffee mugs, 350ml capacity each. Dishwasher and microwave safe.', 'imageUrl': 'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=400'},
    {'name': 'LED Desk Lamp', 'price': 34.99, 'category': 'Home', 'stock': 55, 'isActive': true, 'description': 'Eye-care LED desk lamp with 5 color modes, 10 brightness levels, USB charging port, and touch control.', 'imageUrl': 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400'},
    {'name': 'Scented Soy Candle', 'price': 18.99, 'category': 'Home', 'stock': 200, 'isActive': true, 'description': 'Hand-poured soy wax candle with lavender and vanilla fragrance. 50-hour burn time in a reusable glass jar.', 'imageUrl': 'https://images.unsplash.com/photo-1602028915047-37269d1a73f7?w=400'},
    {'name': 'Minimalist Wall Clock', 'price': 29.99, 'category': 'Home', 'stock': 40, 'isActive': true, 'description': 'Silent non-ticking wall clock with a clean minimalist design. 30cm diameter, easy to read numerals.', 'imageUrl': 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=400'},
    {'name': 'Bamboo Cutting Board', 'price': 22.99, 'category': 'Home', 'stock': 75, 'isActive': true, 'description': 'Extra-large organic bamboo cutting board with juice groove, handle, and anti-slip feet.', 'imageUrl': 'https://images.unsplash.com/photo-1625937286074-9ca519d5d9df?w=400'},
    {'name': 'Indoor Plant Pot Set', 'price': 19.99, 'category': 'Home', 'stock': 60, 'isActive': true, 'description': 'Set of 3 modern ceramic plant pots with drainage holes and bamboo trays. Sizes: small, medium, large.', 'imageUrl': 'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=400'},
    {'name': 'Throw Pillow Cover Set', 'price': 16.99, 'category': 'Home', 'stock': 110, 'isActive': true, 'description': 'Set of 4 premium linen throw pillow covers in neutral tones. 18x18 inch, zipper closure.', 'imageUrl': 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400'},
    // Accessories
    {'name': 'Polarized Sunglasses', 'price': 35.00, 'category': 'Accessories', 'stock': 70, 'isActive': true, 'description': 'UV400 polarized sunglasses with lightweight TR90 frame and scratch-resistant lenses. Includes hard case.', 'imageUrl': 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400'},
    {'name': 'Slim Leather Wallet', 'price': 39.99, 'category': 'Accessories', 'stock': 55, 'isActive': true, 'description': 'Genuine full-grain leather bifold wallet with RFID blocking, 8 card slots, and bill compartment.', 'imageUrl': 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400'},
    {'name': 'Travel Backpack 30L', 'price': 59.99, 'category': 'Accessories', 'stock': 40, 'isActive': true, 'description': 'Durable 30L travel backpack with laptop compartment up to 15.6 inch, hidden pocket, USB charging port, and rain cover.', 'imageUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400'},
    {'name': 'Stainless Steel Water Bottle', 'price': 27.99, 'category': 'Accessories', 'stock': 90, 'isActive': true, 'description': 'Double-wall vacuum insulated 750ml bottle. Keeps drinks cold 24hrs and hot 12hrs. BPA-free, leak-proof lid.', 'imageUrl': 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=400'},
    {'name': 'Genuine Leather Belt', 'price': 24.99, 'category': 'Accessories', 'stock': 85, 'isActive': true, 'description': 'Classic genuine leather dress belt with brushed silver buckle. Available in black and brown, sizes 28-44.', 'imageUrl': 'https://images.unsplash.com/photo-1553531087-b1f7db7f5e8b?w=400'},
    {'name': 'Canvas Tote Bag', 'price': 15.99, 'category': 'Accessories', 'stock': 130, 'isActive': true, 'description': 'Heavy-duty cotton canvas tote bag with reinforced handles, interior zip pocket, and 20L capacity.', 'imageUrl': 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=400'},
    {'name': 'Analog Wrist Watch', 'price': 89.99, 'category': 'Accessories', 'stock': 22, 'isActive': true, 'description': 'Classic minimalist analog watch with sapphire crystal glass, stainless steel case, and genuine leather strap.', 'imageUrl': 'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=400'},
    {'name': 'Phone Crossbody Bag', 'price': 29.99, 'category': 'Accessories', 'stock': 65, 'isActive': true, 'description': 'Compact vegan leather crossbody bag with adjustable strap, card slots, and fits phones up to 6.7 inches.', 'imageUrl': 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400'},
  ];

  for (final product in products) {
    await db.collection('products').add(product);
    debugPrint('✓ Added: ${product['name']}');
  }
}