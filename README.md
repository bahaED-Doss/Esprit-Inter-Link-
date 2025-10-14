# 🎓 Esprit-InterLink

**Connecting ESPRIT students with internship opportunities**

---

## 📱 À propos

Esprit-InterLink connecte entreprises, chefs de projet et étudiants pour la gestion des stages :
- **HR** : Publie des offres, gère les candidatures, crée des comptes PM
- **PM** : Gère les projets, crée des tâches, suit l’avancement
- **Étudiants** : Parcourent les offres, postulent, réalisent les tâches via Kanban

---

## 🚀 Installation rapide

1. **Cloner le projet**
   ```bash
   git clone <repo-url>
   cd esprit-interlink
   flutter pub get
   flutter run
   ```

2. **Ouvrir dans Android Studio**
   - Passer en vue “Project” pour voir la vraie structure.

---

## 🏗️ Architecture du projet

```
lib/
├── core/           // Thème, couleurs, widgets génériques
├── shared/         // AppBar, Drawer, gestion session utilisateur
├── data/           // Configuration base de données locale
├── modules/        // Modules métier (auth, offres, candidatures, etc.)
│   ├── auth/
│   ├── offers/
│   ├── applications/
│   ├── tasks/
│   ├── projects/
│   ├── company/
│   ├── profile/
│   └── notifications/
└── main.dart       // Point d’entrée
```

**Principe** : Chaque module suit une structure inspirée de l’architecture “feature-based” d’Angular/Spring Boot :
- `models/` : Modèles de données (équivalent aux entités)
- `providers/` : Gestion d’état (équivalent aux services)
- `repositories/` : Accès base de données (équivalent aux repositories Spring)
- `presentation/pages/` : Pages (équivalent aux composants Angular)
- `presentation/widgets/` : Widgets réutilisables

---

## 👥 Répartition des modules

| Module           | Responsable | À faire                                      |
|------------------|-------------|----------------------------------------------|
| Auth             | ...         | Connexion, inscription, invitation PM        |
| Offers           | ...         | HR crée des offres, étudiant les consulte    |
| Applications     | ...         | Étudiant postule, HR gère les candidatures   |
| Tasks            | ...         | Kanban étudiant, PM crée les tâches          |
| Projects         | ...         | PM gère, étudiant visualise                  |
| Company          | ...         | HR configure l’entreprise, crée PM           |
| Profile          | ...         | Voir/éditer profil (tous rôles)              |
| Notifications    | ...         | Voir notifications (tous rôles)              |

---

## 🧩 Workflow de développement

1. **Créer une branche**
   ```bash
   git checkout -b module/offers
   ```

2. **Créer la structure du module**
   ```bash
   cd lib/modules
   mkdir -p offers/models offers/providers offers/repositories offers/presentation/pages offers/presentation/widgets
   ```

3. **Développer en respectant la séparation par rôle**
   - Préfixer les pages : `hr_`, `student_`, `pm_`
   - Les widgets réutilisables vont dans `widgets/`

---

## 🗄️ Connexion à la base de données

- Utilisation de `sqflite` (SQLite embarqué)
- Les modèles incluent toujours les références utilisateur (ex : `hrId`, `studentId`)
- Les requêtes sont filtrées par utilisateur courant (comme un repository Spring avec `@Query`)
- Les rôles sont stockés dans la table `users` (`role` = 'HR', 'PM', 'ST')

**Exemple d’insertion utilisateur :**
```dart
await db.insert('users', {
  'id': userId,
  'email': email,
  'role': UserRole.hr.code,  // 'HR'
});
```

**Exemple de requête filtrée :**
```dart
final result = await db.query('offers', where: 'hr_id = ?', whereArgs: [hrId]);
```

---

## 🏆 Bonnes pratiques

- **Séparer les pages par rôle** (pas de page unique pour tout)
- **Jamais d’ID en dur** : toujours utiliser le provider de session utilisateur
- **Les méthodes repository filtrent par utilisateur**
- **Tester avec différents rôles**
- **Inclure les clés étrangères dans les modèles**

---

## 🛑 À éviter

- ❌ Une seule page pour tous les rôles
- ❌ Pas de filtrage par utilisateur
- ❌ IDs codés en dur
- ❌ Oublier les clés étrangères dans les modèles
- ❌ Pas de vérification de rôle avant action

---

## 🔗 Pour les habitués Spring Boot/Angular

- **modules/** = features Angular ou packages Spring
- **models/** = entités
- **repositories/** = repositories Spring
- **providers/** = services Angular/Spring
- **presentation/pages/** = composants Angular
- **widgets/** = composants réutilisables Angular

---



