import 'package:flutter/material.dart';
import '../models/pedido.dart';

class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;

  const PedidoCard({
    Key? key,
    required this.pedido,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          "Pedido #${pedido.numero}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pedido.cliente, style: const TextStyle(fontSize: 16)),
            Text(
              pedido.endereco,
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        trailing: Text(
          pedido.status,
          style: TextStyle(
            fontSize: 14,
            color: pedido.status == 'Em andamento'
                ? Colors.green
                : pedido.status == 'Pendente'
                ? Colors.orange
                : pedido.status == 'Adiado'
                ? Colors.red
                : Colors.black
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
