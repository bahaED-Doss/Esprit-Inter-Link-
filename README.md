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

# 🏆 Déclencheurs de trophées (Trophies Triggers)

Pour chaque trophée, ajoutez ce code dans la partie concernée de votre module pour débloquer le trophée côté utilisateur :

---

## 🎓 Étudiant (Student)

- **Profile Pioneer** (Profil complété)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentProfilePioneer);
```
À placer après la validation du profil étudiant.

- **Welcome Aboard** (Devenir stagiaire)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentWelcomeAboard);
```
À placer quand le HR accepte la candidature d’un étudiant (statut accepté).

- **Task Warrior** (5 tâches complétées)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentTaskWarrior);
```
À placer après la validation de la 5ème tâche par l’étudiant.

- **Rising Star** (Feedback exceptionnel)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentRisingStar);
```
À placer quand le superviseur donne un feedback exceptionnel.

- **Quiz Master** (3 quiz complétés)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentQuizMaster);
```
À placer après la validation du 3ème quiz.

- **First Week Champion** (Première semaine terminée)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentFirstWeekChampion);
```
À placer à la fin de la première semaine de stage.

- **Internship Legend** (Stage terminé)
```dart
await TrophyService.unlockTrophy(context, AchievementType.studentInternshipLegend);
```
À placer à la fin du stage (statut terminé).

---

## 🏢 HR

- **Profile Pioneer**
```dart
await TrophyService.unlockTrophy(context, AchievementType.hrProfilePioneer);
```
Après la complétion du profil HR.

- **Company Champion**
```dart
await TrophyService.unlockTrophy(context, AchievementType.hrCompanyChampion);
```
Après la complétion du profil entreprise.

- **First Opportunity**
```dart
await TrophyService.unlockTrophy(context, AchievementType.hrFirstOpportunity);
```
Après la publication de la première offre.

- **Opportunity Maker**
```dart
await TrophyService.unlockTrophy(context, AchievementType.hrOpportunityMaker);
```
Après la publication de la 3ème offre.

- **Talent Scout**
```dart
await TrophyService.unlockTrophy(context, AchievementType.hrTalentScout);
```
Après avoir accepté le premier étudiant.

- **Team Builder**
```dart
await TrophyService.unlockTrophy(context, AchievementType.hrTeamBuilder);
```
Après avoir accepté 5 étudiants.

---

## 🗂️ Project Manager

- **Profile Pioneer**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmProfilePioneer);
```
Après la complétion du profil PM.

- **Project Initiator**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmProjectInitiator);
```
Après la création du premier projet.

- **Project Architect**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmProjectArchitect);
```
Après la création du 3ème projet.

- **Task Master**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmTaskMaster);
```
Après la création de la première tâche.

- **Delegation Expert**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmDelegationExpert);
```
Après la création de la 5ème tâche.

- **Project Finisher**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmProjectFinisher);
```
Après avoir terminé le premier projet (statut terminé).

- **Project Legend**
```dart
await TrophyService.unlockTrophy(context, AchievementType.pmProjectLegend);
```
Après avoir terminé 3 projets (statut terminé).

---

> Remplacez `TrophyService.unlockTrophy` par la fonction réelle de votre service de trophées si besoin.

---
