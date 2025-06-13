# 🛣️ Trajetto

Aplicativo de gerenciamento de entregas desenvolvido como projeto da A3 na faculdade.  
A proposta é permitir que motoristas visualizem, reportem e concluam entregas de forma prática, utilizando integração com **Supabase** e **Google Maps API**.

---

## 🧩 Tecnologias utilizadas

- **Flutter** com Dart
- **Supabase** (autenticação, banco de dados, hospedagem)
- **Google Maps API**
- **Geolocator** (para localização em tempo real)
- **Geocoding** (conversão de endereços em coordenadas)
- **URL Launcher** (ligações, navegação)
- **Android Intent Plus** (integração com navegação externa no Android)

---

## 🗂️ Estrutura de Pastas e Links Úteis

| Arquivo | Descrição |
|--------|----------|
| [`lib/pages/dashboard_page.dart`](https://github.com/brayan-duwe/trajetto-a3/blob/main/lib/pages/dashboard_page.dart) | Tela principal do motorista com listagem das entregas do dia |
| [`lib/pages/entregar_pedido_page.dart`](https://github.com/brayan-duwe/trajetto-a3/blob/main/lib/pages/entregar_pedido_page.dart) | Tela de entrega do pedido com mapa e botões de ação |
| [`lib/pages/pedidos_detalhes_pages.dart`](https://github.com/brayan-duwe/trajetto-a3/blob/main/lib/pages/pedidos_detalhes_pages.dart) | Detalhes do pedido com botão de iniciar entrega |
| [`lib/pages/reportar_page.dart`](https://github.com/brayan-duwe/trajetto-a3/blob/main/lib/pages/reportar_page.dart) | Tela de relatório de problema com envio para Supabase |
| [`lib/models/pedido.dart`](https://github.com/brayan-duwe/trajetto-a3/blob/main/lib/models/pedido.dart) | Modelo de dados de um pedido |
| [`lib/components/pedido_card.dart`](https://github.com/brayan-duwe/trajetto-a3/blob/main/lib/components/pedido_card.dart) | Componente reutilizável de exibição dos pedidos |

---

## 🧠 Lógica do App

- Motorista faz login com nome e senha (autenticação via Supabase)
- O dashboard carrega as **entregas do dia atual** com base no `motorista_id`
- O usuário pode:
  - **Iniciar entrega**, que muda o status para `Em andamento`
  - **Concluir entrega**, que muda o status para `Concluído`
  - **Reportar problema**, que insere na tabela `reports` e muda status para `Adiado`

---

## 🛠️ Banco de Dados Supabase

### Tabelas principais:

- `usuarios` → Motoristas cadastrados
- `pedidos` → Entregas com `motorista_id`, `data_entrega`, `status`
- `reports` → Relatórios com `pedido_id`, `motorista_id`, `problema`

Relacionamentos:
- `pedidos.motorista_id` → FK para `usuarios.id`
- `reports.motorista_id` → FK para `usuarios.id`
- `reports.pedido_id` → FK para `pedidos.id`

---

## 📍 Google Maps API

- Conversão de endereço para coordenadas: `geocoding`
- Exibição do mapa com marcadores: `google_maps_flutter`
- Localização atual do motorista: `geolocator`
- Navegação até o cliente via Google Maps externo: `android_intent_plus`

---

## 📦 Como rodar

```bash
flutter pub get
flutter run
