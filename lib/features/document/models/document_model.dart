class AppDocument {
  final int id;
  final String name;
  final int? ownerId;
  final String? ownerName;
  final int? folderId;
  final String? folderName;
  final List<int> tagIds;
  final List<String> tagNames;
  final int? partnerId;
  final String? partnerName;
  final String? datasFname;
  final String type; // 'binary' or 'url'
  final String? url;
  final String? createByName;
  final String? createDate;
  final String? writeByName;
  final String? writeDate;
  final bool active;
  final String? companyName;
  final String? thumbnail;

  AppDocument({
    required this.id,
    required this.name,
    this.ownerId,
    this.ownerName,
    this.folderId,
    this.folderName,
    this.tagIds = const [],
    this.tagNames = const [],
    this.partnerId,
    this.partnerName,
    this.datasFname,
    required this.type,
    this.url,
    this.createByName,
    this.createDate,
    this.writeByName,
    this.writeDate,
    required this.active,
    this.companyName,
    this.thumbnail,
  });

  factory AppDocument.fromJson(Map<String, dynamic> json) {
    int? oId;
    String? oName;
    if (json['owner_id'] is List && (json['owner_id'] as List).length >= 2) {
      oId = json['owner_id'][0] as int;
      oName = json['owner_id'][1]?.toString();
    }

    int? fId;
    String? fName;
    if (json['folder_id'] is List && (json['folder_id'] as List).length >= 2) {
      fId = json['folder_id'][0] as int;
      fName = json['folder_id'][1]?.toString();
    }

    int? pId;
    String? pName;
    if (json['partner_id'] is List && (json['partner_id'] as List).length >= 2) {
      pId = json['partner_id'][0] as int;
      pName = json['partner_id'][1]?.toString();
    }

    String? cByName;
    if (json['create_uid'] is List && (json['create_uid'] as List).length >= 2) {
      cByName = json['create_uid'][1]?.toString();
    }

    String? wByName;
    if (json['write_uid'] is List && (json['write_uid'] as List).length >= 2) {
      wByName = json['write_uid'][1]?.toString();
    }

    String? compName;
    if (json['company_id'] is List && (json['company_id'] as List).length >= 2) {
      compName = json['company_id'][1]?.toString();
    }

    return AppDocument(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      ownerId: oId,
      ownerName: oName,
      folderId: fId,
      folderName: fName,
      tagIds: json['tag_ids'] is List ? List<int>.from(json['tag_ids']) : const [],
      tagNames: const [],
      partnerId: pId,
      partnerName: pName,
      datasFname: json['datas_fname']?.toString() ?? json['name']?.toString(),
      type: json['type']?.toString() ?? 'binary',
      url: json['url']?.toString(),
      createByName: cByName,
      createDate: json['create_date']?.toString(),
      writeByName: wByName,
      writeDate: json['write_date']?.toString(),
      active: json['active'] == true,
      companyName: compName,
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
