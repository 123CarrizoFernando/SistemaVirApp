import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:async';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String baseUrl = 'https://api-sistema-vir.onrender.com/api';

void main() {
  runApp(const SistemaAcademicoApp());
}

class SistemaAcademicoApp extends StatelessWidget {
  const SistemaAcademicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Gestión Académica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F4E78)),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============================================================================
// ESTRUCTURA PRINCIPAL: SELECTOR GLOBAL DE AÑO, PERÍODO, MÓDULO Y ORIENTACIÓN
// ============================================================================
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceSeleccionado = 0;

  int _anioActual = 2026;
  String _periodoActual = '2° Período';
  int _moduloActual = 6;
  String _orientacionActual = 'Turismo';

  final List<int> _aniosDisponibles = [2025, 2026, 2027, 2028];
  final List<String> _periodosDisponibles = ['1° Período', '2° Período'];
  final List<int> _modulosDisponibles = [1, 2, 3, 4, 5, 6];
  final List<String> _orientacionesDisponibles = [
    'Turismo',
    'Economía y Administración',
  ];

  @override
  Widget build(BuildContext context) {
    bool esCelular = MediaQuery.of(context).size.width < 750;
    final Key filtroKey = ValueKey(
      '$_anioActual-$_periodoActual-$_moduloActual-$_orientacionActual',
    );

    final List<Widget> pantallas = [
      PantallaAlumnos(
        key: filtroKey,
        anio: _anioActual,
        periodo: _periodoActual,
        modulo: _moduloActual,
        orientacion: _orientacionActual,
      ),
      PantallaGrupos(
        key: filtroKey,
        anio: _anioActual,
        periodo: _periodoActual,
        modulo: _moduloActual,
        orientacion: _orientacionActual,
      ),
      PantallaSeguimiento(
        key: filtroKey,
        anio: _anioActual,
        periodo: _periodoActual,
        modulo: _moduloActual,
        orientacion: _orientacionActual,
      ),
      PantallaEnlaces(
        key: filtroKey,
        modulo: _moduloActual,
        orientacion: _orientacionActual,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F4E78),
        foregroundColor: Colors.white,
        title: const Text(
          'Gestión Académica',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          _chipDropdown<int>(
            value: _anioActual,
            items: _aniosDisponibles
                .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                .toList(),
            onChanged: (v) => setState(() => _anioActual = v!),
          ),
          _chipDropdown<String>(
            value: _periodoActual,
            items: _periodosDisponibles
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(esCelular ? p.substring(0, 3) : p),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _periodoActual = v!),
          ),
          _chipDropdown<int>(
            value: _moduloActual,
            items: _modulosDisponibles
                .map((m) => DropdownMenuItem(value: m, child: Text('Mód. $m')))
                .toList(),
            onChanged: (v) => setState(() => _moduloActual = v!),
          ),
          _chipDropdown<String>(
            value: _orientacionActual,
            items: _orientacionesDisponibles
                .map(
                  (o) => DropdownMenuItem(
                    value: o,
                    child: Text(
                      esCelular && o.startsWith('Economía') ? 'Economía' : o,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _orientacionActual = v!),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Row(
        children: [
          if (!esCelular)
            NavigationRail(
              selectedIndex: _indiceSeleccionado,
              onDestinationSelected: (int index) =>
                  setState(() => _indiceSeleccionado = index),
              extended: true,
              backgroundColor: const Color(0xFF153654),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Alumnos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.group_work_outlined),
                  selectedIcon: Icon(Icons.group_work),
                  label: Text('Grupos y Proyectos'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Seguimiento y Bot'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.link),
                  selectedIcon: Icon(Icons.link),
                  label: Text('Enlaces Moodle'),
                ),
              ],
            ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: pantallas[_indiceSeleccionado],
            ),
          ),
        ],
      ),
      bottomNavigationBar: esCelular
          ? BottomNavigationBar(
              currentIndex: _indiceSeleccionado,
              onTap: (int index) => setState(() => _indiceSeleccionado = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xFF1F4E78),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Alumnos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_work),
                  label: 'Grupos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy),
                  label: 'Bot / Seg.',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.link),
                  label: 'Enlaces',
                ),
              ],
            )
          : null,
    );
  }

  Widget _chipDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: const Color(0xFF1F4E78),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 18,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============================================================================
// PANTALLA 1: ALUMNOS, TARJETA ACADÉMICA, REPORTES PDF Y PASE DE PERÍODO
// ============================================================================
class PantallaAlumnos extends StatefulWidget {
  final int anio;
  final String periodo;
  final int modulo;
  final String orientacion;
  const PantallaAlumnos({
    super.key,
    required this.anio,
    required this.periodo,
    required this.modulo,
    required this.orientacion,
  });

  @override
  State<PantallaAlumnos> createState() => _PantallaAlumnosState();
}

class _PantallaAlumnosState extends State<PantallaAlumnos> {
  List<dynamic> alumnos = [];
  bool cargando = true;
  String _filtroCondicion = 'Todos';

  @override
  void initState() {
    super.initState();
    cargarAlumnos();
  }

  Future<void> cargarAlumnos() async {
    setState(() => cargando = true);
    try {
      final url = Uri.parse(
        '$baseUrl/alumnos_cursada?modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          alumnos = json.decode(response.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  // --- 1. TARJETA ACADÉMICA RÁPIDA (AL HACER CLICK EN EL ALUMNO) ---
  void _abrirTarjetaAcademica(dynamic alumno) {
    String condicion = alumno['condicion'] ?? 'Cursando';
    bool debeDefensa = alumno['debe_defensa'] ?? false;
    bool notificadoLibre = alumno['notificado_libre'] ?? false;
    bool presentoNota = alumno['presento_nota_recursar'] ?? false;
    bool egresado = alumno['egresado'] ?? false;

    String adeudadosStr = alumno['modulos_adeudados']?.toString() ?? '';
    List<String> modulosMarcados = adeudadosStr.isEmpty
        ? []
        : adeudadosStr
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    bool debeModulosAnteriores = modulosMarcados.isNotEmpty;

    List<dynamic> historialAlumno = [];
    bool cargandoHistorial = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (cargandoHistorial) {
              http
                  .get(
                    Uri.parse(
                      '$baseUrl/alumno/${alumno['alumno_id']}/historial',
                    ),
                  )
                  .then((res) {
                    if (res.statusCode == 200) {
                      setStateDialog(() {
                        historialAlumno = json.decode(res.body);
                        cargandoHistorial = false;
                      });
                    }
                  })
                  .catchError(
                    (_) => setStateDialog(() => cargandoHistorial = false),
                  );
            }

            bool puedeEgresar =
                (widget.modulo == 6 &&
                condicion == 'Promocionado' &&
                !debeDefensa &&
                modulosMarcados.isEmpty);

            return AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alumno['nombre_completo'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1F4E78),
                    ),
                  ),
                  Text(
                    'DNI: ${alumno['dni']} | ${widget.anio} - ${widget.periodo} (Mód. ${widget.modulo})',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Situación en este Período:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              'Cursando',
                              'Promocionado',
                              'Regular',
                              'Libre',
                            ].map((estado) {
                              bool seleccionado = condicion == estado;
                              return ChoiceChip(
                                label: Text(estado),
                                selected: seleccionado,
                                selectedColor: _colorCondicion(estado)
                                    .withOpacity(0.25),
                                labelStyle: TextStyle(
                                  fontWeight: seleccionado
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: seleccionado
                                      ? _colorCondicion(estado)
                                      : Colors.black87,
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setStateDialog(() {
                                      condicion = estado;
                                      if (widget.modulo == 6 &&
                                          condicion == 'Promocionado' &&
                                          !debeDefensa &&
                                          modulosMarcados.isEmpty) {
                                        egresado = true;
                                      } else if (condicion != 'Promocionado') {
                                        egresado = false;
                                      }
                                    });
                                  }
                                },
                              );
                            }).toList(),
                      ),

                      if (condicion == 'Libre') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seguimiento de Alumno Libre (Para Recursar):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  '¿Está notificado de su condición de Libre?',
                                  style: TextStyle(fontSize: 13),
                                ),
                                value: notificadoLibre,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (v) =>
                                    setStateDialog(() => notificadoLibre = v!),
                              ),
                              CheckboxListTile(
                                title: const Text(
                                  '¿Presentó nota para recursar el módulo?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                value: presentoNota,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (v) =>
                                    setStateDialog(() => presentoNota = v!),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (condicion == 'Regular' || debeDefensa) ...[
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text(
                            'Falta realizar / aprobar Defensa del Proyecto',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text(
                            'Si está activo, aunque termine la cursada no egresa hasta defender.',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: debeDefensa,
                          activeColor: Colors.orange.shade800,
                          onChanged: (v) =>
                              setStateDialog(() => debeDefensa = v),
                        ),
                      ],

                      const Divider(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '¿Debe Módulos Anteriores?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: debeModulosAnteriores,
                        onChanged: (val) {
                          setStateDialog(() {
                            debeModulosAnteriores = val;
                            if (!val) modulosMarcados.clear();
                          });
                        },
                      ),
                      if (debeModulosAnteriores) ...[
                        const Text(
                          'Seleccioná qué módulos debe:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: ['1', '2', '3', '4', '5'].map((numMod) {
                            bool marcado = modulosMarcados.contains(numMod);
                            return FilterChip(
                              label: Text('Módulo $numMod'),
                              selected: marcado,
                              selectedColor: Colors.orange.shade200,
                              onSelected: (v) {
                                setStateDialog(() {
                                  if (v) {
                                    modulosMarcados.add(numMod);
                                    modulosMarcados.sort();
                                    egresado = false;
                                  } else {
                                    modulosMarcados.remove(numMod);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],

                      const Divider(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: egresado
                              ? Colors.teal.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: egresado
                                ? Colors.teal
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            egresado
                                ? '🎓 ¡ALUMNO EGRESADO / RECIBIDO!'
                                : 'Marcar como Egresado (Se recibió)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: egresado
                                  ? Colors.teal.shade800
                                  : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            puedeEgresar
                                ? 'Cumple todo: Promocionó Mód. 6 y no debe módulos previos.'
                                : 'Requiere aprobar Mód. 6, defensa y no deber módulos (1 al 5).',
                            style: const TextStyle(fontSize: 11),
                          ),
                          value: egresado,
                          activeColor: Colors.teal,
                          onChanged: (v) => setStateDialog(() => egresado = v),
                        ),
                      ),

                      const Divider(height: 24),
                      const Text(
                        'Historial de Períodos Cursados:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF1F4E78),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (cargandoHistorial)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else if (historialAlumno.isEmpty)
                        const Text(
                          'Sin registros previos.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else
                        ...historialAlumno.map(
                          (h) => Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${h['anio']} (${h['periodo']}) - Mód. ${h['numero_modulo']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${h['condicion']}${h['presento_nota_recursar'] == true ? ' (Con Nota)' : ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _colorCondicion(h['condicion']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final res = await http.put(
                      Uri.parse(
                        '$baseUrl/cursada/${alumno['cursada_id']}/estado_academico',
                      ),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'alumno_id': alumno['alumno_id'],
                        'condicion': condicion,
                        'debe_defensa': debeDefensa,
                        'notificado_libre': notificadoLibre,
                        'presento_nota_recursar': presentoNota,
                        'modulos_adeudados': debeModulosAnteriores
                            ? modulosMarcados.join(',')
                            : '',
                        'egresado': egresado,
                      }),
                    );
                    if (res.statusCode == 200) {
                      if (mounted) Navigator.pop(context);
                      cargarAlumnos();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Estado'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 2. EXPORTAR PDF DE LIBRES, REGULARES, PROMOCIONADOS O EGRESADOS ---
  Future<void> _exportarListadoPDF(String condicionFiltro) async {
    List<dynamic> filtrados = alumnos.where((a) {
      if (condicionFiltro == 'Todos') return true;
      if (condicionFiltro == 'Egresados') return a['egresado'] == true;
      return (a['condicion'] ?? 'Cursando') == condicionFiltro;
    }).toList();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'REPORTE DE ALUMNOS: ${condicionFiltro.toUpperCase()}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Año: ${widget.anio} | ${widget.periodo} | Módulo ${widget.modulo} - Orientación: ${widget.orientacion}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          ),
          pw.TableHelper.fromTextArray(
            headers: [
              'Apellido y Nombre',
              'DNI',
              'Condición',
              'Debe Mód.',
              'Observaciones',
            ],
            data: filtrados.map((a) {
              String obs = '';
              if (a['egresado'] == true) obs = 'EGRESADO ';
              if (a['debe_defensa'] == true) obs += 'Debe Defensa. ';
              if (a['condicion'] == 'Libre') {
                obs += (a['notificado_libre'] == true
                    ? 'Notificado. '
                    : 'No notif. ');
                obs += (a['presento_nota_recursar'] == true
                    ? 'Presentó Nota.'
                    : 'Sin Nota.');
              }
              return [
                a['nombre_completo'],
                a['dni'].toString(),
                a['condicion'] ?? 'Cursando',
                (a['modulos_adeudados']?.toString().isNotEmpty ?? false)
                    ? 'Mód: ${a['modulos_adeudados']}'
                    : 'Ninguno',
                obs,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Listado_${condicionFiltro}_Mod${widget.modulo}_${widget.anio}.pdf',
    );
  }

  void _mostrarMenuExportarPDF() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exportar Listado en PDF'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Elegí qué nómina de alumnos querés generar en PDF:'),
            const SizedBox(height: 12),
            ...['Promocionado', 'Regular', 'Libre', 'Egresados', 'Todos'].map(
              (tipo) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorCondicion(tipo),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _exportarListadoPDF(tipo);
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text('Exportar Alumnos: $tipo'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. ASISTENTE DE PASE DE PERÍODO ---
  void _mostrarAsistentePasePeriodo() {
    int anioDestino = widget.periodo == '2° Período'
        ? widget.anio + 1
        : widget.anio;
    String periodoDestino = widget.periodo == '2° Período'
        ? '1° Período'
        : '2° Período';
    int moduloDestino = widget.modulo < 6 ? widget.modulo + 1 : 6;
    String modoSeleccion = 'RecursantesConNota';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          List<dynamic> candidatos = alumnos.where((a) {
            if (modoSeleccion == 'RecursantesConNota') {
              return a['condicion'] == 'Libre' &&
                  a['presento_nota_recursar'] == true;
            } else {
              return (a['condicion'] == 'Promocionado' ||
                      a['condicion'] == 'Regular') &&
                  a['egresado'] != true;
            }
          }).toList();

          return AlertDialog(
            title: const Text('Pasar Alumnos al Próximo Período'),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Los datos actuales quedarán guardados en el historial de este período. Se creará una nueva inscripción en el período destino:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    RadioListTile<String>(
                      title: const Text(
                        'Libres que presentaron nota (Recursan este mismo módulo)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: 'RecursantesConNota',
                      groupValue: modoSeleccion,
                      onChanged: (v) => setStateModal(() {
                        modoSeleccion = v!;
                        moduloDestino = widget.modulo;
                      }),
                    ),
                    RadioListTile<String>(
                      title: const Text(
                        'Promocionados / Regulares (Pasan al módulo siguiente)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      value: 'Promocionados',
                      groupValue: modoSeleccion,
                      onChanged: (v) => setStateModal(() {
                        modoSeleccion = v!;
                        moduloDestino = widget.modulo < 6
                            ? widget.modulo + 1
                            : 6;
                      }),
                    ),
                    const Divider(),
                    const Text(
                      'Período y Módulo de Destino:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: 110,
                          child: DropdownButtonFormField<int>(
                            value: anioDestino,
                            decoration: const InputDecoration(
                              labelText: 'Año',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [2025, 2026, 2027, 2028]
                                .map(
                                  (a) => DropdownMenuItem(
                                    value: a,
                                    child: Text('$a'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setStateModal(() => anioDestino = v!),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: periodoDestino,
                            decoration: const InputDecoration(
                              labelText: 'Período',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['1° Período', '2° Período']
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setStateModal(() => periodoDestino = v!),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: DropdownButtonFormField<int>(
                            value: moduloDestino,
                            decoration: const InputDecoration(
                              labelText: 'Módulo',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [1, 2, 3, 4, 5, 6]
                                .map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text('Mód. $m'),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setStateModal(() => moduloDestino = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Alumnos que cumplen la condición (${candidatos.length}):',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (candidatos.isEmpty)
                      const Text(
                        'Ningún alumno cumple este filtro todavía.',
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      )
                    else
                      ...candidatos.map(
                        (c) => Text(
                          '• ${c['nombre_completo']} (${c['dni']})',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4E78),
                  foregroundColor: Colors.white,
                ),
                onPressed: candidatos.isEmpty
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        final res = await http.post(
                          Uri.parse('$baseUrl/alumnos/masivo'),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'alumnos': candidatos,
                            'numero_modulo': moduloDestino,
                            'orientacion': widget.orientacion,
                            'anio': anioDestino,
                            'periodo': periodoDestino,
                          }),
                        );
                        if (res.statusCode == 200 && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(json.decode(res.body)['mensaje']),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.forward),
                label: const Text('Inscribir en Nuevo Período'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- FUNCIONES DE ALTA Y CARGA MASIVA ---
  Future<void> _procesarTextoMasivo(String textoCrudo) async {
    List<String> lineas = const LineSplitter().convert(textoCrudo);
    List<Map<String, String>> listaAEnviar = [];

    for (var linea in lineas) {
      if (linea.trim().isEmpty) continue;
      List<String> partes = linea.contains('\t')
          ? linea.split('\t')
          : (linea.contains(';') ? linea.split(';') : linea.split(','));
      if (partes.length >= 2) {
        String col1 = partes[0].trim();
        String col2 = partes[1].trim();
        String col3 = partes.length >= 3 ? partes[2].trim() : '';
        if (col1.toLowerCase().contains('nombre') ||
            col2.toLowerCase().contains('dni'))
          continue;

        bool col1EsDni = RegExp(r'^[0-9.]+$').hasMatch(col1);
        String nombre = col1EsDni ? col2 : col1;
        String dni = col1EsDni ? col1 : col2;
        String clave = col3.isNotEmpty ? col3 : dni;
        listaAEnviar.add({
          'nombre_completo': nombre,
          'dni': dni,
          'contrasena_moodle': clave,
        });
      }
    }

    if (listaAEnviar.isEmpty) return;
    setState(() => cargando = true);
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/alumnos/masivo'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'alumnos': listaAEnviar,
          'numero_modulo': widget.modulo,
          'orientacion': widget.orientacion,
          'anio': widget.anio,
          'periodo': widget.periodo,
        }),
      );
      if (res.statusCode == 200) {
        await cargarAlumnos();
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json.decode(res.body)['mensaje']),
              backgroundColor: Colors.green,
            ),
          );
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  void _mostrarDialogoCargaMasiva() {
    TextEditingController textoMasivoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Carga Masiva - ${widget.anio} (${widget.periodo})'),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F4E78),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    ClipboardData? data = await Clipboard.getData(
                      Clipboard.kTextPlain,
                    );
                    if (data != null && data.text != null) {
                      textoMasivoCtrl.text = data.text!;
                    }
                  },
                  icon: const Icon(Icons.content_paste),
                  label: const Text(
                    'Pegar Lista desde el Portapapeles (Excel / Word / PDF)',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Formato por renglón: Apellido y Nombre ; DNI ; Contraseña\n(Acepta celdas pegadas directo de Excel, punto y coma o comas):',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textoMasivoCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'PEREZ JUAN; 40111222; 40111222\nGOMEZ MARIA; 38999888; 38999888',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _procesarTextoMasivo(textoMasivoCtrl.text);
            },
            child: const Text('Importar Todos'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNuevoAlumno() {
    TextEditingController nombreCtrl = TextEditingController();
    TextEditingController dniCtrl = TextEditingController();
    TextEditingController claveCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar Alumno (${widget.anio} - ${widget.periodo})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Apellido y Nombre *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dniCtrl,
              decoration: const InputDecoration(
                labelText: 'DNI *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: claveCtrl,
              decoration: const InputDecoration(
                labelText: 'Contraseña Moodle *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty || dniCtrl.text.isEmpty) return;
              await http.post(
                Uri.parse('$baseUrl/alumnos'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'nombre_completo': nombreCtrl.text.trim(),
                  'dni': dniCtrl.text.trim(),
                  'contrasena_moodle': claveCtrl.text.trim().isEmpty
                      ? dniCtrl.text.trim()
                      : claveCtrl.text.trim(),
                  'numero_modulo': widget.modulo,
                  'orientacion': widget.orientacion,
                  'anio': widget.anio,
                  'periodo': widget.periodo,
                }),
              );
              if (mounted) Navigator.pop(context);
              cargarAlumnos();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarFichaLegajo(dynamic alumno) {
    TextEditingController nombreCtrl = TextEditingController(
      text: alumno['nombre_completo'] ?? '',
    );
    TextEditingController dniCtrl = TextEditingController(
      text: alumno['dni']?.toString() ?? '',
    );
    TextEditingController claveCtrl = TextEditingController(
      text: alumno['contrasena_moodle']?.toString() ?? '',
    );
    TextEditingController correoCtrl = TextEditingController(
      text: alumno['email'] ?? '',
    );
    TextEditingController telCtrl = TextEditingController(
      text: alumno['telefono'] ?? '',
    );

    bool dDni = alumno['doc_dni'] ?? false;
    bool dFoto = alumno['doc_foto_carnet'] ?? false;
    bool dResidencia = alumno['doc_certificado_residencia'] ?? false;
    bool dPaseConst = alumno['doc_constancia_pase'] ?? false;
    bool dPaseLeg = alumno['doc_pase_legalizado'] ?? false;
    bool dSeptimo = alumno['doc_certificado_septimo'] ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Datos y Documentación (Legajo)'),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apellido y Nombre',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dniCtrl,
                          decoration: const InputDecoration(
                            labelText: 'DNI',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: claveCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Clave Moodle',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: correoCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: telCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Wrap(
                    children: [
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: const Text(
                            'Fotocopia DNI',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: dDni,
                          dense: true,
                          onChanged: (v) => setStateDialog(() => dDni = v!),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: const Text(
                            'Foto 4x4',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: dFoto,
                          dense: true,
                          onChanged: (v) => setStateDialog(() => dFoto = v!),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: const Text(
                            'Cert. Residencia',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: dResidencia,
                          dense: true,
                          onChanged: (v) =>
                              setStateDialog(() => dResidencia = v!),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: const Text(
                            'Constancia Pase',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: dPaseConst,
                          dense: true,
                          onChanged: (v) =>
                              setStateDialog(() => dPaseConst = v!),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: const Text(
                            'Pase Legalizado',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: dPaseLeg,
                          dense: true,
                          onChanged: (v) => setStateDialog(() => dPaseLeg = v!),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: CheckboxListTile(
                          title: const Text(
                            'Cert. Séptimo',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: dSeptimo,
                          dense: true,
                          onChanged: (v) => setStateDialog(() => dSeptimo = v!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final pdf = pw.Document();
                pdf.addPage(
                  pw.Page(
                    pageFormat: PdfPageFormat.a4,
                    build: (ctx) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 40),
                        pw.Center(
                          child: pw.Text(
                            'CONSTANCIA DE ALUMNO REGULAR',
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 40),
                        pw.Text(
                          'Se deja constancia de que ${alumno['nombre_completo']} (DNI N° ${alumno['dni']}) cursa el Módulo ${widget.modulo} (${widget.orientacion}) en el ciclo ${widget.anio} (${widget.periodo}).',
                        ),
                      ],
                    ),
                  ),
                );
                await Printing.layoutPdf(onLayout: (f) async => pdf.save());
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Constancia'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await http.put(
                  Uri.parse('$baseUrl/alumno/${alumno['alumno_id']}'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({
                    'nombre_completo': nombreCtrl.text.trim(),
                    'dni': dniCtrl.text.trim(),
                    'contrasena_moodle': claveCtrl.text.trim(),
                    'email': correoCtrl.text.trim(),
                    'telefono': telCtrl.text.trim(),
                    'doc_dni': dDni,
                    'doc_foto_carnet': dFoto,
                    'doc_certificado_residencia': dResidencia,
                    'doc_constancia_pase': dPaseConst,
                    'doc_pase_legalizado': dPaseLeg,
                    'doc_certificado_septimo': dSeptimo,
                  }),
                );
                if (mounted) Navigator.pop(context);
                cargarAlumnos();
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorCondicion(String? cond) {
    if (cond == 'Promocionado') return Colors.green.shade700;
    if (cond == 'Regular') return Colors.blue.shade700;
    if (cond == 'Libre') return Colors.red.shade700;
    if (cond == 'Egresados') return Colors.teal.shade700;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> alumnosMostrados = alumnos.where((a) {
      if (_filtroCondicion == 'Todos') return true;
      if (_filtroCondicion == 'Egresados') return a['egresado'] == true;
      return (a['condicion'] ?? 'Cursando') == _filtroCondicion;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              Text(
                'Alumnos (${widget.anio} - ${widget.periodo})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F4E78),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F4E78),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _mostrarDialogoNuevoAlumno,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Agregar 1'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _mostrarDialogoCargaMasiva,
                    icon: const Icon(Icons.content_paste, size: 18),
                    label: const Text('Importar Lista'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _mostrarMenuExportarPDF,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF Condición'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _mostrarAsistentePasePeriodo,
                    icon: const Icon(Icons.fast_forward, size: 18),
                    label: const Text('Fin de Período'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  [
                    'Todos',
                    'Cursando',
                    'Promocionado',
                    'Regular',
                    'Libre',
                    'Egresados',
                  ].map((f) {
                    bool sel = _filtroCondicion == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: FilterChip(
                        label: Text(f, style: const TextStyle(fontSize: 12)),
                        selected: sel,
                        onSelected: (_) => setState(() => _filtroCondicion = f),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 Tocá sobre la tarjeta de cualquier alumno para marcar si quedó Regular/Promocionado/Libre o si debe módulos anteriores.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          cargando
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : alumnosMostrados.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Text(
                      'No hay alumnos registrados en este filtro/período.',
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: alumnosMostrados.length,
                    itemBuilder: (context, index) {
                      final al = alumnosMostrados[index];
                      String cond = al['condicion'] ?? 'Cursando';
                      String adeuda = al['modulos_adeudados']?.toString() ?? '';
                      bool esEgresado = al['egresado'] == true;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1.5,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _abrirTarjetaAcademica(al),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _colorCondicion(cond),
                                  child: Text(
                                    al['nombre_completo'][0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              al['nombre_completo'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (esEgresado)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.teal,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                '🎓 EGRESADO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'DNI: ${al['dni']} | Clave: ${al['contrasena_moodle']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: [
                                          _etiqueta(
                                            cond.toUpperCase(),
                                            _colorCondicion(cond),
                                          ),
                                          if (adeuda.isNotEmpty)
                                            _etiqueta(
                                              'Debe Mód: $adeuda',
                                              Colors.deepOrange,
                                            ),
                                          if (al['debe_defensa'] == true)
                                            _etiqueta(
                                              'Debe Defensa',
                                              Colors.orange.shade800,
                                            ),
                                          if (cond == 'Libre')
                                            _etiqueta(
                                              al['presento_nota_recursar'] ==
                                                      true
                                                  ? 'Presentó Nota'
                                                  : 'Sin Nota',
                                              al['presento_nota_recursar'] ==
                                                      true
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Editar Legajo / Papeles',
                                  icon: const Icon(
                                    Icons.folder_shared_outlined,
                                    color: Color(0xFF1F4E78),
                                  ),
                                  onPressed: () => _mostrarFichaLegajo(al),
                                ),
                                IconButton(
                                  tooltip: 'Quitar de este período',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await http.delete(
                                      Uri.parse(
                                        '$baseUrl/cursada/${al['cursada_id']}',
                                      ),
                                    );
                                    cargarAlumnos();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _etiqueta(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

// ============================================================================
// PANTALLA 2: GRUPOS Y PROYECTOS
// ============================================================================
class PantallaGrupos extends StatefulWidget {
  final int anio;
  final String periodo;
  final int modulo;
  final String orientacion;
  const PantallaGrupos({
    super.key,
    required this.anio,
    required this.periodo,
    required this.modulo,
    required this.orientacion,
  });

  @override
  State<PantallaGrupos> createState() => _PantallaGruposState();
}

class _PantallaGruposState extends State<PantallaGrupos> {
  List<dynamic> grupos = [];
  List<dynamic> alumnosTotales = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatosGenerales();
  }

  Future<void> cargarDatosGenerales() async {
    setState(() => cargando = true);
    try {
      final resAl = await http.get(
        Uri.parse(
          '$baseUrl/alumnos_cursada?modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
        ),
      );
      final resGr = await http.get(
        Uri.parse(
          '$baseUrl/grupos?modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
        ),
      );
      if (resAl.statusCode == 200) alumnosTotales = json.decode(resAl.body);
      if (resGr.statusCode == 200) grupos = json.decode(resGr.body);
    } catch (e) {
      print(e);
    }
    setState(() => cargando = false);
  }

  void mostrarDialogoCrearGrupo() {
    TextEditingController nombreCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nuevo Grupo'),
        content: TextField(
          controller: nombreCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre (Ej: Grupo 1)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await http.post(
                Uri.parse('$baseUrl/grupos'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'numero_modulo': widget.modulo,
                  'orientacion': widget.orientacion,
                  'anio': widget.anio,
                  'periodo': widget.periodo,
                  'nombre_grupo': nombreCtrl.text.trim(),
                }),
              );
              cargarDatosGenerales();
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void abrirAdministradorGrupo(dynamic grupoInfo) {
    int grupoId = grupoInfo['id'];
    TextEditingController temaCtrl = TextEditingController(
      text: grupoInfo['tema_proyecto'] ?? '',
    );
    TextEditingController notaFinalCtrl = TextEditingController(
      text: grupoInfo['nota_final'] ?? '',
    );
    TextEditingController obsCtrl = TextEditingController(
      text: grupoInfo['observaciones_grupo'] ?? '',
    );

    String i1 = grupoInfo['instancia_1'] ?? 'Pendiente';
    String i2 = grupoInfo['instancia_2'] ?? 'Pendiente';
    String i3 = grupoInfo['instancia_3'] ?? 'Pendiente';
    String iRec = grupoInfo['instancia_recuperacion'] ?? 'No aplica';
    String def = grupoInfo['estado_defensa'] ?? 'Pendiente';
    int? alumnoSeleccionadoId;
    List<String> opcionesNota = [
      'Pendiente',
      'Aprobado',
      'Desaprobado',
      'No presentó',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final grupoActualizado = grupos.firstWhere(
            (g) => g['id'] == grupoId,
            orElse: () => grupoInfo,
          );
          final List integrantes = grupoActualizado['integrantes'] ?? [];

          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Administrar: ${grupoActualizado['nombre_grupo']}'),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () async {
                    Navigator.pop(context);
                    await http.delete(Uri.parse('$baseUrl/grupos/$grupoId'));
                    cargarDatosGenerales();
                  },
                ),
              ],
            ),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: alumnoSeleccionadoId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Agregar Integrante (Máx 4)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: alumnosTotales
                                .map(
                                  (a) => DropdownMenuItem<int>(
                                    value: a['alumno_id'],
                                    child: Text(
                                      a['nombre_completo'],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setStateDialog(
                              () => alumnoSeleccionadoId = val,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (alumnoSeleccionadoId != null) {
                              await http.post(
                                Uri.parse('$baseUrl/grupo/agregar_alumno'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({
                                  'grupo_id': grupoId,
                                  'alumno_id': alumnoSeleccionadoId,
                                }),
                              );
                              await cargarDatosGenerales();
                              setStateDialog(() => alumnoSeleccionadoId = null);
                            }
                          },
                          child: const Text('Agregar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...integrantes.map(
                      (i) => ListTile(
                        dense: true,
                        title: Text(
                          '• ${i['nombre_completo']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await http.delete(
                              Uri.parse(
                                '$baseUrl/grupo/quitar_alumno/$grupoId/${i['id']}',
                              ),
                            );
                            await cargarDatosGenerales();
                            setStateDialog(() {});
                          },
                        ),
                      ),
                    ),
                    const Divider(),
                    TextField(
                      controller: temaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tema del Proyecto',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: i1,
                            decoration: const InputDecoration(
                              labelText: 'Instancia 1',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: opcionesNota
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => i1 = v!),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: i2,
                            decoration: const InputDecoration(
                              labelText: 'Instancia 2',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: opcionesNota
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => i2 = v!),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: i3,
                            decoration: const InputDecoration(
                              labelText: 'Instancia 3',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: opcionesNota
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => i3 = v!),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: iRec,
                            decoration: const InputDecoration(
                              labelText: 'Recuperatorio',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items:
                                [
                                      'No aplica',
                                      'Pendiente',
                                      'Aprobado',
                                      'Desaprobado',
                                    ]
                                    .map(
                                      (o) => DropdownMenuItem(
                                        value: o,
                                        child: Text(o),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setStateDialog(() => iRec = v!),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: DropdownButtonFormField<String>(
                            value: def,
                            decoration: const InputDecoration(
                              labelText: 'Defensa Final',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['Pendiente', 'Aprobado', 'Desaprobado']
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(o),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => def = v!),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: TextField(
                            controller: notaFinalCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nota Final',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: obsCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await http.put(
                    Uri.parse('$baseUrl/grupos/$grupoId'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'tema_proyecto': temaCtrl.text.trim(),
                      'instancia_1': i1,
                      'instancia_2': i2,
                      'instancia_3': i3,
                      'instancia_recuperacion': iRec,
                      'estado_defensa': def,
                      'nota_final': notaFinalCtrl.text.trim(),
                      'observaciones_grupo': obsCtrl.text.trim(),
                    }),
                  );
                  if (mounted) Navigator.pop(context);
                  cargarDatosGenerales();
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grupos (${widget.anio} - ${widget.periodo})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F4E78),
                ),
              ),
              ElevatedButton.icon(
                onPressed: mostrarDialogoCrearGrupo,
                icon: const Icon(Icons.add),
                label: const Text('Crear Grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F4E78),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : grupos.isEmpty
                ? const Center(
                    child: Text('No hay grupos creados en este período.'),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 340,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                    itemCount: grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = grupos[index];
                      final List integrantes = grupo['integrantes'] ?? [];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                grupo['nombre_grupo'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(),
                              ...integrantes.map(
                                (i) => Text(
                                  '• ${i['nombre_completo']}',
                                  style: const TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Defensa: ${grupo['estado_defensa'] ?? 'Pendiente'} | Nota: ${grupo['nota_final'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      abrirAdministradorGrupo(grupo),
                                  child: const Text('Administrar'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PANTALLA 3: SEGUIMIENTO Y BOT (CON SELECCIÓN DE ALUMNOS Y DESBLOQUEO)
// ============================================================================
class PantallaSeguimiento extends StatefulWidget {
  final int anio;
  final String periodo;
  final int modulo;
  final String orientacion;
  const PantallaSeguimiento({
    super.key,
    required this.anio,
    required this.periodo,
    required this.modulo,
    required this.orientacion,
  });

  @override
  State<PantallaSeguimiento> createState() => _PantallaSeguimientoState();
}

class _PantallaSeguimientoState extends State<PantallaSeguimiento> {
  List<dynamic> cursadas = [];
  bool cargando = true;
  bool botEjecutando = false;
  String progresoBot = '';
  Timer? _timerEstado;

  @override
  void initState() {
    super.initState();
    cargarSeguimiento();
    verificarEstadoBot();
  }

  @override
  void dispose() {
    _timerEstado?.cancel();
    super.dispose();
  }

  Future<void> cargarSeguimiento() async {
    setState(() => cargando = true);
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/alumnos_cursada?modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          cursadas = json.decode(response.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  void _abrirSelectorAlumnosBot() {
    Set<int> seleccionados = cursadas
        .map<int>((c) => c['cursada_id'] as int)
        .toSet();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) {
          bool todosMarcados = seleccionados.length == cursadas.length;
          return AlertDialog(
            title: const Text('Seleccionar Alumnos para el Bot'),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 420),
              width: double.maxFinite,
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text(
                      'Seleccionar / Deseleccionar Todos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    value: todosMarcados,
                    onChanged: (v) {
                      setStateModal(() {
                        if (v == true) {
                          seleccionados = cursadas
                              .map<int>((c) => c['cursada_id'] as int)
                              .toSet();
                        } else {
                          seleccionados.clear();
                        }
                      });
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cursadas.length,
                      itemBuilder: (context, i) {
                        final al = cursadas[i];
                        int cid = al['cursada_id'];
                        return CheckboxListTile(
                          dense: true,
                          title: Text(al['nombre_completo']),
                          subtitle: Text('DNI: ${al['dni']}'),
                          value: seleccionados.contains(cid),
                          onChanged: (v) {
                            setStateModal(() {
                              if (v == true)
                                seleccionados.add(cid);
                              else
                                seleccionados.remove(cid);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await http.post(Uri.parse('$baseUrl/bot/cancelar'));
                  if (mounted) Navigator.pop(ctx);
                  verificarEstadoBot();
                },
                child: const Text(
                  'Destrabar / Reiniciar Bot',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: seleccionados.isEmpty
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _ejecutarBotConSeleccion(
                          seleccionados.toList(),
                          forzar: true,
                        );
                      },
                icon: const Icon(Icons.play_arrow),
                label: Text('Iniciar (${seleccionados.length})'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _ejecutarBotConSeleccion(
    List<int> cursadaIds, {
    bool forzar = false,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ejecutar_bot'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'modulo': widget.modulo,
          'orientacion': widget.orientacion,
          'anio': widget.anio,
          'periodo': widget.periodo,
          'cursada_ids': cursadaIds,
          'forzar': forzar,
        }),
      );
      if (res.statusCode == 200) {
        setState(() {
          botEjecutando = true;
          progresoBot =
              'Iniciando seguimiento de ${cursadaIds.length} alumnos...';
        });
        _iniciarMonitoreoBot();
      }
    } catch (e) {
      print(e);
    }
  }

  void _iniciarMonitoreoBot() {
    _timerEstado?.cancel();
    _timerEstado = Timer.periodic(
      const Duration(seconds: 3),
      (_) => verificarEstadoBot(),
    );
  }

  Future<void> verificarEstadoBot() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/bot/estado'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        bool activo = data['ejecutando'] ?? false;
        setState(() {
          botEjecutando = activo;
          progresoBot = data['progreso'] ?? '';
        });
        if (!activo && _timerEstado != null) {
          _timerEstado?.cancel();
          cargarSeguimiento();
        } else if (activo &&
            (_timerEstado == null || !_timerEstado!.isActive)) {
          _iniciarMonitoreoBot();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void copiarParaWhatsApp() {
    String reporteGral =
        "Seguimiento Mód. ${widget.modulo} (${widget.orientacion} - ${widget.anio} ${widget.periodo}):\n\n";
    for (var c in cursadas) {
      if (c['resumen_texto'] != null &&
          c['resumen_texto'].toString().isNotEmpty) {
        reporteGral += "${c['resumen_texto']}\n\n";
      }
    }
    Clipboard.setData(ClipboardData(text: reporteGral));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Copiado para WhatsApp!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              Text(
                'Seguimiento - Mód. ${widget.modulo}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F4E78),
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    onPressed: _abrirSelectorAlumnosBot,
                    icon: const Icon(Icons.smart_toy),
                    label: Text(
                      botEjecutando
                          ? 'Bot Activo (Opciones)'
                          : 'Sincronizar Moodle (Elegir)',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: copiarParaWhatsApp,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (botEjecutando || progresoBot.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Row(
                children: [
                  if (botEjecutando)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (botEjecutando) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      progresoBot,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                  if (botEjecutando)
                    TextButton(
                      onPressed: () async {
                        await http.post(Uri.parse('$baseUrl/bot/cancelar'));
                        verificarEstadoBot();
                      },
                      child: const Text(
                        'Detener',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: cargarSeguimiento,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          cargando
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cursadas.length,
                    itemBuilder: (context, index) {
                      final c = cursadas[index];
                      final resumen =
                          (c['resumen_texto'] != null &&
                              c['resumen_texto'].toString().isNotEmpty)
                          ? c['resumen_texto']
                          : 'Sin datos. Tocá "Sincronizar Moodle" para analizar a este alumno.';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            c['nombre_completo'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              resumen,
                              style: TextStyle(
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Sincronizar solo a este alumno',
                            icon: const Icon(
                              Icons.sync,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () => _ejecutarBotConSeleccion([
                              c['cursada_id'],
                            ], forzar: true),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

// ============================================================================
// PANTALLA 4: CONFIGURACIÓN DE ENLACES MOODLE
// ============================================================================
class PantallaEnlaces extends StatefulWidget {
  final int modulo;
  final String orientacion;
  const PantallaEnlaces({
    super.key,
    required this.modulo,
    required this.orientacion,
  });

  @override
  State<PantallaEnlaces> createState() => _PantallaEnlacesState();
}

class _PantallaEnlacesState extends State<PantallaEnlaces> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _urlCalifController = TextEditingController();

  String _semanaSeleccionada = 'S02';
  String _materiaSeleccionada = 'Cs. Sociales';
  String _tipoActividadSeleccionada = 'Cuestionario / Tarea (Con Link)';

  final List<String> _semanas = [
    'S02',
    'S03',
    'S04',
    'S07',
    'S08',
    'S11',
    'S12',
    'Evaluaciones',
  ];
  final List<String> _materias = [
    'Cs. Sociales',
    'Matemática',
    'Lengua',
    'FpT',
    'Cs. Naturales',
  ];
  final List<String> _tiposActividad = [
    'Cuestionario / Tarea (Con Link)',
    'Actividad Colaborativa (Manual)',
  ];

  List<dynamic> enlacesGuardados = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => cargando = true);
    try {
      final resAct = await http.get(
        Uri.parse(
          '$baseUrl/actividades?modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}',
        ),
      );
      final resConf = await http.get(
        Uri.parse(
          '$baseUrl/config_curso?modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}',
        ),
      );
      if (resAct.statusCode == 200) enlacesGuardados = json.decode(resAct.body);
      if (resConf.statusCode == 200) {
        final conf = json.decode(resConf.body);
        _urlCalifController.text = conf['url_calificaciones'] ?? '';
      }
    } catch (e) {
      print(e);
    }
    setState(() => cargando = false);
  }

  Future<void> guardarUrlCalificaciones() async {
    await http.post(
      Uri.parse('$baseUrl/config_curso'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'numero_modulo': widget.modulo,
        'orientacion': widget.orientacion,
        'url_calificaciones': _urlCalifController.text.trim(),
      }),
    );
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL de calificaciones guardada'),
          backgroundColor: Colors.green,
        ),
      );
  }

  Future<void> guardarEnlace() async {
    bool esManual = _tipoActividadSeleccionada.contains('Manual');
    if (!esManual && _urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pegá una URL o elegí Actividad Colaborativa (Manual)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/actividades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'numero_modulo': widget.modulo,
        'orientacion': widget.orientacion,
        'semana': _semanaSeleccionada,
        'materia': _materiaSeleccionada,
        'tipo_actividad': _tipoActividadSeleccionada,
        'url_actividad': esManual
            ? 'Revisión_Manual'
            : _urlController.text.trim(),
      }),
    );

    if (response.statusCode == 200) {
      _urlController.clear();
      await cargarDatos();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Actividad guardada!'),
            backgroundColor: Colors.green,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esManual = _tipoActividadSeleccionada.contains('Manual');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enlaces Moodle - Mód. ${widget.modulo} (${widget.orientacion})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F4E78),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlCalifController,
                      decoration: const InputDecoration(
                        labelText: 'URL Tabla General de Calificaciones',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: guardarUrlCalificaciones,
                    child: const Text('Fijar URL'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 130,
                        child: DropdownButtonFormField<String>(
                          value: _semanaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Semana',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _semanas
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _semanaSeleccionada = v!),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: DropdownButtonFormField<String>(
                          value: _materiaSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Materia',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _materias
                              .map(
                                (m) =>
                                    DropdownMenuItem(value: m, child: Text(m)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _materiaSeleccionada = v!),
                        ),
                      ),
                      SizedBox(
                        width: 250,
                        child: DropdownButtonFormField<String>(
                          value: _tipoActividadSeleccionada,
                          decoration: const InputDecoration(
                            labelText: 'Tipo Actividad',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _tiposActividad
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _tipoActividadSeleccionada = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          enabled: !esManual,
                          decoration: InputDecoration(
                            labelText: esManual
                                ? 'Revisión Manual (Sin Link)'
                                : 'URL Directa de la Actividad',
                            filled: esManual,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1F4E78),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: guardarEnlace,
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: enlacesGuardados.length,
                    itemBuilder: (context, index) {
                      final enlace = enlacesGuardados[index];
                      bool esRevManual =
                          enlace['url_actividad'] == 'Revisión_Manual';
                      return Card(
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            esRevManual ? Icons.forum : Icons.check_circle,
                            color: esRevManual ? Colors.orange : Colors.green,
                          ),
                          title: Text(
                            '${enlace['semana']} - ${enlace['materia']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            esRevManual
                                ? 'Actividad Colaborativa (Manual)'
                                : enlace['url_actividad'],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await http.delete(
                                Uri.parse(
                                  '$baseUrl/actividades/${enlace['id']}',
                                ),
                              );
                              cargarDatos();
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
