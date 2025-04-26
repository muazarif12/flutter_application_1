import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';

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
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
              fontFamily: 'Exo2',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // **Payment Method Selection**
              _card(
                isDarkMode: isDarkMode,
                title: 'Select Payment Method',
                child: Column(
                  children: _paymentMethods.map((method) {
                    return RadioListTile<String>(
                      activeColor: Colors.green,
                      title: Row(
                        children: [
                          Icon(method['icon'],
                              size: 28,
                              color: Colors.green), // Placeholder icons
                          const SizedBox(width: 10),
                          Text(method['name'],
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
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
                  isDarkMode: isDarkMode,
                  title: 'Enter Card Details',
                  child: Column(
                    children: [
                      _textField(_cardNumberController, 'Card Number',
                          Icons.credit_card, TextInputType.number),
                      const SizedBox(height: 12),
                      _textField(_expiryDateController, 'Expiry Date (MM/YY)',
                          Icons.date_range, TextInputType.datetime),
                      const SizedBox(height: 12),
                      _textField(_cvvController, 'CVV', Icons.lock,
                          TextInputType.number,
                          obscureText: true),
                    ],
                  ),
                ),

              // **Transaction Summary**
              _card(
                isDarkMode: isDarkMode,
                title: 'Transaction Summary',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryItem('Arena', widget.bookingDetails['arenaName'],
                        isDarkMode),
                    _summaryItem(
                        'Sport', widget.bookingDetails['sport'], isDarkMode),
                    _summaryItem(
                        'Date', widget.bookingDetails['date'], isDarkMode),
                    _summaryItem(
                        'Slot', widget.bookingDetails['slot'], isDarkMode),
                    _summaryItem(
                        'Team Size',
                        widget.bookingDetails['teamSize'].toString(),
                        isDarkMode),
                    _summaryItem(
                        'Court Type',
                        widget.bookingDetails['isHalfCourt']
                            ? 'Half Court'
                            : 'Full Court',
                        isDarkMode),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
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
  Widget _card(
      {required String title,
      required Widget child,
      required bool isDarkMode}) {
    return Card(
      elevation: 3,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black)),
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
        prefixIcon: Icon(
          icon,
          color: Colors.green,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  // **Transaction Summary Item**
  Widget _summaryItem(String title, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black)),
          Text(
            value,
            style: const TextStyle(color: Colors.green),
          ),
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
