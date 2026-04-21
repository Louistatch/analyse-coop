# 🌾 Coop Analyzer

**Transformation des Coopératives Agricoles Togolaises en Actifs Financiers**

![Version](https://img.shields.io/badge/version-1.0.1-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## 📖 À Propos

**Coop Analyzer** est une application mobile et web complète conçue pour évaluer et transformer les coopératives agricoles togolaises en actifs financiers investissables. L'outil permet aux investisseurs, banques et partenaires techniques d'obtenir une évaluation objective et standardisée des coopératives.

### 🎯 Objectifs

- ✅ **Standardiser** l'évaluation financière des coopératives agricoles
- ✅ **Identifier** les forces et faiblesses de chaque coopérative
- ✅ **Transformer** les coopératives en opportunités d'investissement crédibles
- ✅ **Faciliter** l'accès au financement bancaire et aux investisseurs
- ✅ **Mesurer** l'impact des interventions et le suivi dans le temps

---

## 🚀 Fonctionnalités Principales

### 🔐 Authentification et Gestion des Utilisateurs
- Inscription et connexion sécurisée (Firebase Auth)
- Profils utilisateurs stockés dans Firestore
- Réinitialisation de mot de passe

### 🏢 Gestion des Coopératives
- CRUD complet (Créer, Lire, Mettre à jour, Supprimer)
- Informations détaillées : nom, localisation, filière, nombre de membres
- Synchronisation cloud automatique

### 💰 Évaluation Financière Complète

#### Actifs (10 Catégories)
1. Trésorerie et liquidités
2. Stocks de produits et intrants
3. Créances et avances
4. Terrains et infrastructures
5. Bâtiments
6. Équipements agricoles
7. Matériel de transport
8. Mobiliers de bureau
9. Matériel informatique
10. Autres actifs

#### Passifs (11 Catégories)
1. Emprunts bancaires court terme
2. Dettes fournisseurs
3. Dettes envers membres
4. Charges sociales et fiscales
5. Autres dettes court terme
6. Emprunts bancaires long terme
7. Crédits équipements
8. Autres dettes long terme
9. Capital social
10. Réserves et résultats
11. Subventions

### 📝 Système d'Enquête Standardisée
- **25 questions** réparties en 5 thématiques :
  - Gouvernance et Organisation (5 questions)
  - Gestion Financière (5 questions)
  - Opérations et Production (5 questions)
  - Relations avec Membres (5 questions)
  - Partenariats et Marchés (5 questions)

### 📊 Scoring et Classification Automatiques
- **Classe A (80-100 points)** : Excellence - Éligible aux meilleurs taux
- **Classe B (60-79 points)** : Bon - Performance satisfaisante
- **Classe C (40-59 points)** : Moyen - Améliorations nécessaires
- **Classe D (0-39 points)** : Faible - Restructuration requise

### 🔍 Diagnostic et Recommandations
- Analyse automatique des forces et faiblesses
- Recommandations actionnables personnalisées
- Identification des axes prioritaires d'amélioration

### 📄 Génération de Rapports PDF
- Rapports professionnels pour investisseurs et banques
- Graphiques interactifs (fl_chart)
- Statistiques et ratios financiers clés
- Export et partage faciles

### 🏆 Classement des Coopératives
- Classement par score global
- Médailles d'excellence (Or, Argent, Bronze)
- Vue comparative entre coopératives

### 🔄 Système de Mise à Jour Automatique
- Vérification automatique des nouvelles versions (Firebase Remote Config)
- Notifications de mises à jour
- Téléchargement intégré via URL
- Mises à jour obligatoires pour corrections critiques

---

## 📱 Captures d'Écran

*(Ajoutez vos captures d'écran ici)*

---

## 🛠️ Stack Technique

### Framework & Langage
- **Flutter** 3.35.4
- **Dart** 3.9.2

### Backend & Base de Données
- **Firebase Core** 3.6.0
- **Firebase Authentication** 5.3.1
- **Cloud Firestore** 5.4.3
- **Firebase Storage** 12.3.2
- **Firebase Remote Config** 5.1.3

### Gestion d'État & Stockage Local
- **Provider** 6.1.5+1 (State Management)
- **Hive** 2.2.3 + **hive_flutter** 1.1.0 (Local Storage)
- **shared_preferences** 2.5.3 (Key-Value Storage)

### UI & Visualisation
- **Material Design 3**
- **fl_chart** 0.69.0 (Graphiques interactifs)

### Génération de Documents
- **pdf** 3.11.1
- **printing** 5.13.4
- **excel** 4.0.6

### Utilitaires
- **http** 1.5.0 (API calls)
- **file_picker** 8.1.4 (File selection)
- **path_provider** 2.1.5 (Paths)
- **intl** 0.20.1 (Internationalization)

---

## 🎨 Design & Branding

### Couleurs Principales
- **Violet** : `#6B4CE6` (RGB 107, 76, 230)
- **Orange** : `#FF6B35` (RGB 255, 107, 53)

### Identité Visuelle
- Logo unique généré par IA
- Dégradé violet-orange symbolisant agriculture et analyse
- Icônes Android adaptatives (5 résolutions)
- Favicon et icônes PWA pour Web

---

## 📦 Installation

### Prérequis
- Flutter 3.35.4 ou supérieur
- Dart 3.9.2 ou supérieur
- Android Studio / Xcode (pour développement mobile)
- Firebase project configuré

### Cloner le Repository
```bash
git clone https://github.com/Louistatch/analyse-coop.git
cd analyse-coop
```

### Installer les Dépendances
```bash
flutter pub get
```

### Configuration Firebase
1. Créer un projet Firebase sur [Firebase Console](https://console.firebase.google.com/)
2. Ajouter une application Android et/ou Web
3. Télécharger `google-services.json` (Android) et placer dans `android/app/`
4. Générer `firebase_options.dart` avec FlutterFire CLI :
   ```bash
   flutterfire configure
   ```

### Lancer l'Application

**Mode Web (Développement)**
```bash
flutter run -d chrome
```

**Mode Android (Développement)**
```bash
flutter run
```

**Build Production (Web)**
```bash
flutter build web --release
```

**Build Production (Android APK)**
```bash
flutter build apk --release
```

**Build Production (Android App Bundle)**
```bash
flutter build appbundle --release
```

---

## 🌐 Déploiement

### Version Web
La version Web peut être déployée sur :
- Firebase Hosting
- Netlify
- Vercel
- GitHub Pages

### Version Mobile (Android)
- Google Play Store
- Distribution directe via APK
- Firebase App Distribution (Beta testing)

---

## 📊 Architecture

```
lib/
├── main.dart                      # Point d'entrée
├── firebase_options.dart          # Configuration Firebase
├── models/                        # Modèles de données
│   ├── cooperative.dart
│   ├── enquete_membre.dart
│   ├── evaluation_actifs.dart
│   ├── evaluation_passifs.dart
│   └── parametrage.dart
├── providers/                     # State Management
│   └── app_provider.dart
├── screens/                       # Écrans de l'application
│   ├── dashboard_screen.dart
│   ├── cooperatives_screen.dart
│   ├── enquetes_screen.dart
│   ├── diagnostics_screen.dart
│   ├── classement_screen.dart
│   ├── reports_screen.dart
│   ├── evaluation_actifs_screen.dart
│   ├── evaluation_passifs_screen.dart
│   ├── login_screen.dart
│   └── register_screen.dart
├── services/                      # Services métier
│   ├── auth_service.dart
│   ├── calcul_service.dart
│   ├── excel_import_service.dart
│   ├── local_storage_service.dart
│   ├── pdf_export_service.dart
│   └── update_service.dart
├── widgets/                       # Widgets réutilisables
│   ├── stat_widgets.dart
│   └── update_dialog.dart
└── utils/                         # Utilitaires
    └── app_theme.dart
```

---

## 🔒 Sécurité

- ✅ Authentification Firebase sécurisée
- ✅ Règles Firestore pour protection des données
- ✅ Validation côté client et serveur
- ✅ HTTPS pour toutes les communications
- ✅ Données sensibles stockées de manière sécurisée

---

## 📈 Roadmap

### Version 1.5 (T2 2025)
- [ ] Tableaux de bord avancés avec plus de métriques
- [ ] Analyse comparative multi-coopératives
- [ ] Export Excel depuis l'application mobile
- [ ] Mode hors-ligne complet avec synchronisation différée

### Version 2.0 (T4 2025)
- [ ] Intelligence Artificielle pour prédictions de performance
- [ ] Marketplace connectant investisseurs et coopératives
- [ ] Module de gestion de projet post-financement
- [ ] API REST pour intégration avec systèmes bancaires
- [ ] Support multilingue (Français, Anglais, Ewe, Kabye)

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 👥 Auteurs

- **Louis Tatchum** - [@Louistatch](https://github.com/Louistatch)

---

## 📞 Contact

Pour toute question, suggestion ou partenariat :

- **Email** : contact@coopanalyzer.com (à configurer)
- **GitHub** : [https://github.com/Louistatch/analyse-coop](https://github.com/Louistatch/analyse-coop)

---

## 🙏 Remerciements

- Firebase pour l'infrastructure backend
- Flutter team pour le framework exceptionnel
- Communauté open-source Flutter
- Coopératives agricoles togolaises pour leur collaboration

---

## 📊 Statistiques du Projet

![GitHub stars](https://img.shields.io/github/stars/Louistatch/analyse-coop)
![GitHub forks](https://img.shields.io/github/forks/Louistatch/analyse-coop)
![GitHub issues](https://img.shields.io/github/issues/Louistatch/analyse-coop)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Louistatch/analyse-coop)

---

## 🌍 Impact Social

**Coop Analyzer** vise à transformer l'écosystème agricole togolais en :
- Facilitant l'accès au financement pour 1,200+ coopératives
- Créant des opportunités d'investissement transparentes
- Améliorant la gouvernance et la gestion financière
- Contribuant à la sécurité alimentaire et au développement économique

**Ensemble, transformons les coopératives en actifs financiers viables !** 🌾💰

---

**Made with ❤️ in Togo for Togolese Agricultural Cooperatives**
