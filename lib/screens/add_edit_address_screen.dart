import 'package:flutter/material.dart';
import 'package:rasoi_app/models/address.dart';
import 'package:rasoi_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart'; // Import uuid package

class AddEditAddressScreen extends StatefulWidget {
  final Address? address; // Nullable for adding new address

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternatePhoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  String _selectedAddressType = 'Home';
  bool _isDefault = false;

  final FirestoreService _firestoreService = FirestoreService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      // Pre-fill fields if editing an existing address
      _fullNameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phone;
      _alternatePhoneController.text = widget.address!.alternatePhone ?? '';
      _streetController.text = widget.address!.street;
      _cityController.text = widget.address!.city;
      _pinCodeController.text = widget.address!.pinCode;
      _villageController.text = widget.address!.village ?? '';
      _selectedAddressType = widget.address!.type;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate() && _currentUser?.uid != null) {
      final String uid = _currentUser!.uid;
      final String addressId = widget.address?.id ?? const Uuid().v4(); // Generate new ID if adding

      final newAddress = Address(
        id: addressId,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        alternatePhone: _alternatePhoneController.text.trim().isEmpty
            ? null
            : _alternatePhoneController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        village: _villageController.text.trim().isEmpty
            ? null
            : _villageController.text.trim(),
        lat: widget.address?.lat ?? 0.0, // Set default or existing lat
        lng: widget.address?.lng ?? 0.0, // Set default or existing lng
        type: _selectedAddressType,
        isDefault: _isDefault,
      );

      if (widget.address == null) {
        // Add new address
        await _firestoreService.addAddress(uid, newAddress);
      } else {
        // Update existing address
        await _firestoreService.updateAddress(uid, newAddress);
      }

      if (!mounted) return; // Use !mounted check on the State
      Navigator.pop(context); // Go back to profile screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Add New Address' : 'Edit Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _alternatePhoneController,
                decoration: const InputDecoration(labelText: 'Alternate Phone Number (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Street / House No. / Building Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your street address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _pinCodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pincode';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(labelText: 'Village / Locality (Optional)'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _selectedAddressType,
                decoration: const InputDecoration(labelText: 'Address Type'),
                items: <String>['Home', 'Work', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAddressType = newValue!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Set as Default Address'),
                value: _isDefault,
                onChanged: (bool? newValue) {
                  setState(() {
                    _isDefault = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text(widget.address == null ? 'Add Address' : 'Update Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
