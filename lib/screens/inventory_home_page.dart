import 'package:flutter/material.dart';
import '../model/item.dart';
import '../services/firestore_service.dart';
import 'add_edit_item_screen.dart';

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key, required this.title});
  final String title;

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final FirestoreService _service = FirestoreService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Food', 'Electronics', 'Clothing'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _openDashboard(context),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _service.getItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var items = snapshot.data!
              .where((item) => item.name.toLowerCase().contains(_searchQuery))
              .toList();

          if (_selectedCategory != 'All') {
            items = items.where((i) => i.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
          }

          if (items.isEmpty) {
            return const Center(child: Text('No items found.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: Key(item.id ?? index.toString()),
                background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
                secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) async {
                  if (item.id != null) await _service.deleteItem(item.id!);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
                },
                child: ListTile(
                  title: Text(item.name),
                  subtitle: Text('Qty: ${item.quantity} • \$${item.price.toStringAsFixed(2)} • ${item.category}'),
                  trailing: Text('\$${(item.quantity * item.price).toStringAsFixed(2)}'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddEditItemScreen(item: item)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditItemScreen()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildCategoryFilter(),
    );
  }

  void _openDashboard(BuildContext context) async {
    final docs = await _service.getItemsOnce();

    final totalItems = docs.length;
    final totalValue = docs.fold<double>(0.0, (p, e) => p + e.price * e.quantity);
  final outOfStock = docs.where((d) => d.quantity <= 0).toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Inventory Dashboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total unique items: $totalItems'),
            Text('Total inventory value: \$${totalValue.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Out of stock items:'),
            if (outOfStock.isEmpty) const Text('- None'),
            for (var o in outOfStock) Text('- ${o.name}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: _categories.map((cat) {
          final bool selected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }
}