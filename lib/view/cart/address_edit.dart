import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/address_inf_storage.dart';
import 'package:flutter_application_1/widgets/widget_auth.dart';

class EditAddressScreen extends StatefulWidget {
  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetController = TextEditingController();
  @override
  void initState() {
    super.initState();
    setState(() {
      _loadAddress();
    });
  }

  Future<void> _loadAddress() async {
    final data = await AddressStorage.load();
    setState(() {
      _nameController.text = data['name']!;
      _phoneController.text = data['phone']!;
      _emailController.text = data['email']!;
      _cityController.text = data['city']!;
      _districtController.text = data['district']!;
      _streetController.text = data['street']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          "Cập nhật địa chỉ",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: gradientBackground),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Họ và tên"),
                validator: (value) => value!.isEmpty ? "Nhập họ tên" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Số điện thoại"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Nhập số điện thoại" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: "Tỉnh/Thành phố"),
              ),
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: "Phường/Xã"),
              ),
              TextFormField(
                controller: _streetController,
                decoration:
                    const InputDecoration(labelText: "Số nhà, tên đường"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await AddressStorage.save(
                        name: _nameController.text,
                        phone: _phoneController.text,
                        email: _emailController.text,
                        city: _cityController.text,
                        district: _districtController.text,
                        street: _streetController.text,
                      );

                      final fullAddress =
                          "${_nameController.text} - ${_phoneController.text}\n"
                          "${_streetController.text}, "
                          "${_districtController.text}, "
                          "${_cityController.text}\n"
                          "${_emailController.text}";

                      Navigator.pop(context,true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero, // bỏ padding để gradient tràn hết
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: gradientBackground, // 👈 gradient ở đây
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Text(
                        "Cập nhật",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
