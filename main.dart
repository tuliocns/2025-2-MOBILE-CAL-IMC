import 'package:flutter/material.dart';

void main() {
  runApp(const ImcApp());
}

class ImcApp extends StatelessWidget {
  const ImcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de IMC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const ImcPage(),
    );
  }
}

class ImcPage extends StatefulWidget {
  const ImcPage({super.key});

  @override
  State<ImcPage> createState() => _ImcPageState();
}

class _ImcPageState extends State<ImcPage> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();

  double? _imc;
  String? _faixa;
  String? _mensagem;
  Color? _corResultado;

  @override
  void dispose() {
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _calcular() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final peso = double.parse(_pesoController.text.replaceAll(',', '.'));
    final alturaCm = double.parse(_alturaController.text.replaceAll(',', '.'));
    // Converter cm -> m
    final altura = alturaCm / 100.0;

    final imc = peso / (altura * altura);
    final (faixa, cor) = _classificar(imc);
    final msg = _recomendacao(faixa);

    setState(() {
      _imc = imc;
      _faixa = faixa;
      _mensagem = msg;
      _corResultado = cor;
    });
  }

  (String, Color) _classificar(double imc) {
    // Classificação baseada na OMS
    if (imc < 18.5) {
      return ('Abaixo do peso', Colors.blue);
    } else if (imc < 25) {
      return ('Peso normal', Colors.green);
    } else if (imc < 30) {
      return ('Sobrepeso', Colors.orange);
    } else if (imc < 35) {
      return ('Obesidade I', Colors.deepOrange);
    } else if (imc < 40) {
      return ('Obesidade II', Colors.red);
    } else {
      return ('Obesidade III', Colors.purple);
    }
  }

  String _recomendacao(String faixa) {
    switch (faixa) {
      case 'Abaixo do peso':
        return 'Considere acompanhamento nutricional para atingir um peso saudável.';
      case 'Peso normal':
        return 'Ótimo! Mantenha hábitos saudáveis de alimentação e atividade física.';
      case 'Sobrepeso':
        return 'Ajustes na dieta e atividade física podem ajudar a retornar ao peso ideal.';
      case 'Obesidade I':
      case 'Obesidade II':
      case 'Obesidade III':
        return 'Procure orientação profissional para um plano personalizado.';
      default:
        return '';
    }
  }

  void _limpar() {
    _formKey.currentState?.reset();
    _pesoController.clear();
    _alturaController.clear();
    setState(() {
      _imc = null;
      _faixa = null;
      _mensagem = null;
      _corResultado = null;
    });
  }

  String? _validarNumero(String? value,
      {required String campo, double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe $campo';
    }
    final v = double.tryParse(value.replaceAll(',', '.'));
    if (v == null) return 'Use apenas números (ex: 75.5)';
    if (min != null && v < min) return '$campo mínimo: $min';
    if (max != null && v > max) return '$campo máximo: $max';
    return null;
    // Altura em cm entre 50 e 250; peso entre 10 e 400
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de IMC'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                color: cs.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pesoController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          hintText: 'Ex: 72.3',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                        validator: (v) => _validarNumero(
                          v,
                          campo: 'o peso',
                          min: 10,
                          max: 400,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _alturaController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Altura (cm)',
                          hintText: 'Ex: 175',
                          prefixIcon: Icon(Icons.height),
                        ),
                        validator: (v) => _validarNumero(
                          v,
                          campo: 'a altura',
                          min: 50,
                          max: 250,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _calcular,
                              icon: const Icon(Icons.calculate),
                              label: const Text('Calcular'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _limpar,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_imc != null) ...[
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Seu IMC',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _imc!.toStringAsFixed(1),
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(color: _corResultado),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(_faixa!),
                          backgroundColor: _corResultado?.withOpacity(0.12),
                          side: BorderSide(color: _corResultado ?? cs.primary),
                          labelStyle: TextStyle(
                            color: _corResultado ?? cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _mensagem!,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LegendaImc(),
              ] else
                const _LegendaImc(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendaImc extends StatelessWidget {
  const _LegendaImc();

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Abaixo de 18.5', 'Abaixo do peso', Colors.blue),
      ('18.5 – 24.9', 'Peso normal', Colors.green),
      ('25.0 – 29.9', 'Sobrepeso', Colors.orange),
      ('30.0 – 34.9', 'Obesidade I', Colors.deepOrange),
      ('35.0 – 39.9', 'Obesidade II', Colors.red),
      ('40.0+', 'Obesidade III', Colors.purple),
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faixas de IMC (OMS)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...items.map(
              (e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(backgroundColor: e.$3, radius: 8),
                title: Text(e.$2),
                subtitle: Text(e.$1),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
