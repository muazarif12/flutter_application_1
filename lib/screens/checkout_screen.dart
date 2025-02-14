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

  // Dummy payment methods
  final List<String> _paymentMethods = ['Easypaisa', 'PayPro', 'Cash'];

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Method Selection
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._paymentMethods.map((method) {
                return RadioListTile<String>(
                  title: Text(method),
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 20),

              // Card Details (only shown if PayPro is selected)
              if (_selectedPaymentMethod == 'PayPro') ...[
                const Text(
                  'Enter Card Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number, // Correct placement
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _expiryDateController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date (MM/YY)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.datetime, // Correct placement
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter expiry date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.number, // Correct placement
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CVV';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Transaction Summary
              const Text(
                'Transaction Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Arena: ${widget.bookingDetails['arenaName']}'),
              Text('Sport: ${widget.bookingDetails['sport']}'),
              Text('Date: ${widget.bookingDetails['date']}'),
              Text('Slot: ${widget.bookingDetails['slot']}'),
              Text('Team Size: ${widget.bookingDetails['teamSize']}'),
              Text('Court Type: ${widget.bookingDetails['isHalfCourt'] ? 'Half Court' : 'Full Court'}'),
              const SizedBox(height: 20),

              // Checkout and Pay Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _processPayment(context);
                    }
                  },
                  child: const Text('Checkout and Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to process payment
  void _processPayment(BuildContext context) {
    // Simulate payment processing
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