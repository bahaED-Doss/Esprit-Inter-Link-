# 🎓 Esprit-InterLink

**Connecting ESPRIT students with internship opportunities**

---

## 📱 About

Esprit-InterLink links companies, project managers, and students for internship management:
- **HR**: Post offers, review applications, create PM accounts
- **PM**: Manage projects, create tasks, view progress
- **Students**: Browse offers, apply, complete tasks via Kanban

---

## 🚀 Setup (Windows + Android Studio)

### 1. Clone & Install
```bash
git clone <repo-url>
cd esprit-interlink
flutter pub get
flutter run
```

### 2. View Project Structure
In Android Studio, switch from **"Android"** to **"Project"** view (top-left dropdown)

---

## 📁 Project Structure

```
lib/
├── core/           ✅ READY - Colors, theme, generic widgets
├── shared/         ✅ READY - AppBar, Drawer, User session
├── data/           ✅ READY - Database setup
├── modules/        🎯 YOU WORK HERE
│   ├── auth/
│   ├── offers/
│   ├── applications/
│   ├── tasks/
│   ├── projects/
│   ├── company/
│   ├── profile/
│   └── notifications/
└── main.dart       ✅ READY
```

---

## 👥 Module Assignments

| Module | Person | What to Build |
|--------|--------|---------------|
| **Auth** | _____ | Login, Signup, PM Invitation |
| **Offers** | _____ | HR creates offers + Student browses |
| **Applications** | _____ | Student applies + HR reviews |
| **Tasks** | _____ | Student Kanban + PM creates tasks |
| **Projects** | _____ | PM manages + Student views |
| **Company** | _____ | HR company setup + Create PM |
| **Profile** | _____ | View/Edit profile (all roles) |
| **Notifications** | _____ | View notifications (all roles) |

---

## 🎯 Your Workflow

### Step 1: Create Your Branch
```bash
git checkout -b module/offers  # or your module name
```

### Step 2: Create Module Folder Structure

**Option A: Terminal**
```bash
cd lib/modules
mkdir -p offers/models
mkdir -p offers/providers
mkdir -p offers/repositories
mkdir -p offers/presentation/pages
mkdir -p offers/presentation/widgets
```

**Option B: Android Studio**
- Right-click `lib/modules/` → New → Directory → `offers`
- Create subfolders: `models`, `providers`, `repositories`, `presentation/pages`, `presentation/widgets`

### Step 3: Build Your Module

Follow the structure below 👇

---

## 🏗️ Module Structure (Example: Offers)

```
modules/offers/
├── models/
│   └── offer_model.dart              # Data structure
├── providers/
│   └── offer_provider.dart           # State management
├── repositories/
│   └── offer_repository.dart         # Database queries
└── presentation/
    ├── pages/
    │   ├── hr_offers_list_page.dart      # HR sees their offers
    │   ├── hr_create_offer_page.dart     # HR creates new offer
    │   ├── hr_edit_offer_page.dart       # HR edits offer
    │   ├── student_offers_browse_page.dart  # Student browses all offers
    │   └── student_offer_detail_page.dart   # Student views offer details
    └── widgets/
        ├── offer_card.dart               # Reusable offer card
        └── offer_form.dart               # Form for create/edit
```

**Key Points:**
- **Separate pages** for each role (HR vs Student)
- **Name files clearly** by role prefix: `hr_`, `student_`, `pm_`
- **Shared widgets** go in `widgets/` folder

---

## 🎨 How to Handle Different Role Views

### ❌ **WRONG WAY (Last year's mistake):**
```dart
// Don't do this - One page trying to show everything!
class OffersPage extends StatelessWidget {
  Widget build(BuildContext context) {
    // Confusing! HR and Student see different things but same code?
    return ListView(
      children: offers.map((offer) => OfferCard(offer)).toList(),
    );
  }
}
```

### ✅ **CORRECT WAY:**

#### **1. Create Separate Pages for Each Role**

```dart
// pages/hr_offers_list_page.dart
class HROffersListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Offers"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create offer page
          Navigator.pushNamed(context, '/hr/create-offer');
        },
        child: Icon(Icons.add),
      ),
      body: Consumer<OfferProvider>(
        builder: (context, provider, _) {
          // IMPORTANT: Get only offers created by this HR
          final hrId = context.read<UserSessionProvider>().userId;
          final myOffers = provider.getOffersByHR(hrId);
          
          return ListView.builder(
            itemCount: myOffers.length,
            itemBuilder: (context, index) {
              final offer = myOffers[index];
              return OfferCard(
                offer: offer,
                // HR can Edit and Delete
                onEdit: () => Navigator.pushNamed(
                  context, 
                  '/hr/edit-offer',
                  arguments: offer.id,
                ),
                onDelete: () => provider.deleteOffer(offer.id),
              );
            },
          );
        },
      ),
    );
  }
}
```

```dart
// pages/student_offers_browse_page.dart
class StudentOffersBrowsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Browse Offers"),
      body: Consumer<OfferProvider>(
        builder: (context, provider, _) {
          // IMPORTANT: Get ALL active offers
          final allOffers = provider.getAllActiveOffers();
          
          return ListView.builder(
            itemCount: allOffers.length,
            itemBuilder: (context, index) {
              final offer = allOffers[index];
              return OfferCard(
                offer: offer,
                // Student can only View
                onTap: () => Navigator.pushNamed(
                  context,
                  '/student/offer-detail',
                  arguments: offer.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

#### **2. Repository Methods MUST Filter by User**

```dart
// repositories/offer_repository.dart
class OfferRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  // Get offers created by a specific HR
  Future<List<OfferModel>> getOffersByHR(String hrId) async {
    final db = await _db.database;
    final result = await db.query(
      'offers',
      where: 'hr_id = ?',  // ⭐ FILTER BY HR ID
      whereArgs: [hrId],
    );
    return result.map((json) => OfferModel.fromJson(json)).toList();
  }
  
  // Get all active offers (for students)
  Future<List<OfferModel>> getAllActiveOffers() async {
    final db = await _db.database;
    final result = await db.query(
      'offers',
      where: 'status = ?',  // Only active offers
      whereArgs: ['active'],
    );
    return result.map((json) => OfferModel.fromJson(json)).toList();
  }
  
  // Get a single offer by ID
  Future<OfferModel?> getOfferById(String offerId) async {
    final db = await _db.database;
    final result = await db.query(
      'offers',
      where: 'id = ?',
      whereArgs: [offerId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return OfferModel.fromJson(result.first);
  }
}
```

---

#### **3. Provider Uses Repository Methods**

```dart
// providers/offer_provider.dart
class OfferProvider extends ChangeNotifier {
  final OfferRepository _repository = OfferRepository();
  
  List<OfferModel> _allOffers = [];
  List<OfferModel> get allOffers => _allOffers;
  
  // Load offers for HR (their own offers only)
  Future<void> loadMyOffers(String hrId) async {
    _allOffers = await _repository.getOffersByHR(hrId);
    notifyListeners();
  }
  
  // Load all offers for students
  Future<void> loadActiveOffers() async {
    _allOffers = await _repository.getAllActiveOffers();
    notifyListeners();
  }
  
  // Get offers filtered by HR
  List<OfferModel> getOffersByHR(String hrId) {
    return _allOffers.where((offer) => offer.hrId == hrId).toList();
  }
  
  // Get all active offers
  List<OfferModel> getAllActiveOffers() {
    return _allOffers.where((offer) => offer.status == 'active').toList();
  }
}
```

---

#### **4. Model Includes User References**

```dart
// models/offer_model.dart
class OfferModel {
  final String id;
  final String title;
  final String description;
  final String companyId;
  final String hrId;        // ⭐ WHO created this offer
  final String status;      // active, closed, etc.
  final DateTime createdAt;
  
  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.companyId,
    required this.hrId,
    required this.status,
    required this.createdAt,
  });
  
  // Convert from database JSON
  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      companyId: json['company_id'],
      hrId: json['hr_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  // Convert to database JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'company_id': companyId,
      'hr_id': hrId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

---

## 🔑 Database Role Column

**In the `users` table, store role as string:**

```sql
users (
  id TEXT PRIMARY KEY,
  email TEXT,
  role TEXT  -- Save: 'HR', 'PM', or 'ST'
)
```

**When inserting user:**
```dart
await db.insert('users', {
  'id': userId,
  'email': email,
  'role': UserRole.hr.code,  // Saves 'HR'
});
```

**When reading user:**
```dart
final result = await db.query('users', where: 'id = ?', whereArgs: [userId]);
final roleCode = result.first['role'] as String;
final role = UserRole.fromCode(roleCode);  // Converts 'HR' to UserRole.hr
```

---

## 🎯 Real Example: Applications Module

### Scenario: Student applies, HR reviews

#### **Student View:**
```dart
// pages/student_apply_page.dart
class StudentApplyPage extends StatelessWidget {
  final String offerId;
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Apply to Internship"),
      body: ApplicationForm(
        onSubmit: (coverLetter) {
          final studentId = context.read<UserSessionProvider>().userId!;
          final application = ApplicationModel(
            offerId: offerId,
            studentId: studentId,  // ⭐ Current student ID
            coverLetter: coverLetter,
            status: 'pending',
          );
          context.read<ApplicationProvider>().submitApplication(application);
        },
      ),
    );
  }
}
```

#### **HR View:**
```dart
// pages/hr_applications_list_page.dart
class HRApplicationsListPage extends StatelessWidget {
  Widget build(BuildContext context) {
    final hrId = context.read<UserSessionProvider>().userId!;
    
    return Scaffold(
      appBar: CustomAppBar(title: "Applications"),
      body: Consumer<ApplicationProvider>(
        builder: (context, provider, _) {
          // ⭐ Get applications for offers created by this HR
          final applications = provider.getApplicationsForHR(hrId);
          
          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, i) {
              final app = applications[i];
              return ApplicationCard(
                application: app,
                onAccept: () => provider.acceptApplication(app.id),
                onReject: () => provider.rejectApplication(app.id),
              );
            },
          );
        },
      ),
    );
  }
}
```

#### **Repository:**
```dart
// Get applications for HR's offers
Future<List<ApplicationModel>> getApplicationsForHR(String hrId) async {
  final db = await _db.database;
  final result = await db.rawQuery('''
    SELECT applications.* 
    FROM applications
    JOIN offers ON applications.offer_id = offers.id
    WHERE offers.hr_id = ?
  ''', [hrId]);
  return result.map((json) => ApplicationModel.fromJson(json)).toList();
}

// Get applications by student
Future<List<ApplicationModel>> getApplicationsByStudent(String studentId) async {
  final db = await _db.database;
  final result = await db.query(
    'applications',
    where: 'student_id = ?',
    whereArgs: [studentId],
  );
  return result.map((json) => ApplicationModel.fromJson(json)).toList();
}
```

---

## ✅ Checklist Before Push

- [ ] Separate pages for each role (hr_, student_, pm_)
- [ ] Repository methods filter by user ID
- [ ] Tested with different user roles
- [ ] No hardcoded user IDs
- [ ] Used `UserSessionProvider` to get current user
- [ ] Models include user references (hrId, studentId, etc.)

---

## 🚫 Common Mistakes to Avoid

1. ❌ **One page for all roles** - Split into separate pages!
2. ❌ **Not filtering by user** - Always get data for current user
3. ❌ **Hardcoded IDs** - Use `UserSessionProvider`
4. ❌ **Missing foreign keys** - Store hrId, studentId in models
5. ❌ **No role checking** - Check `isHR`, `isStudent`, `isPM` before showing actions

---

## 📞 Need Help?
 
**Issues?** Check if you're using `UserSessionProvider` correctly!

---

**Good luck! 🚀**