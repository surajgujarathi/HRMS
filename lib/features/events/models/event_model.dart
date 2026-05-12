import 'package:flutter_app/core/models/odoo_models.dart';

class EventModel {
  final int id;
  final String name;
  final DateTime? dateBegin;
  final DateTime? dateEnd;
  final String? dateTz;
  final String? lang;
  final ManyToOne? eventTypeId; // Template
  final List<int> tagIds;
  final ManyToOne? organizerId;
  final ManyToOne? userId; // Responsible
  final ManyToOne? companyId;
  final ManyToOne? addressId; // Venue
  final bool websitePublished;
  final String? websiteVisibility;
  final bool seatsLimited;
  final int seatsMax;
  final int seatsTaken;
  final String? badgeFormat;
  final String? badgeImage;
  final List<EventTicket> tickets;
  final List<EventQuestion> questions;
  final String? note; // Internal Notes
  final String? ticketInstructions;

  EventModel({
    required this.id,
    required this.name,
    this.dateBegin,
    this.dateEnd,
    this.dateTz,
    this.lang,
    this.eventTypeId,
    this.tagIds = const [],
    this.organizerId,
    this.userId,
    this.companyId,
    this.addressId,
    this.websitePublished = false,
    this.websiteVisibility,
    this.seatsLimited = false,
    this.seatsMax = 0,
    this.seatsTaken = 0,
    this.badgeFormat,
    this.badgeImage,
    this.tickets = const [],
    this.questions = const [],
    this.note,
    this.ticketInstructions,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      dateBegin: json['date_begin'] != null && json['date_begin'] != false
          ? DateTime.tryParse(json['date_begin'].toString())
          : null,
      dateEnd: json['date_end'] != null && json['date_end'] != false
          ? DateTime.tryParse(json['date_end'].toString())
          : null,
      dateTz: json['date_tz']?.toString(),
      lang: json['lang']?.toString(),
      eventTypeId: ManyToOne.tryParse(json['event_type_id']),
      tagIds: json['tag_ids'] is List ? List<int>.from(json['tag_ids']) : [],
      organizerId: ManyToOne.tryParse(json['organizer_id']),
      userId: ManyToOne.tryParse(json['user_id']),
      companyId: ManyToOne.tryParse(json['company_id']),
      addressId: ManyToOne.tryParse(json['address_id']),
      websitePublished: json['website_published'] is bool ? json['website_published'] : false,
      websiteVisibility: json['website_visibility']?.toString(),
      seatsLimited: json['seats_limited'] is bool ? json['seats_limited'] : false,
      seatsMax: json['seats_max'] is int ? json['seats_max'] : 0,
      seatsTaken: json['seats_taken'] is int ? json['seats_taken'] : 0,
      badgeFormat: json['badge_format']?.toString(),
      badgeImage: json['badge_image']?.toString(),
      note: json['note']?.toString(),
      ticketInstructions: json['ticket_instructions']?.toString(),
      tickets: json['event_ticket_ids'] is List
          ? (json['event_ticket_ids'] as List)
              .map((t) => EventTicket.fromJson(t is Map<String, dynamic> ? t : {}))
              .toList()
          : [],
      questions: json['question_ids'] is List
          ? (json['question_ids'] as List)
              .map((q) => EventQuestion.fromJson(q is Map<String, dynamic> ? q : {}))
              .toList()
          : [],
    );
  }
}

class EventTicket {
  final int id;
  final String name;
  final ManyToOne? productId;
  final String? description;
  final double price;
  final DateTime? startSaleDatetime;
  final DateTime? endSaleDatetime;
  final int seatsMax;
  final int seatsReserved;

  EventTicket({
    required this.id,
    required this.name,
    this.productId,
    this.description,
    this.price = 0.0,
    this.startSaleDatetime,
    this.endSaleDatetime,
    this.seatsMax = 0,
    this.seatsReserved = 0,
  });

  factory EventTicket.fromJson(Map<String, dynamic> json) {
    return EventTicket(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      productId: ManyToOne.tryParse(json['product_id']),
      description: json['description']?.toString(),
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      startSaleDatetime: json['start_sale_datetime'] != null && json['start_sale_datetime'] != false
          ? DateTime.tryParse(json['start_sale_datetime'].toString())
          : null,
      endSaleDatetime: json['end_sale_datetime'] != null && json['end_sale_datetime'] != false
          ? DateTime.tryParse(json['end_sale_datetime'].toString())
          : null,
      seatsMax: json['seats_max'] is int ? json['seats_max'] : 0,
      seatsReserved: json['seats_reserved'] is int ? json['seats_reserved'] : 0,
    );
  }
}

class EventQuestion {
  final int id;
  final String title;
  final bool isMandatoryAnswer;
  final bool oncePerOrder;
  final String? questionType;
  final List<EventAnswer> answers;

  EventQuestion({
    required this.id,
    required this.title,
    this.isMandatoryAnswer = false,
    this.oncePerOrder = false,
    this.questionType,
    this.answers = const [],
  });

  factory EventQuestion.fromJson(Map<String, dynamic> json) {
    return EventQuestion(
      id: json['id'] is int ? json['id'] : 0,
      title: json['title']?.toString() ?? '',
      isMandatoryAnswer: json['is_mandatory_answer'] is bool ? json['is_mandatory_answer'] : false,
      oncePerOrder: json['once_per_order'] is bool ? json['once_per_order'] : false,
      questionType: json['question_type']?.toString(),
      answers: json['answer_ids'] is List
          ? (json['answer_ids'] as List)
              .map((a) => EventAnswer.fromJson(a is Map<String, dynamic> ? a : {}))
              .toList()
          : [],
    );
  }
}

class EventAnswer {
  final int id;
  final String name;
  final String displayName;

  EventAnswer({
    required this.id,
    required this.name,
    required this.displayName,
  });

  factory EventAnswer.fromJson(Map<String, dynamic> json) {
    return EventAnswer(
      id: json['id'] is int ? json['id'] : 0,
      name: json['name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
    );
  }
}
