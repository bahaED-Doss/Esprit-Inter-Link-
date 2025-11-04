class WorkExperience {
  final String title;
  final String company;
  final String duration;

  WorkExperience({required this.title, required this.company, required this.duration});
}

class Education {
  final String degree;
  final String institution;
  final String duration;

  Education({required this.degree, required this.institution, required this.duration});
}

class Skill {
  final String name;

  Skill({required this.name});
}

class Appreciation {
  final String title;
  final String context;
  final String year;

  Appreciation({required this.title, required this.context, required this.year});
}

class Resume {
  final String fileName;
  final String fileSize;

  Resume({required this.fileName, required this.fileSize});
}

// Données statiques simulées
class StudentProfileData {
  static const String name = 'Ahmed Slim';
  static const String location = 'Sousse, Tunisia';
  static const String avatarPath = 'assets/images/ahmed_avatar.png'; // Assurez-vous d'avoir une image d'avatar
  static const String aboutMe =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lectus id commodo egestas metus interdum dolor.';
  static const String resumePath = 'assets/docs/Jamel_kudasi_CV.pdf';

  static final List<WorkExperience> workExperiences = [
    WorkExperience(title: 'Manager', company: 'Amazon Inc', duration: 'Jan 2018 - Feb 2022 • 5 Years'),
  ];

  static final List<Education> educationList = [
    Education(degree: 'Information Technology', institution: 'University of Oxford', duration: 'Sep 2010 - Aug 2013 • 5 Years'),
  ];

  static final List<Skill> skills = [
    Skill(name: 'Leadership'),
    Skill(name: 'Teamwork'),
    Skill(name: 'Visioner'),
    Skill(name: 'Target oriented'),
    Skill(name: 'Consistent'),
    Skill(name: '+5 more'),
  ];

  static final List<String> languages = [
    'English',
    'German',
    'Spanish',
    'Mandarin',
    'Italy',
  ];

  static final List<Appreciation> appreciations = [
    Appreciation(title: 'Wireless Symposium (RWS)', context: 'Young Scientist', year: '2014'),
  ];

  static final Resume resume = Resume(fileName: 'Jamel kudasi - CV - UI/UX Designer', fileSize: '587 KB');
}