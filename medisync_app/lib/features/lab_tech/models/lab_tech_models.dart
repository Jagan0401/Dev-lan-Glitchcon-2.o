/// Data models and seed data for the Lab Technician dashboard.
/// Mirrors the static content from labtech.html exactly.
library;

// ─── Enums ────────────────────────────────────────────────────────────────────

enum CollectionStatus { scheduled, inProgress, completed, cancelled }

extension CollectionStatusExt on CollectionStatus {
  String get label => switch (this) {
    CollectionStatus.scheduled => 'Scheduled',
    CollectionStatus.inProgress => 'In Progress',
    CollectionStatus.completed => 'Completed',
    CollectionStatus.cancelled => 'Cancelled',
  };
}

enum SampleStatus { pending, collected, inTransit, delivered, reportFinalised }

extension SampleStatusExt on SampleStatus {
  String get label => switch (this) {
    SampleStatus.pending => 'Pending',
    SampleStatus.collected => 'Collected',
    SampleStatus.inTransit => 'In Transit',
    SampleStatus.delivered => 'Delivered',
    SampleStatus.reportFinalised => 'Report Finalised',
  };
}

// ─── Models ───────────────────────────────────────────────────────────────────

class CollectionTask {
  final String patientName;
  final String testName;
  final String address;
  final String timeSlot;
  final String patientId;
  final String age;
  final String assignedDoctor;
  final String condition;
  CollectionStatus status;

  CollectionTask({
    required this.patientName,
    required this.testName,
    required this.address,
    required this.timeSlot,
    required this.patientId,
    required this.age,
    required this.assignedDoctor,
    required this.condition,
    this.status = CollectionStatus.scheduled,
  });
}

class SampleRecord {
  final String sampleId;
  final String patientName;
  final String testName;
  final String collectedAt;
  SampleStatus status;

  SampleRecord({
    required this.sampleId,
    required this.patientName,
    required this.testName,
    required this.collectedAt,
    this.status = SampleStatus.collected,
  });
}

class RouteStop {
  final String timeSlot;
  final String patientName;
  final String location;
  bool confirmed;

  RouteStop({
    required this.timeSlot,
    required this.patientName,
    required this.location,
    this.confirmed = false,
  });
}

class CommLog {
  final String patientName;
  final String lastMessage;
  final String channel;
  final String status;

  const CommLog({
    required this.patientName,
    required this.lastMessage,
    required this.channel,
    required this.status,
  });
}

class AuditEntry {
  final String actor;
  final String action;
  final String timestamp;

  const AuditEntry({
    required this.actor,
    required this.action,
    required this.timestamp,
  });
}

class TechActivityItem {
  final String icon;
  final String text;
  final String time;

  const TechActivityItem({
    required this.icon,
    required this.text,
    required this.time,
  });
}

// ─── Seed data ────────────────────────────────────────────────────────────────

final seedTasks = [
  CollectionTask(
    patientName: 'Ravi Kumar',
    testName: 'HbA1c',
    address: 'T.Nagar, Chennai',
    timeSlot: '09:00 AM',
    patientId: 'P-7729',
    age: '52',
    assignedDoctor: 'Dr. Rahul Sharma',
    condition: 'Diabetes',
    status: CollectionStatus.scheduled,
  ),
  CollectionTask(
    patientName: 'Meena Iyer',
    testName: 'Creatinine',
    address: 'Indiranagar, BLR',
    timeSlot: '10:30 AM',
    patientId: 'P-7730',
    age: '48',
    assignedDoctor: 'Dr. Rahul Sharma',
    condition: 'CKD',
    status: CollectionStatus.completed,
  ),
  CollectionTask(
    patientName: 'Arjun Patel',
    testName: 'BP Test',
    address: 'Saket, Delhi',
    timeSlot: '11:15 AM',
    patientId: 'P-7731',
    age: '35',
    assignedDoctor: 'Dr. Rahul Sharma',
    condition: 'Hypertension',
    status: CollectionStatus.scheduled,
  ),
  CollectionTask(
    patientName: 'Neha Sharma',
    testName: 'TSH',
    address: 'Banjara Hills, HYD',
    timeSlot: '12:00 PM',
    patientId: 'P-7732',
    age: '41',
    assignedDoctor: 'Dr. Rahul Sharma',
    condition: 'Hypothyroidism',
    status: CollectionStatus.scheduled,
  ),
  CollectionTask(
    patientName: 'Karthik Rao',
    testName: 'Creatinine',
    address: 'Kothrud, Pune',
    timeSlot: '01:00 PM',
    patientId: 'P-7733',
    age: '58',
    assignedDoctor: 'Dr. Rahul Sharma',
    condition: 'CKD',
    status: CollectionStatus.scheduled,
  ),
];

final seedSamples = [
  SampleRecord(
    sampleId: 'S1001',
    patientName: 'Ravi Kumar',
    testName: 'HbA1c',
    collectedAt: '9:05 AM',
    status: SampleStatus.collected,
  ),
  SampleRecord(
    sampleId: 'S1002',
    patientName: 'Meena Iyer',
    testName: 'Creatinine',
    collectedAt: '10:35 AM',
    status: SampleStatus.delivered,
  ),
  SampleRecord(
    sampleId: 'S1003',
    patientName: 'Arjun Patel',
    testName: 'BP Test',
    collectedAt: '11:20 AM',
    status: SampleStatus.collected,
  ),
  SampleRecord(
    sampleId: 'S1004',
    patientName: 'Neha Sharma',
    testName: 'TSH',
    collectedAt: '12:10 PM',
    status: SampleStatus.collected,
  ),
  SampleRecord(
    sampleId: 'S1005',
    patientName: 'Karthik Rao',
    testName: 'Creatinine',
    collectedAt: '—',
    status: SampleStatus.pending,
  ),
];

final seedRouteStops = [
  RouteStop(
    timeSlot: '09:00 AM',
    patientName: 'Ravi Kumar',
    location: 'Chennai',
  ),
  RouteStop(
    timeSlot: '10:30 AM',
    patientName: 'Meena Iyer',
    location: 'Bangalore',
  ),
  RouteStop(
    timeSlot: '11:15 AM',
    patientName: 'Arjun Patel',
    location: 'Delhi',
  ),
  RouteStop(
    timeSlot: '12:00 PM',
    patientName: 'Neha Sharma',
    location: 'Hyderabad',
  ),
  RouteStop(timeSlot: '01:00 PM', patientName: 'Karthik Rao', location: 'Pune'),
];

final seedCommLogs = [
  const CommLog(
    patientName: 'Ravi Kumar',
    lastMessage: 'Arrival confirmation',
    channel: 'WhatsApp',
    status: 'Delivered',
  ),
  const CommLog(
    patientName: 'Meena Iyer',
    lastMessage: 'Collection completed',
    channel: 'WhatsApp',
    status: 'Delivered',
  ),
  const CommLog(
    patientName: 'Arjun Patel',
    lastMessage: 'Running late by 10 mins',
    channel: 'SMS',
    status: 'Sent',
  ),
  const CommLog(
    patientName: 'Neha Sharma',
    lastMessage: 'Appointment reminder',
    channel: 'WhatsApp',
    status: 'Delivered',
  ),
  const CommLog(
    patientName: 'Karthik Rao',
    lastMessage: 'Address confirmation',
    channel: 'WhatsApp',
    status: 'Sent',
  ),
];

final seedAuditLog = [
  const AuditEntry(
    actor: 'Technician',
    action: 'Started visit for Ravi Kumar',
    timestamp: 'Today, 09:02 AM',
  ),
  const AuditEntry(
    actor: 'Technician',
    action: 'Uploaded sample details #S1001',
    timestamp: 'Today, 09:15 AM',
  ),
  const AuditEntry(
    actor: 'Technician',
    action: 'Finalized diagnostic report for Ravi Kumar',
    timestamp: 'Today, 09:45 AM',
  ),
  const AuditEntry(
    actor: 'Technician',
    action: 'Marked collection completed (Meena I.)',
    timestamp: 'Today, 10:45 AM',
  ),
  const AuditEntry(
    actor: 'Technician',
    action: 'Updated sample status to Lab Delivered',
    timestamp: 'Yesterday',
  ),
];

final seedActivityFeed = [
  const TechActivityItem(
    icon: '💉',
    text: 'Sample collected from Ravi Kumar',
    time: '2 mins ago',
  ),
  const TechActivityItem(
    icon: '🚚',
    text: 'Creatinine sample delivered to lab',
    time: '15 mins ago',
  ),
  const TechActivityItem(
    icon: '📅',
    text: 'Collection scheduled for Meena Iyer',
    time: '1 hour ago',
  ),
  const TechActivityItem(
    icon: '📝',
    text: 'Follow-up requested for Arjun Patel',
    time: '2 hours ago',
  ),
  const TechActivityItem(
    icon: '✓',
    text: 'Appointment confirmed with Neha Sharma',
    time: '4 hours ago',
  ),
];
