// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// ignore_for_file: avoid_print

// Package qui permet de faire du material design sur les app
import 'package:flutter/material.dart';

// Permet d'avoir des fonctions asynchrones
import 'dart:async';
import 'dart:io';

// Permet de gérer la caméra
import 'package:camera/camera.dart';
// Permet d'utiliser la base de donées Hive, recommandée par pas mal de monde sous Flutter
import 'package:hive_flutter/hive_flutter.dart';

// Notre modèle de données dans cette base de donnée (cf fichier correspondant)
import 'inspection_photo.dart';

// Pour générer des uuid
import 'package:uuid/uuid.dart';
// Pour travailler avec les chemin de fichier
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Pour avoir des logs
import 'dart:developer';

// Tout code flutter doit avoir une fonction main, c'est la fonction executée au lancement du code
// (comme en C)
Future<void> main() async {
  // On initialise notre base de données
  await Hive.initFlutter();

  // On notifie notre base de données de notre modèle de données
  Hive.registerAdapter(InspectionPhotoAdapter());

  // On ouvre la collection qui va stocker nos objets.
  // Notez qu'elle stocke les objets typés, ce qui est bien pratique
  // Entre parenthèse c'est le nom de la "collection"
  var box = await Hive.openBox<InspectionPhoto>('inspectionPhotoBox');

  // Permet de supprimer toutes les entrées de la db
  //box.clear();

  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  // On lance l'app
  runApp(MyApp(camera: firstCamera, box: box));
}

// La classe principale de l'app. En fait dans Flutter, tout est Widget, l'app est donc logiquement un widget...
// ... qui va appeler des sous-widget, etc.
// Il y a deux types de widget, les StatelessWidget qui ne changent jamais et les StateFul widget qui peuvent
// avoir un état propre.
class MyApp extends StatelessWidget {
  // C'sest comme ça qu'on déclare en dart le constructeur de la classe, qui a donc deux champs obligatoires
  const MyApp({super.key, required this.camera, required this.box});

  // Et bien sur on doit déclarer ces champs
  final Box<InspectionPhoto> box;
  final CameraDescription camera;

  // Override est un élément de Dart qui indique qu'on va changer la définition d'une fonction
  // Héritée
  @override
  // Finalement on fait notre widget via la fonction build
  Widget build(BuildContext context) {
    // J'aiaps très bien compris ce qu'est le widget "MaterialApp" sinon qu'il permet
    // de faire des app qui respectent le Material Design (logique de Design d'Android)
    //
    // Les widget ont a chaque fois plein d'arguments.
    // En particulier ici on a l'argument "Home" qui est la zone principale du widget
    // où l'on met un nouveau widget "HomePage2"
    return MaterialApp(
        title: 'Mimia Prototype',
        home: HomePage2(camera: this.camera, box: this.box));
  }
}

// HomePage2 va être notre widget qui reçoit la liste d'éléments
// Ici c'est un widget Stateful mais je suis pas certain que ce soit utile au final,
// à tester...
// En tout cas ça permet de montrer les widgets Stateful qui ont systématiquement
// Une classe de state associée
class HomePage2 extends StatefulWidget {
  const HomePage2({super.key, required this.camera, required this.box});
  final CameraDescription camera;
  final Box<InspectionPhoto> box;

  @override
  _HomePage2State createState() => _HomePage2State();
}

// Voici la famuse classe de state
class _HomePage2State extends State<HomePage2> {
  // Ici on récupère la collection dont on va avoir besoin
  final Box<InspectionPhoto> _inspectioPhotoBox =
      Hive.box('inspectionPhotoBox');

  // Et on construit notre nouveau widget
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Mimia Prototype'),
        ),
        body: Center(
            // ici on utilise le widget "ValueListenableBuilder", il permet de construire un widget qui
            // sera rechargé si jamais le listener concerné change (ici la mise a jour de notre db)
            child: ValueListenableBuilder(
          valueListenable: // comme précisé on écoute notre chère db
              Hive.box<InspectionPhoto>('inspectionPhotoBox').listenable(),
          builder: (context, Box<InspectionPhoto> _inspectionsPhotoBox, _) {
            // Puis finalement on construit le widget
            return ListView.builder(
                // Ici on va faire une list d'où la "ListView"
                padding:
                    const EdgeInsets.all(16.0), // Je sais pas a quoi ça sert
                itemCount: 2 * _inspectionsPhotoBox.values.length,
                itemBuilder: (context, i) {
                  // Indique comment on va constuire les éléments de la liste
                  if (i.isOdd)
                    return const Divider(); // Met une barre entre les différents items

                  final index = i ~/ 2;
                  final item = _inspectionsPhotoBox
                      .getAt(index); // Récupère l'élément à afficher

                  return ListTile(
                    // L'affiche
                    leading: ConstrainedBox(
                      // Grace au "leading" on peut afficher un truc au début de la liste, ici une image
                      constraints: BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                        maxWidth: 64,
                        maxHeight: 64,
                      ),
                      child: Image.file(File(item!.path), fit: BoxFit.cover),
                    ),
                    title: Text(
                      // Et on met un texte dans la zone principale de la liste
                      item!.path,
                    ),
                  );
                });
          },
        )),
        floatingActionButton: FloatingActionButton(
          // Enfin on va pouvir ajouter un bouton, ici on ajoute un "flaoting button" en bas à gauche comme c'est souvent fait sous android
          child: const Icon(Icons.camera_alt),
          onPressed: (() {
            // Et on indique ce qui se passe quand on appuie dessus
            Navigator.push(
              // Ici quand on appuie desus on va dans la page suivante (le navigator permet de se souvenir de l'arbre de navigation)
              context,
              MaterialPageRoute(
                builder: (context) => TakePictureScreen(
                  // Pass the appropriate camera to the TakePictureScreen widget.
                  camera: widget.camera,
                  box: _inspectioPhotoBox,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Ici c'est l'écran qui va afficher la camera et va permettre de prendre une photo, c'est principalement un copier-coller
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera, required this.box});

  final CameraDescription camera;
  final Box<InspectionPhoto> box;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    imagePath: image.path,
                    box: widget.box),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// Ca c'est l'écran ou on va afficher la capture pour confirmer, c'est un copier coller
// sauf la partie du bouton de confirmation
// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final Box<InspectionPhoto> box;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.box});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(imagePath)),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // Lors de la confirmation on commence par récupérer le path de sauvegarde
            final String path = (await getApplicationDocumentsDirectory()).path;
            // on crée une id
            final String uuid = Uuid().v4();
            // On détermine où on va sauvegarder
            final String newPath = '$path/$uuid${p.extension(imagePath)}';
            // Et on sauvegarde notre image (jusqu'alors elle était dans le cache)
            File newImage = await File(imagePath).copy(newPath);
            // Enfin on met a jour la db
            box.add(InspectionPhoto(newPath));

            // Pour finir on revient deux écran en arrière
            // C'est assez dégueu a priori de faire comme ça et Flutter propose mieux
            // Mais j'ai pas eu le temps de le mettre en place
            int count = 0;
            Navigator.of(context).popUntil((_) => count++ >= 2);
          },
          child: const Icon(Icons.check_outlined)),
    );
  }
}
