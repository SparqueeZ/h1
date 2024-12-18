import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../models/promotion.dart';
import '../models/user.dart';

class HomePageEleve extends StatefulWidget {
  const HomePageEleve({super.key});

  @override
  State<HomePageEleve> createState() => _HomePageEleveState();
}

class _HomePageEleveState extends State<HomePageEleve> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? userFirstName;
  String? userLastName;
  List<Promotion>? userPromotions;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Ouvrir la boîte Hive
      final userBox = await Hive.openBox('userBox');

      // Récupérer l'utilisateur
      final user = userBox.get('user') as User?;

      // Récupérer les promotions
      final promotions = userBox.get('promotions') as List<Promotion>?;

      // Mettre à jour l'état avec les données récupérées
      if (user != null) {
        setState(() {
          userFirstName = user.firstname;
          userLastName = user.lastname;
          userPromotions = promotions;
        });
      }
    } catch (e) {
      _showErrorDialog('Erreur lors du chargement : $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String initials = "${userFirstName?[0] ?? ''}${userLastName?[0] ?? ''}".toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.teal,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bonjour ${userFirstName ?? 'Utilisateur'}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Bienvenue sur h1',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              if (userPromotions != null && userPromotions!.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: userPromotions!.length,
                    itemBuilder: (context, index) {
                      final promotion = userPromotions![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: const Icon(Icons.school, color: Colors.teal),
                          title: Text(
                            promotion.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'Année : ${promotion.year}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Aucune promotion trouvée.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
