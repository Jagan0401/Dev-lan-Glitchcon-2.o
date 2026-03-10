/// Lightweight local models for the Doctor Dashboard.
/// In production these would be fetched via the Dio API client.
library;

enum RiskLevel { low, medium, high, critical }

extension RiskLevelExt on RiskLevel {
  String get label => switch (this) {
    RiskLevel.low => 'Low',
    RiskLevel.medium => 'Medium',
    RiskLevel.high => 'High',
    RiskLevel.critical => 'Critical',
  };
}

class PatientSummary {
  final String id;
  final String name;
  final String condition;
  final String lastTest;
  final RiskLevel risk;

  const PatientSummary({
    required this.id,
    required this.name,
    required this.condition,
    required this.lastTest,
    required this.risk,
  });
}

class CareGapAlert {
  final String patientName;
  final String testOverdue;
  final String delay;
  final RiskLevel risk;
  bool escalated;

  CareGapAlert({
    required this.patientName,
    required this.testOverdue,
    required this.delay,
    required this.risk,
    this.escalated = false,
  });
}

class LabResult {
  final String patientName;
  final String testName;
  final String result;
  final String date;

  const LabResult({
    required this.patientName,
    required this.testName,
    required this.result,
    required this.date,
  });
}

class Appointment {
  final String patientName;
  final String purpose;
  final String date;
  final String status; // 'Scheduled' | 'Completed' | 'Cancelled'

  const Appointment({
    required this.patientName,
    required this.purpose,
    required this.date,
    required this.status,
  });
}

class ActivityFeedItem {
  final String icon;
  final String text;
  final String time;

  const ActivityFeedItem({
    required this.icon,
    required this.text,
    required this.time,
  });
}

class CaseloadBar {
  final String label;
  final double fraction; // 0.0 – 1.0
  final bool isCritical;

  const CaseloadBar({
    required this.label,
    required this.fraction,
    this.isCritical = false,
  });
}

// ─── Seed data (mirrors the HTML static content exactly) ──────────────────────

final seedPatients = [
  const PatientSummary(
    id: 'P1001',
    name: 'Ravi Kumar',
    condition: 'Diabetes',
    lastTest: '120 days ago',
    risk: RiskLevel.high,
  ),
  const PatientSummary(
    id: 'P1002',
    name: 'Meena Iyer',
    condition: 'CKD',
    lastTest: '200 days ago',
    risk: RiskLevel.critical,
  ),
  const PatientSummary(
    id: 'P1003',
    name: 'Arjun Patel',
    condition: 'Hypertension',
    lastTest: '60 days ago',
    risk: RiskLevel.medium,
  ),
  const PatientSummary(
    id: 'P1004',
    name: 'Neha Sharma',
    condition: 'Diabetes',
    lastTest: '30 days ago',
    risk: RiskLevel.low,
  ),
  const PatientSummary(
    id: 'P1005',
    name: 'Karthik Rao',
    condition: 'Hypothyroidism',
    lastTest: '150 days ago',
    risk: RiskLevel.high,
  ),
];

final seedCareGaps = [
  CareGapAlert(
    patientName: 'Ravi Kumar',
    testOverdue: 'HbA1c',
    delay: '120 days',
    risk: RiskLevel.high,
  ),
  CareGapAlert(
    patientName: 'Meena Iyer',
    testOverdue: 'Creatinine',
    delay: '200 days',
    risk: RiskLevel.critical,
  ),
  CareGapAlert(
    patientName: 'Arjun Patel',
    testOverdue: 'BP Check',
    delay: '95 days',
    risk: RiskLevel.medium,
  ),
  CareGapAlert(
    patientName: 'Neha Sharma',
    testOverdue: 'HbA1c',
    delay: '30 days',
    risk: RiskLevel.low,
  ),
  CareGapAlert(
    patientName: 'Karthik Rao',
    testOverdue: 'TSH',
    delay: '150 days',
    risk: RiskLevel.high,
  ),
];

final seedLabResults = [
  const LabResult(
    patientName: 'Ravi Kumar',
    testName: 'HbA1c',
    result: '9.5%',
    date: 'Mar 10',
  ),
  const LabResult(
    patientName: 'Meena Iyer',
    testName: 'Creatinine',
    result: '2.1',
    date: 'Mar 9',
  ),
  const LabResult(
    patientName: 'Arjun Patel',
    testName: 'BP Check',
    result: '145/92',
    date: 'Mar 8',
  ),
  const LabResult(
    patientName: 'Neha Sharma',
    testName: 'HbA1c',
    result: '6.8%',
    date: 'Mar 7',
  ),
  const LabResult(
    patientName: 'Karthik Rao',
    testName: 'TSH',
    result: '5.3',
    date: 'Mar 6',
  ),
];

final seedAppointments = [
  const Appointment(
    patientName: 'Ravi Kumar',
    purpose: 'HbA1c follow-up',
    date: 'Mar 20',
    status: 'Scheduled',
  ),
  const Appointment(
    patientName: 'Meena Iyer',
    purpose: 'CKD review',
    date: 'Mar 18',
    status: 'Scheduled',
  ),
  const Appointment(
    patientName: 'Arjun Patel',
    purpose: 'BP monitoring',
    date: 'Mar 17',
    status: 'Completed',
  ),
  const Appointment(
    patientName: 'Neha Sharma',
    purpose: 'Diabetes review',
    date: 'Mar 25',
    status: 'Scheduled',
  ),
  const Appointment(
    patientName: 'Karthik Rao',
    purpose: 'Thyroid review',
    date: 'Mar 22',
    status: 'Scheduled',
  ),
];

final seedActivityFeed = [
  const ActivityFeedItem(
    icon: '🤖',
    text: 'AI detected overdue HbA1c for Ravi Kumar',
    time: '2 mins ago',
  ),
  const ActivityFeedItem(
    icon: '📋',
    text: 'Patient Meena Iyer booked creatinine test',
    time: '15 mins ago',
  ),
  const ActivityFeedItem(
    icon: '🧪',
    text: 'Lab reported new test results for Arjun Patel',
    time: '1 hour ago',
  ),
  const ActivityFeedItem(
    icon: '🏠',
    text: 'Care coordinator scheduled home sample collection',
    time: '3 hours ago',
  ),
  const ActivityFeedItem(
    icon: '⚠️',
    text: 'Critical CKD patient escalated to doctor inbox',
    time: '4 hours ago',
  ),
];

final seedAuditLog = [
  const ActivityFeedItem(
    icon: '👤',
    text: 'Sent reminder to Ravi Kumar',
    time: 'Today, 10:45 AM',
  ),
  const ActivityFeedItem(
    icon: '📝',
    text: 'Reviewed CKD report #RK920',
    time: 'Today, 09:12 AM',
  ),
  const ActivityFeedItem(
    icon: '⚠️',
    text: 'Escalated patient Meena Iyer',
    time: 'Today, 08:30 AM',
  ),
  const ActivityFeedItem(
    icon: '📅',
    text: 'Scheduled follow-up with Arjun Patel',
    time: 'Yesterday',
  ),
  const ActivityFeedItem(
    icon: '🤖',
    text: 'System AI generated patient alert',
    time: 'Yesterday',
  ),
];

final seedCaseload = [
  const CaseloadBar(label: 'Low', fraction: 0.40),
  const CaseloadBar(label: 'Med', fraction: 0.70),
  const CaseloadBar(label: 'High', fraction: 1.00),
  const CaseloadBar(label: 'Crit', fraction: 0.30, isCritical: true),
];
