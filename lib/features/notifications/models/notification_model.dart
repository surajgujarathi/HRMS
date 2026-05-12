class OdooNotification {
  final int id;
  final String status; // notification_status
  final int messageId;
  final String messageSubject;
  final String messageBody;
  final DateTime messageDate;
  final String notificationType;
  final bool isRead;
  final DateTime? readDate;
  final String? failureType;
  final String? failureReason;
  final int partnerId;

  OdooNotification({
    required this.id,
    required this.status,
    required this.messageId,
    required this.messageSubject,
    required this.messageBody,
    required this.messageDate,
    required this.notificationType,
    required this.isRead,
    this.readDate,
    this.failureType,
    this.failureReason,
    required this.partnerId,
  });

  factory OdooNotification.fromJson(Map<String, dynamic> json) {
    // Handle Many2one for mail_message_id
    final messageData = json['mail_message_id'];
    int mId = 0;
    String mSubject = 'No Subject';
    if (messageData is List && messageData.isNotEmpty) {
      mId = messageData[0];
      mSubject = messageData[1];
    }

    return OdooNotification(
      id: json['id'],
      status: json['notification_status']?.toString() ?? 'ready',
      messageId: mId,
      messageSubject: mSubject,
      // Note: Body and Date might need a secondary fetch or dot-notation if supported.
      // For now, we use placeholders or the name if available.
      messageBody: json['message_body']?.toString() ?? '', 
      messageDate: json['message_date'] != null 
          ? DateTime.parse(json['message_date']) 
          : DateTime.now(),
      notificationType: json['notification_type']?.toString() ?? 'inbox',
      isRead: json['is_read'] ?? false,
      readDate: json['read_date'] != null && json['read_date'] != false 
          ? DateTime.parse(json['read_date']) 
          : null,
      failureType: json['failure_type'] != false ? json['failure_type']?.toString() : null,
      failureReason: json['failure_reason'] != false ? json['failure_reason']?.toString() : null,
      partnerId: (json['res_partner_id'] is List) 
          ? json['res_partner_id'][0] 
          : (json['res_partner_id'] ?? 0),
    );
  }
}
