import 'package:flutter/material.dart';
import '../model/item.dart';
import '../services/firestore_service.dart';

class AddEditItemScreen extends StatefulWidget {
  final Item? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _service = FirestoreService();

  late TextEditingController _nameC;
  late TextEditingController _qtyC;
  late TextEditingController _priceC;
  late TextEditingController _categoryC;

  bool get isEditMode => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.item?.name ?? '');
    _qtyC = TextEditingController(text: widget.item?.quantity.toString() ?? '0');
    _priceC = TextEditingController(text: widget.item?.price.toStringAsFixed(2) ?? '0.00');
    _categoryC = TextEditingController(text: widget.item?.category ?? 'General');
  }

  @override
  void dispose() {
    _nameC.dispose();
    _qtyC.dispose();
    _priceC.dispose();
    _categoryC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? 'Edit Item' : 'Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qtyC,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) => (int.tryParse(v ?? '') == null) ? 'Enter valid integer' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceC,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Enter valid price' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryC,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditMode ? 'Save Changes' : 'Add Item'),
              ),
              if (isEditMode) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _delete,
                  child: const Text('Delete Item'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      id: widget.item?.id,
      name: _nameC.text.trim(),
      quantity: int.parse(_qtyC.text.trim()),
      price: double.parse(_priceC.text.trim()),
      category: _categoryC.text.trim(),
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    if (isEditMode) {
      await _service.updateItem(item);
    } else {
      await _service.addItem(item);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.item?.id == null) return;
    await _service.deleteItem(widget.item!.id!);
    if (mounted) Navigator.pop(context);
  }
}