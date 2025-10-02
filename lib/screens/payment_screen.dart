import 'package:flutter/material.dart';
import 'package:rasoi_app/screens/my_orders_screen.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Simulating Payment...'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MyOrdersScreen()));
              },
              child: const Text('Complete Payment (Simulated)'),
            ),
          ],
        ),
      ),
    );
  }
}
