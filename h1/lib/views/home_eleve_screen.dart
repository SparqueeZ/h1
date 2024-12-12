import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class HomePageEleve extends StatefulWidget {
  const HomePageEleve({super.key});

  @override
  State<HomePageEleve> createState() => _HomePageEleveState();
}

class _HomePageEleveState extends State<HomePageEleve> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? userFirstName;
  String? userLastName;
  List<Map<String, dynamic>> courses = []; // Liste des cours récupérés

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Charger les données utilisateur et cours
  Future<void> _loadData() async {
    try {
      // Récupération du token
      String? token = await secureStorage.read(key: 'auth_token');

      if (token != null) {
        final userBox = await Hive.openBox('users');
        final user = userBox.values.cast<Map>().firstWhere(
              (user) => user['token'] == token,
          orElse: () => {},
        );

        if (user.isNotEmpty) {
          setState(() {
            userFirstName = user['first_name'];
            userLastName = user['last_name'];
            courses = List<Map<String, dynamic>>.from(user['courses'] ?? []);
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Erreur lors du chargement : $e');
    }
  }

  // Méthode pour afficher un message d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Fermer'),
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
              // Rond avec les initiales de l'utilisateur
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.teal,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Bonjour ${userFirstName ?? 'Utilisateur'}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                'Bienvenue sur h1',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),

              // Boutons "Mes cours" et "Ma promotion"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Action pour "Mes cours"
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Mes cours'),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Action pour "Ma promotion"
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.teal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Ma promotion',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Liste des cours
              Expanded(
                child: ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      color: Colors.grey[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        title: Text(
                          course['nom_du_cours'] ?? 'Cours inconnu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course['nom_du_prof'] ?? 'Professeur inconnu'),
                            Text('Salle ${course['numero_de_la_salle'] ?? ''}'),
                          ],
                        ),
                        trailing: Text(
                          '${course['h_debut']} - ${course['h_fin']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Navigation bar en bas
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(Icons.home, color: Colors.teal),
                      onPressed: () {
                        // Action Accueil
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.teal),
                      onPressed: () {
                        // Action Calendrier
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications, color: Colors.teal),
                      onPressed: () {
                        // Action Notifications
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: Colors.teal),
                      onPressed: () {
                        // Action Paramètres
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
