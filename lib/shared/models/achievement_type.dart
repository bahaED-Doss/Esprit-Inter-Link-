import 'package:flutter/material.dart';

enum AchievementRole { hr, pm, student }

enum AchievementType {
  // HR
  hrProfilePioneer,
  hrCompanyChampion,
  hrFirstOpportunity,
  hrOpportunityMaker,
  hrTalentScout,
  hrTeamBuilder,
  // PM
  pmProfilePioneer,
  pmProjectInitiator,
  pmProjectArchitect,
  pmTaskMaster,
  pmDelegationExpert,
  pmProjectFinisher,
  pmProjectLegend,
  // Student
  studentProfilePioneer,
  studentWelcomeAboard,
  studentTaskWarrior,
  studentRisingStar,
  studentQuizMaster,
  studentFirstWeekChampion,
  studentInternshipLegend,
}

class Achievement {
  final AchievementType type;
  final AchievementRole role;
  final String title;
  final String subtitle;
  final String message;
  final IconData icon;
  final int xpPoints;

  const Achievement({
    required this.type,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.message,
    required this.icon,
    required this.xpPoints,
  });

  static Achievement fromType(AchievementType type) {
    switch (type) {
      // HR
      case AchievementType.hrProfilePioneer:
        return const Achievement(
          type: AchievementType.hrProfilePioneer,
          role: AchievementRole.hr,
          title: 'Profile Pioneer',
          subtitle: 'Profile Completed',
          message: 'Great start! Your profile is ready to attract talent.',
          icon: Icons.verified_user,
          xpPoints: 100,
        );
      case AchievementType.hrCompanyChampion:
        return const Achievement(
          type: AchievementType.hrCompanyChampion,
          role: AchievementRole.hr,
          title: 'Company Champion',
          subtitle: 'Company Profile Complete',
          message: 'Your company shines! Students will love learning about you.',
          icon: Icons.apartment,
          xpPoints: 150,
        );
      case AchievementType.hrFirstOpportunity:
        return const Achievement(
          type: AchievementType.hrFirstOpportunity,
          role: AchievementRole.hr,
          title: 'First Opportunity',
          subtitle: 'Posted Your First Offer',
          message: 'The journey begins! Your first opportunity is live.',
          icon: Icons.campaign,
          xpPoints: 200,
        );
      case AchievementType.hrOpportunityMaker:
        return const Achievement(
          type: AchievementType.hrOpportunityMaker,
          role: AchievementRole.hr,
          title: 'Opportunity Maker',
          subtitle: 'Posted 3 Offers',
          message: "You're creating opportunities! Keep opening doors.",
          icon: Icons.description,
          xpPoints: 300,
        );
      case AchievementType.hrTalentScout:
        return const Achievement(
          type: AchievementType.hrTalentScout,
          role: AchievementRole.hr,
          title: 'Talent Scout',
          subtitle: 'Accepted Your First Intern',
          message: 'Welcome to mentorship! A new journey begins.',
          icon: Icons.handshake,
          xpPoints: 250,
        );
      case AchievementType.hrTeamBuilder:
        return const Achievement(
          type: AchievementType.hrTeamBuilder,
          role: AchievementRole.hr,
          title: 'Team Builder',
          subtitle: 'Built a Team of 5',
          message: "You're building the future! Your team is growing strong.",
          icon: Icons.groups,
          xpPoints: 400,
        );
      // PM
      case AchievementType.pmProfilePioneer:
        return const Achievement(
          type: AchievementType.pmProfilePioneer,
          role: AchievementRole.pm,
          title: 'Profile Pioneer',
          subtitle: 'Profile Completed',
          message: 'Ready to lead! Your profile is set.',
          icon: Icons.verified_user,
          xpPoints: 100,
        );
      case AchievementType.pmProjectInitiator:
        return const Achievement(
          type: AchievementType.pmProjectInitiator,
          role: AchievementRole.pm,
          title: 'Project Initiator',
          subtitle: 'Created Your First Project',
          message: "Every great journey starts with one project. Let's build!",
          icon: Icons.create_new_folder,
          xpPoints: 200,
        );
      case AchievementType.pmProjectArchitect:
        return const Achievement(
          type: AchievementType.pmProjectArchitect,
          role: AchievementRole.pm,
          title: 'Project Architect',
          subtitle: 'Created 3 Projects',
          message: "You're building an empire! Your vision is taking shape.",
          icon: Icons.folder_copy,
          xpPoints: 300,
        );
      case AchievementType.pmTaskMaster:
        return const Achievement(
          type: AchievementType.pmTaskMaster,
          role: AchievementRole.pm,
          title: 'Task Master',
          subtitle: 'Created Your First Task',
          message: 'Breaking it down! Great projects start with clear tasks.',
          icon: Icons.assignment_turned_in,
          xpPoints: 150,
        );
      case AchievementType.pmDelegationExpert:
        return const Achievement(
          type: AchievementType.pmDelegationExpert,
          role: AchievementRole.pm,
          title: 'Delegation Expert',
          subtitle: 'Created 5 Tasks',
          message: "You're organizing like a pro! Your team knows what to do.",
          icon: Icons.assignment,
          xpPoints: 250,
        );
      case AchievementType.pmProjectFinisher:
        return const Achievement(
          type: AchievementType.pmProjectFinisher,
          role: AchievementRole.pm,
          title: 'Project Finisher',
          subtitle: 'Completed Your First Project',
          message: "Victory! You've proven you can deliver excellence.",
          icon: Icons.flag,
          xpPoints: 350,
        );
      case AchievementType.pmProjectLegend:
        return const Achievement(
          type: AchievementType.pmProjectLegend,
          role: AchievementRole.pm,
          title: 'Project Legend',
          subtitle: 'Completed 3 Projects',
          message: "Legendary! You're a master of execution and delivery.",
          icon: Icons.emoji_events,
          xpPoints: 500,
        );
      // Student
      case AchievementType.studentProfilePioneer:
        return const Achievement(
          type: AchievementType.studentProfilePioneer,
          role: AchievementRole.student,
          title: 'Profile Pioneer',
          subtitle: 'Profile Completed',
          message: "Looking good! You're ready to impress employers.",
          icon: Icons.verified_user,
          xpPoints: 100,
        );
      case AchievementType.studentWelcomeAboard:
        return const Achievement(
          type: AchievementType.studentWelcomeAboard,
          role: AchievementRole.student,
          title: 'Welcome Aboard',
          subtitle: "You're Officially an Intern",
          message: 'Your journey begins here. Time to make an impact!',
          icon: Icons.work,
          xpPoints: 100,
        );
      case AchievementType.studentTaskWarrior:
        return const Achievement(
          type: AchievementType.studentTaskWarrior,
          role: AchievementRole.student,
          title: 'Task Warrior',
          subtitle: 'Completed 5 Tasks',
          message: "You're crushing it! Your dedication shows.",
          icon: Icons.checklist,
          xpPoints: 200,
        );
      case AchievementType.studentRisingStar:
        return const Achievement(
          type: AchievementType.studentRisingStar,
          role: AchievementRole.student,
          title: 'Rising Star',
          subtitle: 'Received Outstanding Feedback',
          message: 'Your supervisor is impressed. Shine bright!',
          icon: Icons.star,
          xpPoints: 250,
        );
      case AchievementType.studentQuizMaster:
        return const Achievement(
          type: AchievementType.studentQuizMaster,
          role: AchievementRole.student,
          title: 'Quiz Master',
          subtitle: 'Completed 3 Quizzes',
          message: 'Your knowledge is growing. Keep up the great work!',
          icon: Icons.menu_book,
          xpPoints: 150,
        );
      case AchievementType.studentFirstWeekChampion:
        return const Achievement(
          type: AchievementType.studentFirstWeekChampion,
          role: AchievementRole.student,
          title: 'First Week Champion',
          subtitle: 'Survived Your First Week',
          message: "One week down, many more to go. You've got this!",
          icon: Icons.calendar_today,
          xpPoints: 175,
        );
      case AchievementType.studentInternshipLegend:
        return const Achievement(
          type: AchievementType.studentInternshipLegend,
          role: AchievementRole.student,
          title: 'Internship Legend',
          subtitle: 'Perfect Internship Completion',
          message: "You've mastered every challenge. Congratulations!",
          icon: Icons.emoji_events,
          xpPoints: 500,
        );
    }
  }

  static List<Achievement> getAllAchievements() {
    return AchievementType.values.map((type) => fromType(type)).toList();
  }

  static List<Achievement> getAchievementsByRole(AchievementRole role) {
    return getAllAchievements().where((a) => a.role == role).toList();
  }
}
