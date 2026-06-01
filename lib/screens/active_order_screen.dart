import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/order_model.dart';
import '../providers/order_provider.dart';

class ActiveOrderScreen extends StatefulWidget {
  final Order order;
  const ActiveOrderScreen({super.key, required this.order});

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await Provider.of<OrderProvider>(context, listen: false)
          .updateOrderStatus(widget.order.id, newStatus);
      if (newStatus == 'delivered') {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    // Find current state of the order in the provider
    final currentOrder = orderProvider.activeOrders.firstWhere(
      (o) => o.id == widget.order.id,
      orElse: () => widget.order,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aktywna dostawa'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusTimeline(status: currentOrder.status),
                const SizedBox(height: 24),
                _InfoCard(
                  title: 'Odbiór z:',
                  name: currentOrder.restaurant?.name ?? '',
                  address: currentOrder.restaurant?.address ?? '',
                  icon: LucideIcons.store,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Dostawa do:',
                  name: currentOrder.customerName,
                  address: currentOrder.customerAddress,
                  icon: LucideIcons.mapPin,
                  color: Colors.orange,
                ),
                if (currentOrder.orderDetails != null) ...[
                  const SizedBox(height: 16),
                  _DetailsCard(details: currentOrder.orderDetails!),
                ],
                const SizedBox(height: 32),
                _ActionButtons(
                  status: currentOrder.status,
                  isUpdating: _isUpdating,
                  onUpdate: _updateStatus,
                ),
              ],
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Status dostawy', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _Step(label: 'Zamówienie przyjęte', isActive: true, isDone: true),
          _Connector(isDone: status != 'accepted'),
          _Step(
            label: 'Odebrane z restauracji',
            isActive: status == 'picked_up',
            isDone: status == 'picked_up' || status == 'delivered',
          ),
          _Connector(isDone: status == 'delivered'),
          _Step(label: 'Dostarczone klientowi', isActive: status == 'delivered', isDone: status == 'delivered'),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDone;

  const _Step({required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isDone ? LucideIcons.checkCircle : LucideIcons.circle,
          color: isDone ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive || isDone ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isDone;
  const _Connector({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 9),
      height: 20,
      width: 2,
      color: isDone ? Colors.green : Colors.grey[300],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String name;
  final String address;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.name,
    required this.address,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(address, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String details;
  const _DetailsCard({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.package, size: 16),
              SizedBox(width: 8),
              Text('Szczegóły', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(details, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String status;
  final bool isUpdating;
  final Function(String) onUpdate;

  const _ActionButtons({
    required this.status,
    required this.isUpdating,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: isUpdating ? null : () => onUpdate('picked_up'),
          icon: const Icon(LucideIcons.store),
          label: const Text('Odebrałem zamówienie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    if (status == 'picked_up' || status == 'in_transit') {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: isUpdating ? null : () => onUpdate('delivered'),
          icon: const Icon(LucideIcons.checkCircle),
          label: const Text('Dostarczyłem zamówienie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
