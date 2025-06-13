class Pedido {
  final int numero;
  final String cliente;
  final String endereco;
  String status;
  final String telefone;

  Pedido({
    required this.numero,
    required this.cliente,
    required this.endereco,
    required this.status,
    required this.telefone,
  });
}
