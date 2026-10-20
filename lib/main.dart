import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const String baseUrl = 'https://api-sistema-vir.onrender.com/api';

// PALETA DE COLORES OFICIAL BASADA EN EL LOGO DEL SISTEMA VIRTUAL N° 9002
const Color kNegroLogo = Color(0xFF141414);
const Color kCarbonLogo = Color(0xFF222222);
const Color kRojoLogo = Color(0xFFD32F2F);
const Color kNaranjaLogo = Color(0xFFFF3D00);

const List<String> SEDES_OFICIALES = [
  'Aguaray',
  'Aguas Blancas',
  'Angastaco',
  'Animaná',
  'Apolinario Saravia',
  'Cachi / Payogasta',
  'Campo Quijano',
  'Campo Santo',
  'Capital',
  'Chicoana',
  'El Carril',
  'El Galpón',
  'Embarcación',
  'Gral. Güemes',
  'Gral. Mosconi',
  'Gral. Pizarro',
  'Guachipas',
  'Ing. Mauri / Gob. Solá / Alfarcito',
  'Iruya',
  'J. V. González',
  'La Unión',
  'Los Toldos',
  'Luracatao',
  'Metán',
  'Moldes',
  'Olacapato',
  'Orán',
  'Pichanal',
  'Poscaya / Nazareno',
  'Rivadavia Banda Sur',
  'Rosario de la Frontera',
  'Rosario de Lerma',
  'Salvador Mazza',
  'San Antonio de los Cobres',
  'San Carlos',
  'Tartagal',
];

void main() {
  runApp(const SistemaAcademicoApp());
}

class SistemaAcademicoApp extends StatelessWidget {
  const SistemaAcademicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Virtual N° 9002 - Gestión Académica',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kRojoLogo,
          primary: kRojoLogo,
          secondary: kNegroLogo,
        ),
        useMaterial3: true,
      ),
      home: const PantallaLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============================================================================
// WIDGET DEL LOGO OFICIAL N° 9002 (ESFERA NEGRA 3D, CÍRCULO ROJO, 8 PUNTOS Y LÍNEAS ROJAS)
// ============================================================================
class LogoSistema9002 extends StatelessWidget {
  final double size;
  const LogoSistema9002({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _Logo9002Painter()),
    );
  }
}

class _Logo9002Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final Offset center = Offset(r, r);

    // 1. Esfera negra 3D con brillo superior
    final Path circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: r));
    canvas.save();
    canvas.clipPath(circlePath);

    final Paint spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.9,
        colors: [Colors.grey.shade800, const Color(0xFF111111), Colors.black],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, spherePaint);

    // 2. Franjas rojas curvas en la parte inferior izquierda
    final Paint stripePaint = Paint()
      ..color = kRojoLogo
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055;

    for (int i = 0; i < 3; i++) {
      double offset = i * (size.width * 0.085);
      Path stripe = Path();
      stripe.moveTo(-size.width * 0.1, size.height * 0.38 + offset);
      stripe.quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.92 + offset * 0.6,
        size.width * 0.95,
        size.height * 0.78 + offset * 0.3,
      );
      canvas.drawPath(stripe, stripePaint);
    }

    // 3. Óvalo central rojo/naranja inclinado
    canvas.save();
    canvas.translate(size.width * 0.50, size.height * 0.44);
    canvas.rotate(-0.45);

    final Paint redCenterPaint = Paint()
      ..color = kNaranjaLogo
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width * 0.28,
        height: size.height * 0.19,
      ),
      redCenterPaint,
    );

    // 4. 8 óvalos blancos alrededor del centro
    final Paint whiteDotPaint = Paint()
      ..color = const Color(0xFFEAEAEA)
      ..style = PaintingStyle.fill;

    const int numDots = 8;
    final double rx = size.width * 0.25;
    final double ry = size.height * 0.19;

    for (int i = 0; i < numDots; i++) {
      double angle = (i * 2 * math.pi) / numDots;
      double dx = rx * math.cos(angle);
      double dy = ry * math.sin(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(dx, dy),
          width: size.width * 0.11,
          height: size.height * 0.075,
        ),
        whiteDotPaint,
      );
    }
    canvas.restore();

    // 5. Reflejo cristalino superior (efecto 3D del logo)
    final Paint glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.35), Colors.white.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.45));

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.12,
        size.height * 0.04,
        size.width * 0.76,
        size.height * 0.38,
      ),
      glossPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// PANTALLA DE INICIO DE SESIÓN (LOGIN CON LOGO Y COLORES N° 9002)
// ============================================================================
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _userCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _cargando = false;
  bool _ocultarPass = true;

  Future<void> _iniciarSesion() async {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) return;
    setState(() => _cargando = true);

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _userCtrl.text.trim(),
          'password': _passCtrl.text.trim(),
        }),
      );

      setState(() => _cargando = false);

      if (res.statusCode == 200) {
        final usuario = json.decode(res.body);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PantallaPrincipal(usuarioActual: usuario),
            ),
          );
        }
      } else {
        final err = json.decode(res.body)['error'] ?? 'Error al ingresar';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: kRojoLogo),
          );
        }
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Conectando con el servidor... Intentá en unos segundos ($e)',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kNegroLogo,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kNegroLogo, Color(0xFF2B0909), kNegroLogo],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: kRojoLogo, width: 1.5),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO OFICIAL N° 9002 EN EL INICIO
                    const LogoSistema9002(size: 96),
                    const SizedBox(height: 16),
                    const Text(
                      'Sistema Virtual N° 9002',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kNegroLogo,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      'Gestión Académica y Seguimiento por Sedes',
                      style: TextStyle(
                        fontSize: 13,
                        color: kRojoLogo,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _userCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: kRojoLogo,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _ocultarPass,
                      onSubmitted: (_) => _iniciarSesion(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: kRojoLogo,
                        ),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _ocultarPass
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _ocultarPass = !_ocultarPass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kRojoLogo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _cargando ? null : _iniciarSesion,
                        icon: _cargando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          _cargando ? 'Verificando...' : 'Ingresar al Sistema',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ESTRUCTURA PRINCIPAL CON BARRA NEGRA/ROJA Y LOGO N° 9002
// ============================================================================
class PantallaPrincipal extends StatefulWidget {
  final Map<String, dynamic> usuarioActual;
  const PantallaPrincipal({super.key, required this.usuarioActual});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceSeleccionado = 0;

  late bool _esSuperAdmin;
  late String _sedeActual;
  late List<int> _modulosDisponibles;
  late int _moduloActual;

  int _anioActual = 2026;
  String _periodoActual = '2° Período';
  String _orientacionActual = 'Turismo';

  final List<int> _aniosDisponibles = [2025, 2026, 2027, 2028];
  final List<String> _periodosDisponibles = ['1° Período', '2° Período'];
  final List<String> _orientacionesDisponibles = [
    'Turismo',
    'Economía y Administración',
  ];

  @override
  void initState() {
    super.initState();
    _esSuperAdmin =
        (widget.usuarioActual['rol'] == 'admin' ||
        widget.usuarioActual['sede'] == 'TODAS');
    _sedeActual = _esSuperAdmin
        ? 'Tartagal'
        : widget.usuarioActual['sede'].toString();

    String modsStr =
        widget.usuarioActual['modulos_permitidos']?.toString() ?? '1,2,3,4,5,6';
    _modulosDisponibles = modsStr
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
    if (_modulosDisponibles.isEmpty) _modulosDisponibles = [6];
    _modulosDisponibles.sort();
    _moduloActual = _modulosDisponibles.first;
  }

  Future<void> _confirmarCerrarSesion() async {
    bool salir =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: Text(
              '¿Querés salir de la cuenta de ${widget.usuarioActual['nombre_completo']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRojoLogo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sí, Salir'),
              ),
            ],
          ),
        ) ??
        false;

    if (salir && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaLogin()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool esCelular = MediaQuery.of(context).size.width < 800;
    final Key filtroKey = ValueKey(
      '$_sedeActual-$_anioActual-$_periodoActual-$_moduloActual-$_orientacionActual',
    );

    final List<Widget> pantallas = [
      PantallaAlumnos(
        key: filtroKey,
        sede: _sedeActual,
        anio: _anioActual,
        periodo: _periodoActual,
        modulo: _moduloActual,
        orientacion: _orientacionActual,
      ),
      PantallaGrupos(
        key: filtroKey,
        sede: _sedeActual,
        anio: _anioActual,
        periodo: _periodoActual,
        modulo: _moduloActual,
        orientacion: _orientacionActual,
      ),
      PantallaSeguimiento(
        key: filtroKey,
        sede: _sedeActual,
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
      if (_esSuperAdmin) const PantallaUsuariosSedes(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kNegroLogo,
        foregroundColor: Colors.white,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: LogoSistema9002(size: 36),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _esSuperAdmin
                  ? 'SVFD N° 9002 - Admin General'
                  : 'SVFD N° 9002 - Sede $_sedeActual',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Text(
              'Facilitador: ${widget.usuarioActual['nombre_completo']}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          if (_esSuperAdmin)
            _chipDropdown<String>(
              value: _sedeActual,
              items: SEDES_OFICIALES
                  .map((s) => DropdownMenuItem(value: s, child: Text('📍 $s')))
                  .toList(),
              onChanged: (v) => setState(() => _sedeActual = v!),
            )
          else if (!esCelular)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: kRojoLogo,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _sedeActual,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
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
                      esCelular && o.startsWith('Economía') ? 'Econ.' : o,
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _orientacionActual = v!),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kRojoLogo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              onPressed: _confirmarCerrarSesion,
              icon: const Icon(Icons.logout, size: 16),
              label: Text(
                esCelular ? '' : 'Salir',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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
              backgroundColor: kCarbonLogo,
              indicatorColor: kRojoLogo,
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
              selectedIconTheme: const IconThemeData(color: Colors.white),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: kRojoLogo),
                      ),
                      onPressed: _confirmarCerrarSesion,
                      icon: const Icon(Icons.logout, color: kRojoLogo),
                      label: const Text('Cerrar Sesión'),
                    ),
                  ),
                ),
              ),
              destinations: [
                const NavigationRailDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Alumnos'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.group_work_outlined),
                  selectedIcon: Icon(Icons.group_work),
                  label: Text('Grupos y Proyectos'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Seguimiento y Bot'),
                ),
                const NavigationRailDestination(
                  icon: Icon(Icons.link),
                  selectedIcon: Icon(Icons.link),
                  label: Text('Enlaces Moodle'),
                ),
                if (_esSuperAdmin)
                  const NavigationRailDestination(
                    icon: Icon(Icons.manage_accounts_outlined),
                    selectedIcon: Icon(Icons.manage_accounts),
                    label: Text('Usuarios / Sedes'),
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
              backgroundColor: kNegroLogo,
              selectedItemColor: kNaranjaLogo,
              unselectedItemColor: Colors.white60,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Alumnos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.group_work),
                  label: 'Grupos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.smart_toy),
                  label: 'Bot / Seg.',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.link),
                  label: 'Enlaces',
                ),
                if (_esSuperAdmin)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.manage_accounts),
                    label: 'Usuarios',
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
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: kCarbonLogo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          icon: const Icon(
            Icons.arrow_drop_down,
            color: kNaranjaLogo,
            size: 16,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ============================================================================
// PANTALLA 5 (SOLO ADMIN): GESTIÓN DE USUARIOS, EDICIÓN Y SUSPENSIÓN RÁPIDA
// ============================================================================
class PantallaUsuariosSedes extends StatefulWidget {
  const PantallaUsuariosSedes({super.key});

  @override
  State<PantallaUsuariosSedes> createState() => _PantallaUsuariosSedesState();
}

class _PantallaUsuariosSedesState extends State<PantallaUsuariosSedes> {
  List<dynamic> usuarios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    setState(() => cargando = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/usuarios'));
      if (res.statusCode == 200) {
        setState(() {
          usuarios = json.decode(res.body);
          cargando = false;
        });
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  Future<void> _cambiarEstadoPago(dynamic u, bool nuevoEstado) async {
    if (u['username'] == 'admin' && !nuevoEstado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No podés deshabilitar tu cuenta principal de Administrador.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final bodyData = json.encode({
        'username': u['username'],
        'password': u['password'],
        'nombre_completo': u['nombre_completo'],
        'rol': u['rol'],
        'sede': u['sede'],
        'modulos_permitidos': u['modulos_permitidos'],
        'activo': nuevoEstado,
      });

      var res = await http.put(
        Uri.parse('$baseUrl/usuarios/${u['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: bodyData,
      );

      if (res.statusCode != 200) {
        res = await http.post(
          Uri.parse('$baseUrl/usuarios'),
          headers: {'Content-Type': 'application/json'},
          body: bodyData,
        );
      }

      if (res.statusCode == 200) {
        cargarUsuarios();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                nuevoEstado
                    ? '✅ Cuenta de ${u['nombre_completo']} HABILITADA'
                    : '⛔ Cuenta de ${u['nombre_completo']} SUSPENDIDA por falta de pago',
              ),
              backgroundColor: nuevoEstado ? Colors.green : kRojoLogo,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void _abrirFormularioUsuario({dynamic usuarioExistente}) {
    bool esEdicion = usuarioExistente != null;
    TextEditingController userCtrl = TextEditingController(
      text: usuarioExistente?['username'] ?? '',
    );
    TextEditingController passCtrl = TextEditingController(
      text: usuarioExistente?['password'] ?? '',
    );
    TextEditingController nombreCtrl = TextEditingController(
      text: usuarioExistente?['nombre_completo'] ?? '',
    );

    String rol = usuarioExistente?['rol'] ?? 'facilitador';
    String sede =
        (usuarioExistente != null &&
            SEDES_OFICIALES.contains(usuarioExistente['sede']))
        ? usuarioExistente['sede']
        : 'Tartagal';
    bool activo = usuarioExistente?['activo'] ?? true;

    String modsIniciales =
        usuarioExistente?['modulos_permitidos']?.toString() ?? '6';
    List<String> modulosElegidos = modsIniciales
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => AlertDialog(
          title: Text(
            esEdicion
                ? 'Editar Facilitador: ${usuarioExistente['nombre_completo']}'
                : 'Crear Cuenta para Facilitador',
          ),
          content: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: activo ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: activo ? Colors.green : kRojoLogo,
                      ),
                    ),
                    child: SwitchListTile(
                      title: Text(
                        activo
                            ? 'CUENTA HABILITADA (Al día)'
                            : 'CUENTA DESHABILITADA (Falta de pago)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: activo ? Colors.green.shade800 : kRojoLogo,
                        ),
                      ),
                      subtitle: Text(
                        activo ? 'El usuario puede ingresar normalmente.' : 'El usuario tiene el acceso bloqueado al intentar loguearse.',
                        style: const TextStyle(fontSize: 11),
                      ),
                      value: activo,
                      activeColor: Colors.green,
                      onChanged: (usuarioExistente?['username'] == 'admin')
                          ? null
                          : (v) => setStateModal(() => activo = v),
                    ),
                  ),
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre y Apellido del Facilitador *',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: userCtrl,
                          enabled: usuarioExistente?['username'] != 'admin',
                          decoration: const InputDecoration(
                            labelText: 'Usuario de Login *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: passCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña *',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: rol,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Cuenta',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'facilitador',
                        child: Text(
                          'Facilitador de Sede (Aislado por ciudad y módulos)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text(
                          'Super Administrador (Acceso Total)',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    onChanged: (usuarioExistente?['username'] == 'admin')
                        ? null
                        : (v) => setStateModal(() => rol = v!),
                  ),
                  const SizedBox(height: 12),
                  if (rol != 'admin') ...[
                    DropdownButtonFormField<String>(
                      value: sede,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Localidad / Sede Asignada',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: SEDES_OFICIALES
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s, overflow: TextOverflow.ellipsis),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setStateModal(() => sede = v!),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Módulos Habilitados (Marcá cuáles puede ver y tocar):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['1', '2', '3', '4', '5', '6'].map((m) {
                        bool marcado = modulosElegidos.contains(m);
                        return FilterChip(
                          label: Text('Módulo $m'),
                          selected: marcado,
                          selectedColor: kRojoLogo.withOpacity(0.25),
                          onSelected: (val) {
                            setStateModal(() {
                              if (val) {
                                modulosElegidos.add(m);
                                modulosElegidos.sort();
                              } else if (modulosElegidos.length > 1) {
                                modulosElegidos.remove(m);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
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
                backgroundColor: kRojoLogo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (userCtrl.text.isEmpty ||
                    passCtrl.text.isEmpty ||
                    nombreCtrl.text.isEmpty)
                  return;
                final payload = json.encode({
                  'username': userCtrl.text.trim(),
                  'password': passCtrl.text.trim(),
                  'nombre_completo': nombreCtrl.text.trim(),
                  'rol': rol,
                  'sede': rol == 'admin' ? 'TODAS' : sede,
                  'modulos_permitidos': rol == 'admin'
                      ? '1,2,3,4,5,6'
                      : modulosElegidos.join(','),
                  'activo': activo,
                });

                if (esEdicion) {
                  var res = await http.put(
                    Uri.parse('$baseUrl/usuarios/${usuarioExistente['id']}'),
                    headers: {'Content-Type': 'application/json'},
                    body: payload,
                  );
                  if (res.statusCode != 200) {
                    await http.post(
                      Uri.parse('$baseUrl/usuarios'),
                      headers: {'Content-Type': 'application/json'},
                      body: payload,
                    );
                  }
                } else {
                  await http.post(
                    Uri.parse('$baseUrl/usuarios'),
                    headers: {'Content-Type': 'application/json'},
                    body: payload,
                  );
                }

                if (mounted) Navigator.pop(ctx);
                cargarUsuarios();
              },
              icon: const Icon(Icons.save),
              label: Text(esEdicion ? 'Guardar Cambios' : 'Crear Usuario'),
            ),
          ],
        ),
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
              const Text(
                'Control de Alquileres, Sedes y Usuarios',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNegroLogo,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRojoLogo,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _abrirFormularioUsuario(),
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo Facilitador / Sede'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '💡 Hacé clic sobre cualquier usuario para editar sus datos/módulos, o usá el interruptor de la derecha para deshabilitarlo al instante si no abonó.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: cargando
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final u = usuarios[index];
                      bool activo = u['activo'] ?? true;
                      bool esAdminPpal = u['username'] == 'admin';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: activo ? Colors.transparent : kRojoLogo,
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () =>
                              _abrirFormularioUsuario(usuarioExistente: u),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: activo
                                      ? kNegroLogo
                                      : kRojoLogo,
                                  child: Icon(
                                    u['rol'] == 'admin'
                                        ? Icons.security
                                        : Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              u['nombre_completo'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                decoration: activo
                                                    ? null
                                                    : TextDecoration
                                                          .lineThrough,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: activo
                                                  ? Colors.green.shade100
                                                  : Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              activo
                                                  ? 'ACTIVO'
                                                  : 'SUSPENDIDO (SIN PAGO)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: activo
                                                    ? Colors.green.shade900
                                                    : Colors.red.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Usuario: ${u['username']}   |   Clave: ${u['password']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Text(
                                            '📍 Sede: ${u['sede']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: kRojoLogo,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '📚 Módulos: ${u['modulos_permitidos']}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: activo,
                                      activeColor: Colors.green,
                                      inactiveThumbColor: kRojoLogo,
                                      onChanged: esAdminPpal
                                          ? null
                                          : (val) => _cambiarEstadoPago(u, val),
                                    ),
                                    Text(
                                      activo ? 'Habilitado' : 'Bloqueado',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: activo
                                            ? Colors.green.shade700
                                            : kRojoLogo,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Editar Usuario',
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: kNegroLogo,
                                  ),
                                  onPressed: () => _abrirFormularioUsuario(
                                    usuarioExistente: u,
                                  ),
                                ),
                                if (!esAdminPpal)
                                  IconButton(
                                    tooltip: 'Eliminar Cuenta',
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: kRojoLogo,
                                    ),
                                    onPressed: () async {
                                      bool conf =
                                          await showDialog(
                                            context: context,
                                            builder: (c) => AlertDialog(
                                              title: const Text(
                                                'Eliminar Usuario',
                                              ),
                                              content: Text(
                                                '¿Seguro que querés eliminar la cuenta de ${u['nombre_completo']}?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(c, false),
                                                  child: const Text('Cancelar'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            kRojoLogo,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                  onPressed: () =>
                                                      Navigator.pop(c, true),
                                                  child: const Text('Eliminar'),
                                                ),
                                              ],
                                            ),
                                          ) ??
                                          false;
                                      if (conf) {
                                        await http.delete(
                                          Uri.parse(
                                            '$baseUrl/usuarios/${u['id']}',
                                          ),
                                        );
                                        cargarUsuarios();
                                      }
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
}

// ============================================================================
// PANTALLA 1: ALUMNOS (CON PDF HORIZONTAL Y NOMBRES VISIBLES)
// ============================================================================
class PantallaAlumnos extends StatefulWidget {
  final String sede;
  final int anio;
  final String periodo;
  final int modulo;
  final String orientacion;
  const PantallaAlumnos({
    super.key,
    required this.sede,
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
        '$baseUrl/alumnos_cursada?sede=${Uri.encodeComponent(widget.sede)}&modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
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
                      color: kNegroLogo,
                    ),
                  ),
                  Text(
                    'Sede: ${widget.sede} | DNI: ${alumno['dni']} | ${widget.anio} (${widget.periodo})',
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
                                  color: kRojoLogo,
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
                      if (debeModulosAnteriores)
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
                      const Divider(height: 24),
                      SwitchListTile(
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
                              ? 'Cumple todo para egresar.'
                              : 'Requiere aprobar Mód. 6 y no deber módulos.',
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: egresado,
                        activeColor: Colors.teal,
                        onChanged: (v) => setStateDialog(() => egresado = v),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Historial de Períodos Cursados:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: kNegroLogo,
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
                                  '${h['anio']} (${h['periodo']}) - Mód. ${h['numero_modulo']} [${h['sede']}]',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${h['condicion']}',
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

  // EXPORTAR PDF DE CONDICIÓN EN HOJA A4 HORIZONTAL (LANDSCAPE) CON NOMBRES CLAROS
  Future<void> _exportarListadoPDF(String condicionFiltro) async {
    List<dynamic> filtrados = alumnos.where((a) {
      if (condicionFiltro == 'Todos') return true;
      if (condicionFiltro == 'Egresados') return a['egresado'] == true;
      return (a['condicion'] ?? 'Cursando') == condicionFiltro;
    }).toList();

    final pdf = pw.Document();
    final formatoHorizontal = PdfPageFormat.a4.landscape;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: formatoHorizontal,
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(24),
        ),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SISTEMA VIRTUAL N° 9002 - SEDE ${widget.sede.toUpperCase()}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Nómina de Alumnos (${condicionFiltro.toUpperCase()}) | Año: ${widget.anio} - ${widget.periodo} | Módulo ${widget.modulo} (${widget.orientacion})',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                pw.Text(
                  'Total: ${filtrados.length}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: [
              'N°',
              'Apellido y Nombre del Alumno',
              'DNI',
              'Condición',
              'Módulos Adeudados',
              'Observaciones / Estado',
            ],
            data: List.generate(filtrados.length, (i) {
              final a = filtrados[i];
              String obs = '';
              if (a['egresado'] == true) obs = 'EGRESADO. ';
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
                '${i + 1}',
                (a['nombre_completo'] ?? '').toString(),
                (a['dni'] ?? '').toString(),
                (a['condicion'] ?? 'Cursando').toString(),
                (a['modulos_adeudados']?.toString().isNotEmpty ?? false)
                    ? 'Mód: ${a['modulos_adeudados']}'
                    : 'Ninguno',
                obs,
              ];
            }),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFD32F2F),
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 9.5,
              color: PdfColors.black,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(3.0),
              2: const pw.FlexColumnWidth(1.2),
              3: const pw.FlexColumnWidth(1.3),
              4: const pw.FlexColumnWidth(1.5),
              5: const pw.FlexColumnWidth(2.5),
            },
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
      format: formatoHorizontal,
      onLayout: (_) async => pdf.save(),
      name: 'Nomina_${widget.sede}_${condicionFiltro}.pdf',
    );
  }

  void _mostrarMenuExportarPDF() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Exportar PDF Horizontal (${widget.sede})'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Promocionado', 'Regular', 'Libre', 'Egresados', 'Todos']
              .map(
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
              )
              .toList(),
        ),
      ),
    );
  }

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
            if (modoSeleccion == 'RecursantesConNota')
              return a['condicion'] == 'Libre' &&
                  a['presento_nota_recursar'] == true;
            return (a['condicion'] == 'Promocionado' ||
                    a['condicion'] == 'Regular') &&
                a['egresado'] != true;
          }).toList();

          return AlertDialog(
            title: Text('Fin de Período - Sede ${widget.sede}'),
            content: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RadioListTile<String>(
                      title: const Text(
                        'Libres con Nota presentada (Recursan el mismo módulo)',
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
                        'Promocionados / Regulares (Avanzan al módulo siguiente)',
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
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: 110,
                          child: DropdownButtonFormField<int>(
                            value: anioDestino,
                            isExpanded: true,
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
                            isExpanded: true,
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
                            isExpanded: true,
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
                      'Alumnos seleccionados (${candidatos.length}):',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
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
                  backgroundColor: kRojoLogo,
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
                            'sede': widget.sede,
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
          'sede': widget.sede,
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
        title: Text('Carga Masiva - ${widget.sede}'),
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
                    backgroundColor: kNegroLogo,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    ClipboardData? data = await Clipboard.getData(
                      Clipboard.kTextPlain,
                    );
                    if (data?.text != null) textoMasivoCtrl.text = data!.text!;
                  },
                  icon: const Icon(Icons.content_paste),
                  label: const Text(
                    'Pegar Lista desde el Portapapeles (Excel / Word / PDF)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: textoMasivoCtrl,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'PEREZ JUAN; 40111222; 40111222',
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
        title: Text('Agregar Alumno en ${widget.sede}'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: kRojoLogo,
              foregroundColor: Colors.white,
            ),
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
                  'sede': widget.sede,
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
              style: ElevatedButton.styleFrom(
                backgroundColor: kNegroLogo,
                foregroundColor: Colors.white,
              ),
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
                          'Se deja constancia de que ${alumno['nombre_completo']} (DNI N° ${alumno['dni']}) cursa en la Sede ${widget.sede} el Módulo ${widget.modulo} (${widget.orientacion}) durante el ciclo ${widget.anio} (${widget.periodo}).',
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
    if (cond == 'Libre') return kRojoLogo;
    if (cond == 'Egresados') return Colors.teal.shade700;
    return kCarbonLogo;
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
                'Alumnos [${widget.sede}] - Mód. ${widget.modulo}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNegroLogo,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRojoLogo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _mostrarDialogoNuevoAlumno,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Agregar 1'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNegroLogo,
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
                        selectedColor: kRojoLogo.withOpacity(0.2),
                        onSelected: (_) => setState(() => _filtroCondicion = f),
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          cargando
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : alumnosMostrados.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      'No hay alumnos cargados en la sede ${widget.sede} para este filtro.',
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
                                                  : kRojoLogo,
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
                                    color: kNegroLogo,
                                  ),
                                  onPressed: () => _mostrarFichaLegajo(al),
                                ),
                                IconButton(
                                  tooltip: 'Quitar de este período',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: kRojoLogo,
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
// PANTALLA 2: GRUPOS Y PROYECTOS (SIN OVERFLOW HORIZONTAL)
// ============================================================================
class PantallaGrupos extends StatefulWidget {
  final String sede;
  final int anio;
  final String periodo;
  final int modulo;
  final String orientacion;
  const PantallaGrupos({
    super.key,
    required this.sede,
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
          '$baseUrl/alumnos_cursada?sede=${Uri.encodeComponent(widget.sede)}&modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
        ),
      );
      final resGr = await http.get(
        Uri.parse(
          '$baseUrl/grupos?sede=${Uri.encodeComponent(widget.sede)}&modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
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
        title: Text('Crear Grupo en ${widget.sede}'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: kRojoLogo,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (nombreCtrl.text.isEmpty) return;
              Navigator.pop(context);
              await http.post(
                Uri.parse('$baseUrl/grupos'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'sede': widget.sede,
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
                Flexible(
                  child: Text(
                    'Administrar: ${grupoActualizado['nombre_grupo']}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: kRojoLogo),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kNegroLogo,
                            foregroundColor: Colors.white,
                          ),
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
                          icon: const Icon(Icons.close, color: kRojoLogo),
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
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            value: i1,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Instancia 1',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: opcionesNota
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(
                                      o,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => i1 = v!),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            value: i2,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Instancia 2',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: opcionesNota
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(
                                      o,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => i2 = v!),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            value: i3,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Instancia 3',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: opcionesNota
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(
                                      o,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => i3 = v!),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            value: iRec,
                            isExpanded: true,
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
                                        child: Text(
                                          o,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) => setStateDialog(() => iRec = v!),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            value: def,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Defensa Final',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: ['Pendiente', 'Aprobado', 'Desaprobado']
                                .map(
                                  (o) => DropdownMenuItem(
                                    value: o,
                                    child: Text(
                                      o,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setStateDialog(() => def = v!),
                          ),
                        ),
                        SizedBox(
                          width: 170,
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
                'Grupos [${widget.sede}] - Mód. ${widget.modulo}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNegroLogo,
                ),
              ),
              ElevatedButton.icon(
                onPressed: mostrarDialogoCrearGrupo,
                icon: const Icon(Icons.add),
                label: const Text('Crear Grupo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRojoLogo,
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
                ? Center(
                    child: Text(
                      'No hay grupos creados en la sede ${widget.sede}.',
                    ),
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kNegroLogo,
                                    foregroundColor: Colors.white,
                                  ),
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
// PANTALLA 3: SEGUIMIENTO, PLANILLA SEMANAL, PDF HORIZONTAL Y EXPORTACIÓN A WORD
// ============================================================================
class PantallaSeguimiento extends StatefulWidget {
  final String sede;
  final int anio;
  final String periodo;
  final int modulo;
  final String orientacion;
  const PantallaSeguimiento({
    super.key,
    required this.sede,
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
  bool _verComoPlanilla = false;
  Timer? _timerEstado;

  final List<String> _semanasOrden = [
    'S02',
    'S03',
    'S04',
    'S07',
    'S08',
    'S11',
    'S12',
    'Evaluaciones',
  ];

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
          '$baseUrl/alumnos_cursada?sede=${Uri.encodeComponent(widget.sede)}&modulo=${widget.modulo}&orientacion=${Uri.encodeComponent(widget.orientacion)}&anio=${widget.anio}&periodo=${Uri.encodeComponent(widget.periodo)}',
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

  String _obtenerEstadoSemana(dynamic alumnoCursada, String codigoSemana) {
    final segRaw = alumnoCursada['seguimiento_semanal'];
    if (segRaw == null) return '-';

    Map<String, dynamic> segMap = {};
    if (segRaw is String && segRaw.isNotEmpty) {
      try {
        segMap = json.decode(segRaw);
      } catch (_) {}
    } else if (segRaw is Map) {
      segMap = Map<String, dynamic>.from(segRaw);
    }

    if (!segMap.containsKey(codigoSemana)) return '-';
    final datosSem = segMap[codigoSemana];
    if (datosSem is! Map) return '-';

    List completas = (datosSem['completas'] as List?) ?? [];
    List faltan = (datosSem['faltan'] as List?) ?? [];

    if (completas.isEmpty && faltan.isEmpty) return '-';
    if (faltan.isEmpty) return 'COMPLETA';
    if (completas.isEmpty) return 'No realizó';
    return 'Debe: ${faltan.join(", ")}';
  }

  // 1. EXPORTAR PDF EN HOJA A4 HORIZONTAL (LANDSCAPE) CON NOMBRES VISIBLES
  Future<void> _exportarPlanillaSeguimientoPDF() async {
    final pdf = pw.Document();
    final formatoHorizontal = PdfPageFormat.a4.landscape;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: formatoHorizontal,
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(18),
        ),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SISTEMA VIRTUAL N° 9002 - PLANILLA DE SEGUIMIENTO MOODLE',
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Sede: ${widget.sede} | Módulo ${widget.modulo} (${widget.orientacion}) | ${widget.anio} - ${widget.periodo}',
                      style: const pw.TextStyle(fontSize: 10.5),
                    ),
                  ],
                ),
                pw.Text(
                  'Total Alumnos: ${cursadas.length}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: [
              'N°',
              'Apellido y Nombre del Alumno',
              'DNI',
              'Sem. 2',
              'Sem. 3',
              'Sem. 4',
              'Sem. 7',
              'Sem. 8',
              'Sem. 11',
              'Sem. 12',
              'Eval.',
            ],
            data: List.generate(cursadas.length, (index) {
              final c = cursadas[index];
              final nombreAlumno = (c['nombre_completo'] ?? 'Sin Nombre')
                  .toString();
              final dniAlumno = (c['dni'] ?? '').toString();
              return [
                '${index + 1}',
                nombreAlumno,
                dniAlumno,
                ..._semanasOrden.map((sem) => _obtenerEstadoSemana(c, sem)),
              ];
            }),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 8.5,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFD32F2F),
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 7.5,
              color: PdfColors.black,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            columnWidths: {
              0: const pw.FlexColumnWidth(0.5),
              1: const pw.FlexColumnWidth(2.6),
              2: const pw.FlexColumnWidth(1.1),
              3: const pw.FlexColumnWidth(1.1),
              4: const pw.FlexColumnWidth(1.1),
              5: const pw.FlexColumnWidth(1.1),
              6: const pw.FlexColumnWidth(1.1),
              7: const pw.FlexColumnWidth(1.1),
              8: const pw.FlexColumnWidth(1.1),
              9: const pw.FlexColumnWidth(1.1),
              10: const pw.FlexColumnWidth(1.1),
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      format: formatoHorizontal,
      onLayout: (_) async => pdf.save(),
      name: 'Planilla_Seguimiento_${widget.sede}_Mod${widget.modulo}.pdf',
    );
  }

  // 2. EXPORTAR COMO ARCHIVO WORD (.DOC) DIRECTO (CON TABLA HORIZONTAL Y NOMBRES)
  Future<void> _exportarPlanillaWord() async {
    StringBuffer filasHtml = StringBuffer();
    for (int i = 0; i < cursadas.length; i++) {
      final c = cursadas[i];
      final nombre = (c['nombre_completo'] ?? '').toString();
      final dni = (c['dni'] ?? '').toString();
      filasHtml.write('<tr>');
      filasHtml.write(
        '<td style="border:1px solid #333; padding:5px; text-align:center;">${i + 1}</td>',
      );
      filasHtml.write(
        '<td style="border:1px solid #333; padding:5px; font-weight:bold;">$nombre</td>',
      );
      filasHtml.write(
        '<td style="border:1px solid #333; padding:5px;">$dni</td>',
      );
      for (final sem in _semanasOrden) {
        final est = _obtenerEstadoSemana(c, sem);
        String bg = '#FFFFFF';
        if (est == 'COMPLETA')
          bg = '#E8F5E9';
        else if (est.startsWith('Debe:'))
          bg = '#FFF3E0';
        else if (est == 'No realizó')
          bg = '#FFEBEE';
        filasHtml.write(
          '<td style="border:1px solid #333; padding:5px; background-color:$bg; font-size:9pt;">$est</td>',
        );
      }
      filasHtml.write('</tr>');
    }

    String docWord =
        '''
<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
<head>
<meta charset="utf-8">
<title>Seguimiento Moodle</title>
<style>
  @page Section1 { size: 841.9pt 595.3pt; mso-page-orientation: landscape; margin: 1.5cm; }
  div.Section1 { page: Section1; }
  body { font-family: Arial, sans-serif; }
  table { border-collapse: collapse; width: 100%; }
</style>
</head>
<body>
<div class="Section1">
  <h2 style="color:#D32F2F; margin-bottom:2px;">SISTEMA VIRTUAL DE FORMACIÓN A DISTANCIA N° 9002</h2>
  <p style="margin-top:0; font-size:11pt;"><b>Sede:</b> ${widget.sede} &nbsp;|&nbsp; <b>Módulo:</b> ${widget.modulo} (${widget.orientacion}) &nbsp;|&nbsp; <b>Ciclo:</b> ${widget.anio} - ${widget.periodo}</p>
  <table>
    <thead>
      <tr style="background-color:#141414; color:#FFFFFF; font-weight:bold; font-size:9.5pt;">
        <th style="border:1px solid #333; padding:6px;">N°</th>
        <th style="border:1px solid #333; padding:6px;">Apellido y Nombre</th>
        <th style="border:1px solid #333; padding:6px;">DNI</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 2</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 3</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 4</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 7</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 8</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 11</th>
        <th style="border:1px solid #333; padding:6px;">Sem. 12</th>
        <th style="border:1px solid #333; padding:6px;">Eval.</th>
      </tr>
    </thead>
    <tbody>
      ${filasHtml.toString()}
    </tbody>
  </table>
</div>
</body>
</html>
''';

    final bytes = Uint8List.fromList(utf8.encode(docWord));
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Seguimiento_${widget.sede}_Mod${widget.modulo}.doc',
    );
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
            title: Text('Bot Moodle - Sede ${widget.sede}'),
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
                        if (v == true)
                          seleccionados = cursadas
                              .map<int>((c) => c['cursada_id'] as int)
                              .toSet();
                        else
                          seleccionados.clear();
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
                  'Destrabar Bot',
                  style: TextStyle(color: kRojoLogo),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRojoLogo,
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
          'sede': widget.sede,
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
          progresoBot = 'Iniciando seguimiento en ${widget.sede}...';
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
        "Seguimiento Sede ${widget.sede} - Mód. ${widget.modulo} (${widget.orientacion}):\n\n";
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

  Widget _construirVistaPlanilla() {
    return Card(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(kNegroLogo),
            headingTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            columnSpacing: 18,
            columns: const [
              DataColumn(label: Text('Apellido y Nombre')),
              DataColumn(label: Text('Semana 2')),
              DataColumn(label: Text('Semana 3')),
              DataColumn(label: Text('Semana 4')),
              DataColumn(label: Text('Semana 7')),
              DataColumn(label: Text('Semana 8')),
              DataColumn(label: Text('Semana 11')),
              DataColumn(label: Text('Semana 12')),
              DataColumn(label: Text('Evaluaciones')),
            ],
            rows: cursadas.map((c) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      c['nombre_completo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ..._semanasOrden.map((sem) {
                    String est = _obtenerEstadoSemana(c, sem);
                    Color colorTexto = Colors.black87;
                    Color colorFondo = Colors.transparent;
                    if (est == 'COMPLETA') {
                      colorTexto = Colors.green.shade800;
                      colorFondo = Colors.green.shade50;
                    } else if (est.startsWith('Debe:')) {
                      colorTexto = Colors.orange.shade900;
                      colorFondo = Colors.orange.shade50;
                    } else if (est == 'No realizó') {
                      colorTexto = kRojoLogo;
                      colorFondo = Colors.red.shade50;
                    }
                    return DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorFondo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          est,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorTexto,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
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
                'Seguimiento [${widget.sede}] - Mód. ${widget.modulo}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kNegroLogo,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    onPressed: _abrirSelectorAlumnosBot,
                    icon: const Icon(Icons.smart_toy, size: 18),
                    label: Text(
                      botEjecutando ? 'Bot Activo' : 'Sincronizar Moodle',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kRojoLogo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => _verComoPlanilla = !_verComoPlanilla),
                    icon: Icon(
                      _verComoPlanilla ? Icons.view_agenda : Icons.table_chart,
                      size: 18,
                    ),
                    label: Text(
                      _verComoPlanilla ? 'Ver Tarjetas' : 'Ver Planilla',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNegroLogo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportarPlanillaSeguimientoPDF,
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('PDF Horizontal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportarPlanillaWord,
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Exportar Word'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: copiarParaWhatsApp,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copiar WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
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
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kRojoLogo),
              ),
              child: Row(
                children: [
                  if (botEjecutando)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kRojoLogo,
                      ),
                    ),
                  if (botEjecutando) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      progresoBot,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kRojoLogo,
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
                        style: TextStyle(color: kRojoLogo),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: cargarSeguimiento,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          cargando
              ? const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              : Expanded(
                  child: _verComoPlanilla
                      ? _construirVistaPlanilla()
                      : ListView.builder(
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                    color: kRojoLogo,
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
              color: kNegroLogo,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kNegroLogo,
                      foregroundColor: Colors.white,
                    ),
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
                          isExpanded: true,
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
                          isExpanded: true,
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
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          value: _tipoActividadSeleccionada,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Tipo Actividad',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _tiposActividad
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    t,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
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
                          backgroundColor: kRojoLogo,
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
                            icon: const Icon(Icons.delete, color: kRojoLogo),
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
