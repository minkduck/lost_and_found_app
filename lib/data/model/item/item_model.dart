class Item {
  Pagination? pagination;
  List<Result>? result;
  List<dynamic>? errors;
  int? statusCode;
  bool? isError;
  String? message;

  Item({
    this.pagination,
    this.result,
    this.errors,
    this.statusCode,
    this.isError,
    this.message,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      pagination: Pagination.fromJson(json['pagination']),
      result: (json['result'] as List<dynamic>)
          .map((item) => Result.fromJson(item))
          .toList(),
      errors: (json['errors'] as List<dynamic>?), // Corrected this line
      statusCode: json['statusCode'],
      isError: json['isError'],
      message: json['message'],
    );
  }
}

class Pagination {
  int? totalCount;
  int? maxPageSize;
  int? currentPage;
  int? totalPages;
  bool? hasNext;
  bool? hasPrevious;

  Pagination({
    this.totalCount,
    this.maxPageSize,
    this.currentPage,
    this.totalPages,
    this.hasNext,
    this.hasPrevious,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalCount: json['totalCount'],
      maxPageSize: json['maxPageSize'],
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
    );
  }
}

class Result {
  int? id;
  String? foundUserId;
  String? name;
  String? description;
  String? locationName;
  String? categoryName;
  String? itemStatus;
  String? foundDate;
  String? createdDate;
  User? user;
  List<ItemMedia>? itemMedias;

  Result({
    this.id,
    this.foundUserId,
    this.name,
    this.description,
    this.locationName,
    this.categoryName,
    this.itemStatus,
    this.foundDate,
    this.createdDate,
    this.user,
    this.itemMedias,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'],
      foundUserId: json['foundUserId'],
      name: json['name'],
      description: json['description'],
      locationName: json['LocationName'],
      categoryName: json['categoryName'],
      itemStatus: json['itemStatus'],
      foundDate: json['foundDate'],
      createdDate: json['createdDate'],
      user: User.fromJson(json['user']),
      itemMedias: (json['itemMedias'] as List<dynamic>)
          .map((itemMedia) => ItemMedia.fromJson(itemMedia))
          .toList(),
    );
  }
}

class User {
  String? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? gender;
  String? email;
  String? avatar;
  String? schoolId;
  String? campus;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.fullName,
    this.gender,
    this.email,
    this.avatar,
    this.schoolId,
    this.campus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      gender: json['gender'],
      email: json['email'],
      avatar: json['avatar'],
      schoolId: json['schoolId'],
      campus: json['campus'],
    );
  }
}

class ItemMedia {
  Media? media;

  ItemMedia({
    this.media,
  });

  factory ItemMedia.fromJson(Map<String, dynamic> json) {
    return ItemMedia(
      media: Media.fromJson(json['media']),
    );
  }
}

class Media {
  String? url;

  Media({
    this.url,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      url: json['url'],
    );
  }
}
