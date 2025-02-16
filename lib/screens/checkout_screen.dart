import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;
  final Function(Map<String, dynamic>) onBookingConfirmed;

  const CheckoutScreen({
    super.key,
    required this.bookingDetails,
    required this.onBookingConfirmed,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPaymentMethod;
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Dummy payment methods with placeholder icons
  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'Easypaisa', 'icon': Icons.account_balance_wallet},
    {'name': 'PayPro', 'icon': Icons.credit_card},
    {'name': 'Cash', 'icon': Icons.money},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // **Payment Method Selection**
              _card(
                title: 'Select Payment Method',
                child: Column(
                  children: _paymentMethods.map((method) {
                    return RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(method['icon'], size: 28, color: Colors.green), // Placeholder icons
                          const SizedBox(width: 10),
                          Text(method['name'], style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      value: method['name'],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              // **Card Details (Shown only if PayPro is selected)**
              if (_selectedPaymentMethod == 'PayPro')
                _card(
                  title: 'Enter Card Details',
                  child: Column(
                    children: [
                      _textField(_cardNumberController, 'Card Number', Icons.credit_card, TextInputType.number),
                      const SizedBox(height: 12),
                      _textField(_expiryDateController, 'Expiry Date (MM/YY)', Icons.date_range, TextInputType.datetime),
                      const SizedBox(height: 12),
                      _textField(_cvvController, 'CVV', Icons.lock, TextInputType.number, obscureText: true),
                    ],
                  ),
                ),

              // **Transaction Summary**
              _card(
                title: 'Transaction Summary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryItem('Arena', widget.bookingDetails['arenaName']),
                    _summaryItem('Sport', widget.bookingDetails['sport']),
                    _summaryItem('Date', widget.bookingDetails['date']),
                    _summaryItem('Slot', widget.bookingDetails['slot']),
                    _summaryItem('Team Size', widget.bookingDetails['teamSize'].toString()),
                    _summaryItem('Court Type', widget.bookingDetails['isHalfCourt'] ? 'Half Court' : 'Full Court'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // **Checkout and Pay Button**
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.payment),
                  label: const Text(
                    'Checkout & Pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _processPayment(context);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // **Reusable Card Wrapper**
  Widget _card({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  // **Reusable Text Field**
  Widget _textField(
      TextEditingController controller,
      String label,
      IconData icon,
      TextInputType keyboardType, {
        bool obscureText = false,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  // **Transaction Summary Item**
  Widget _summaryItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  // **Function to Process Payment**
  void _processPayment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful!'),
      ),
    );

    // Call the callback to confirm the booking
    widget.onBookingConfirmed(widget.bookingDetails);

    // Navigate back to the previous screen
    Navigator.pop(context);
  }
}
