import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido.dart';

class ReportarProblemaPage extends StatefulWidget {
  final Pedido pedido;

  const ReportarProblemaPage({Key? key, required this.pedido}) : super(key: key);

  @override
  State<ReportarProblemaPage> createState() => _ReportarProblemaPageState();
}

class _ReportarProblemaPageState extends State<ReportarProblemaPage> {
  final _descricaoOutroController = TextEditingController();
  final supabase = Supabase.instance.client;

  String? _problemaSelecionado;
  bool get _mostrarOutroCampo => _problemaSelecionado == 'Outro';

  final List<String> _problemasComuns = [
    'Cliente não atende',
    'Endereço incorreto',
    'Cliente recusou o pedido',
    'Problema no trânsito',
    'Outro',
  ];

  @override
  void dispose() {
    _descricaoOutroController.dispose();
    super.dispose();
  }

  Future<void> _enviarProblema() async {
    if (_problemaSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um problema.')),
      );
      return;
    }

    final outrosDetalhes = _descricaoOutroController.text.trim();

    if (_mostrarOutroCampo && outrosDetalhes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descreva o problema em "Outro".')),
      );
      return;
    }

    final descricao = _problemaSelecionado! +
        (_mostrarOutroCampo ? '\nDescrição adicional: $outrosDetalhes' : '');

    try {
      final motoristaId = supabase.auth.currentUser?.id;
      if (motoristaId == null) throw 'Usuário não autenticado';

      // Inserir na tabela reports
      await supabase.from('reports').insert({
        'pedido_id': widget.pedido.numero, // int ou uuid (verifique conforme o tipo)
        'motorista_id': motoristaId,
        'problema': descricao,
      });

      // Atualizar status do pedido
      await supabase
          .from('pedidos')
          .update({'status': 'Adiado'})
          .eq('id', widget.pedido.numero);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Problema reportado com sucesso!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar problema: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 42),
                const Text(
                  'Reportar um problema',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${widget.pedido.numero}, ${widget.pedido.cliente}',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Qual é o problema encontrado?',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ..._problemasComuns.map((problema) {
                      return RadioListTile<String>(
                        title: Text(problema),
                        value: problema,
                        groupValue: _problemaSelecionado,
                        activeColor: const Color(0xFF037AEF),
                        onChanged: (String? value) {
                          setState(() {
                            _problemaSelecionado = value;
                            if (!_mostrarOutroCampo) _descricaoOutroController.clear();
                          });
                        },
                      );
                    }),
                    if (_mostrarOutroCampo)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          TextField(
                            controller: _descricaoOutroController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Descreva o problema',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _enviarProblema,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF037AEF),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 140),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        child: const Text(
                          'Enviar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
