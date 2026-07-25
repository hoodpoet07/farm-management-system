import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';

class AddPurchaseScreen extends StatefulWidget{
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState()=> _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _supplierController=TextEditingController();
  final TextEditingController _quantityController=TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  double _totalPrice =0;
  
  @override
  void initState(){
    super.initState();

    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);
  }

  void _calculateTotal(){
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;

    setState((){
      _totalPrice = quantity * unitPrice;
    });
  }

  @override
  void dispose(){
    _itemController.dispose();
    _supplierController.dispose;
    _quantityController.dispose;
    _unitPriceController.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Purchase"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _itemController,
                label: "Item Name",
                icon: Icons.shopping_bag,
                validator: (value){
                  if (value==null || value.trim().isEmpty){
                    return "Please enter the item name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: _supplierController,
                label: "Supplier",
                icon: Icons.business,
                validator: (value){
                  if (value == null || value.trim().isEmpty){
                    return "Please enter the supplier";
                  }
                },
              ),
            ]
          ),
        ),
      ),
    );
  }
}