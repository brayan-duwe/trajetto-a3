import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pedido.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'reportar_page.dart';

class EntregarPedidoPage extends StatefulWidget {
  final Pedido pedido;

  const EntregarPedidoPage({Key? key, required this.pedido}) : super(key: key);

  @override
  State<EntregarPedidoPage> createState() => _IniciarEntregaPageState();
}

class _IniciarEntregaPageState extends State<EntregarPedidoPage> {
  LatLng? destinoLatLng;
  Position? minhaLocalizacao;
  late GoogleMapController mapController;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _carregarEnderecoEDestino();
  }

  Future<void> _carregarEnderecoEDestino() async {
    try {
      final List<Location> locations = await locationFromAddress(widget.pedido.endereco)
          .timeout(const Duration(seconds: 10));

      destinoLatLng = LatLng(locations[0].latitude, locations[0].longitude);
      minhaLocalizacao = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('Endereço resolvido: $destinoLatLng');
      setState(() {});
    } catch (e) {
      print('Erro ao localizar endereço: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar o mapa.')),
        );
      }
      Navigator.pop(context);
    }
  }

  Future<void> _atualizarStatus(String novoStatus) async {
    try {
      await supabase
          .from('pedidos')
          .update({'status': novoStatus})
          .eq('id', widget.pedido.numero);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(novoStatus == 'Concluído'
            ? 'Entrega finalizada com sucesso!'
            : 'Entrega cancelada e marcada como pendente.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (destinoLatLng == null || minhaLocalizacao == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: destinoLatLng!,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('destino'),
                  position: destinoLatLng!,
                  infoWindow: InfoWindow(title: widget.pedido.endereco),
                ),
                Marker(
                  markerId: const MarkerId('minhaLocalizacao'),
                  position: LatLng(
                    minhaLocalizacao!.latitude,
                    minhaLocalizacao!.longitude,
                  ),
                  infoWindow: const InfoWindow(title: 'Você'),
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Container(
                padding: const EdgeInsets.only(bottom: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(42),
                    bottomRight: Radius.circular(42),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 45),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                Text(
                                  'Pedido #${widget.pedido.numero}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.pedido.cliente,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  widget.pedido.endereco,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () => _atualizarStatus('Concluído'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 102),
                                    backgroundColor: const Color(0xFF037AEF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(42),
                                    ),
                                  ),
                                  child: const Text(
                                    "Entregar produto",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _atualizarStatus('Pendente'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(42),
                                        ),
                                      ),
                                      child: const Text(
                                        "Cancelar Entrega",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    IconButton(
                                      icon: const Icon(Icons.phone, color: Colors.black),
                                      tooltip: 'Ligar para o cliente',
                                      onPressed: () async {
                                        final numero = widget.pedido.telefone;
                                        final uri = Uri(scheme: 'tel', path: numero);

                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Chamadas não suportadas no emulador.')),
                                          );
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.warning_amber_rounded, color: Colors.black),
                                      tooltip: 'Reportar problema',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReportarProblemaPage(pedido: widget.pedido),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
