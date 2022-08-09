## Prerequis

Pour faire fonctionner tout ça il faut : 

- instlaller le sdk android
- installer gradle `brew install flutter`
- installer flutter `brew install --cask flutter`
- Installer un IDE qui le gère (moi j'ai utilisé Visual Studio Code)


Si on veut faire tourner sur son device android (ce que j'ai fait), il faut : 

- le passer en developper mode : ça dépend du device mais en gros faut trouver le numéro de build et taper dessus 7 fois (https://www.samsung.com/uk/support/mobile-devices/how-do-i-turn-on-the-developer-options-menu-on-my-samsung-galaxy-device/#:~:text=1%20Go%20to%20%22Settings%22%2C,enable%20the%20Developer%20options%20menu.) 
- Ca ajoute un menu "déveloper options" qu'il faut activer et dans ce menu faut aussi activer "install via USB" et "usb debugging" (vous aurez un warning flippant, c'est normal)
- via la commande `adb` vous pouvez vous les mobiles connectés à l'ordinateur `adb devices -l`, par exemple moi il me retourne : 

```
List of devices attached
3055c06c               device usb:336592896X product:spesn_eea model:2201117TY device:spesn transport_id:1
```

A partir de la vous devriez voir le device dans Visual Studio Code et pouvoir executer l'app dessus en appuyant sur le bouton "play" après avoir sélectionné le device (je crois que ça lance `flutter run` du terminal)