import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  static const _primary = Color(0xFF1A1F36);
  static const _accent  = Color(0xFF4F6EF7);
  static const _success = Color(0xFF00C48C);
  static const _bg      = Color(0xFFF4F6FC);
  static const _surface = Color(0xFFFFFFFF);
  static const _textSub = Color(0xFF8A94A6);
  static const _navy    = Color(0xFF003087);

  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _rates;
  DateTime? _lastUpdated;

  // Currencies to display
  final List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar',        'flag': '🇺🇸'},
    {'code': 'EUR', 'name': 'Euro',              'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound',    'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen',     'flag': '🇯🇵'},
    {'code': 'AED', 'name': 'UAE Dirham',       'flag': '🇦🇪'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'flag': '🇸🇬'},
    {'code': 'CAD', 'name': 'Canadian Dollar',  'flag': '🇨🇦'},
    {'code': 'AUD', 'name': 'Australian Dollar','flag': '🇦🇺'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      // Free API — no key required
      final uri = Uri.parse(
          'https://api.frankfurter.app/latest?from=INR');
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rates       = data['rates'];
          _lastUpdated = DateTime.now();
          _loading     = false;
        });
      } else {
        setState(() {
          _error   = 'Failed to fetch rates. Try again.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error   = 'No internet connection.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        foregroundColor: _primary,
        centerTitle: true,
        title: const Text('Currency Rates',
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loading ? null : _fetchRates,
            color: _accent,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header Card ──────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_navy, Color(0xFF1A4A9F)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: _navy.withOpacity(.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('🇮🇳',
                        style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text('Indian Rupee (INR)',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13)),
                        const Text('₹ 1.00',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: _success),
                        const SizedBox(width: 6),
                        Text(
                          _lastUpdated != null
                              ? 'Updated ${_fmtTime(_lastUpdated!)}'
                              : 'Live Exchange Rates',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── API Info Banner ───────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _accent.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _accent.withOpacity(.2)),
              ),
              child: Row(children: [
                const Icon(Icons.api_rounded,
                    color: _accent, size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Data fetched live from frankfurter.app (REST API)',
                    style: TextStyle(
                        fontSize: 12,
                        color: _accent,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 20),

            // ── Rates ─────────────────────────────────────
            const Text('1 INR equals',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _primary)),

            const SizedBox(height: 12),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                      color: _accent),
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 40, color: _textSub),
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(
                          color: _textSub, fontSize: 14),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12)),
                    ),
                    onPressed: _fetchRates,
                    icon: const Icon(Icons.refresh_rounded,
                        size: 18),
                    label: const Text('Retry'),
                  ),
                ]),
              )
            else if (_rates != null)
              Container(
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: _primary.withOpacity(.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  children: _currencies.asMap().entries.map((e) {
                    final idx = e.key;
                    final c   = e.value;
                    final rate = _rates![c['code']];

                    if (rate == null) return const SizedBox();

                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(children: [
                          // Flag + Code
                          Text(c['flag']!,
                              style:
                                  const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(c['code']!,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                        fontSize: 14,
                                        color: _primary)),
                                Text(c['name']!,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: _textSub)),
                              ],
                            ),
                          ),
                          // Rate value
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              Text(
                                rate is double
                                    ? rate.toStringAsFixed(4)
                                    : rate.toString(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _accent),
                              ),
                              Text(c['code']!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _textSub)),
                            ],
                          ),
                        ]),
                      ),
                      if (idx < _currencies.length - 1)
                        const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16),
                    ]);
                  }).toList(),
                ),
              ),

            const SizedBox(height: 20),

            // ── Footer ───────────────────────────────────
            Center(
              child: Text(
                'Rates are indicative and may vary',
                style: TextStyle(
                    fontSize: 11,
                    color: _textSub.withOpacity(.6)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime d) {
    final h   = d.hour > 12 ? d.hour - 12 : d.hour;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM'
    return '$h:$min $ampm';
  }
}