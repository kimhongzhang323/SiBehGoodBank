===============================================
PAYMENT & VENDOR LOGO ASSET FILES
===============================================

Please add the following image files to this directory (assets/images/):

PAYMENT METHODS:
1. alipay.png       - Alipay logo (recommended size: 120x120px, PNG format)
2. touchngo.png     - Touch 'n Go eWallet logo (120x120px, PNG)
3. boost.png        - Boost logo (120x120px, PNG)
4. wechatpay.png    - WeChat Pay logo (120x120px, PNG)
5. paypal.png       - PayPal logo (120x120px, PNG)

RIDE & DELIVERY SERVICES:
6. grab.png         - Grab logo (120x120px, PNG)
7. uber.svg         - Uber logo (SVG format for scalability)

BOOKING SERVICES:
8. booking.jpg      - Booking.com logo (120x120px, JPG/PNG)
9. agoda.png        - Agoda logo (120x120px, PNG)

===============================================
USAGE IN APP:
===============================================

These logos will be used throughout the app in:
- Top-up payment method selection
- Linked accounts screen
- Mini-programs (ride-hailing, hotel booking, etc.)
- Wallet detail screen payment sources

===============================================
HOW TO ADD:
===============================================

1. Download each logo from official brand resources
2. Resize to recommended dimensions (120x120px or similar)
3. Save with the exact filenames listed above
4. Place all files in this directory: assets/images/
5. Run: flutter clean && flutter pub get
6. Run the app to see the logos in action!

===============================================
NOTE:
===============================================

- uber.svg uses SVG format and will be rendered using flutter_svg package
- All other images use standard Image.asset() widget
- Ensure logos are transparent backgrounds (PNG) for best results
- Use official brand colors and guidelines when sourcing logos

===============================================
