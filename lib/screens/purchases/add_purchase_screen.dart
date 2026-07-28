import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/purchase.dart';
import '../../models/supplier.dart';
import '../../database/database_helper.dart';

class AddPurchaseScreen extends StatefulWidget{
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState()=> _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  List<Supplier> _suppliers = [];
  Supplier? _selectedSupplier;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _supplierController=TextEditingController();
  final TextEditingController _quantityController=TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  double _totalPrice =0;
  
  Future<void> _showAddSupplierDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text("Add Supplier"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Supplier Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                final supplier = Supplier(
                  name: controller.text.trim(),
                );

                await DatabaseHelper.instance.insertSupplier(supplier);
                  Navigator.pop(context);

                  await _loadSuppliers();

                  final suppliers = await DatabaseHelper.instance.getAllSuppliers();

                  final addedSupplier = suppliers.firstWhere(
                    (s)=>s.name==controller.text.trim(),
                  );

                  setState((){
                    _selectedSupplier = addedSupplier;
                  });
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _loadSuppliers() async {
    final suppliers = 
      await DatabaseHelper.instance.getAllSuppliers();

    setState((){
      _suppliers = suppliers;
    });
  }
  @override
  void initState(){
    super.initState();

    _quantityController.addListener(_calculateTotal);
    _unitPriceController.addListener(_calculateTotal);

    _loadSuppliers();
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

  void _savePurchase(){
    if(!_formKey.currentState!.validate()){
      return;
    }

    Purchase purchase = Purchase(
       itemName: _itemController.text.trim(),
       supplier: _selectedSupplier!.name,
       quantity: int.parse(_quantityController.text),
       unitPrice: double.parse(_unitPriceController.text),
       totalPrice: _totalPrice,
       date: DateTime.now().toString(),
    );

    Navigator.pop(context, purchase);
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

              DropdownButtonFormField<Supplier>(
                initialValue: _selectedSupplier,
                decoration: const InputDecoration(
                  labelText: "Supplier",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                items: [
                  ..._suppliers.map(
                    (supplier) => DropdownMenuItem<Supplier>(
                      value: supplier,
                      child: Text(supplier.name),
                    ),
                  ),

                  DropdownMenuItem<Supplier>(
                    value: _addSupplierOption,
                    child: Text("➕ Add New Supplier"),
                  ),
                ],
                onChanged: (supplier) async {
                  if (supplier == null) return;
                                      
                  if (supplier.id==-1){
                    await _showAddSupplierDialog();
                    return;
                  }
                    setState(() {
                      _selectedSupplier = supplier;
                    });
                  
                },
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: _quantityController,
                label: "Quantity",
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (value){
                  if (value==null||value.isEmpty){
                    return "Enter quantity";
                  }
                  if (int.tryParse(value)==null){
                    return "Quantity must be a whole number";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: _unitPriceController,
                label: "Unit Price",
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value){
                  if (value==null||value.isEmpty){
                    return "Enter unit price";
                  }
                  if (double.tryParse(value)==null){
                    return "Invalid price";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                    ),
                ),
                child: Column(
                  children: [
                    
                    const Icon(
                      Icons.calculate,
                      size: 40,
                      color: Colors.green,
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Total Purchase Cost",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "\$${_totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _savePurchase,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save Purchase",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }

  final Supplier _addSupplierOption = Supplier(
    id: -1,
    name: "➕ Add New Supplier",
  );
 
}