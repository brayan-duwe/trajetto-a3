import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/pedido.dart';
import '../components/pedido_card.dart';
import 'entregar_pedido_page.dart';
import 'pedidos_detalhes_pages.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final supabase = Supabase.instance.client;
  List<Pedido> pedidos = [];
  bool loading = true;
  String nomeUsuario = '';

  @override
  void initState() {
    super.initState();
    carregarPedidos();
  }

  Future<void> carregarPedidos() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw 'Usuário não autenticado';

      // Buscar nome do usuário
      final usuarioResponse = await supabase
          .from('usuarios')
          .select('nome')
          .eq('id', userId)
          .single();

      nomeUsuario = usuarioResponse['nome'] ?? '';

      final hoje = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final response = await supabase
          .from('pedidos')
          .select()
          .eq('motorista_id', userId)
          .eq('data_entrega', hoje);

      pedidos = (response as List).map((p) {
        return Pedido(
          numero: (p['id'] as int),
          cliente: p['cliente_nome'] ?? '',
          endereco: p['endereco'] ?? '',
          status: p['status'] ?? '',
          telefone: p['telefone'].toString(),
        );
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pedidos: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Row(
          children: [
            Image.asset('assets/logo_preta.png', height: 32),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Text(
              'Olá, ${nomeUsuario.isNotEmpty ? nomeUsuario : 'motorista'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Text(
              'Você tem ${pedidos.length} entregas hoje.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                return PedidoCard(
                  pedido: pedidos[index],
                  onTap: () async {
                    final destino = pedidos[index].status == 'Em andamento'
                        ? EntregarPedidoPage(pedido: pedidos[index])
                        : PedidoDetalhesPage(pedido: pedidos[index]);

                    final atualizou = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => destino),
                    );

                    if (atualizou == true) {
                      await carregarPedidos(); // Atualiza dados do Supabase
                    }
                  }
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}