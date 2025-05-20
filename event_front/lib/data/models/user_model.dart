class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String status;
  final String? phoneNumber;
  final String? organizationName;
  final String? address;
  final String? website;
  final List<String>? socialLinks;
  final String? about;
  final String? experience;
  final List<String>? eventCategories;
  final String? logo;
  final String? serviceProvided;
  final List<Document>? docs;
  final double? rating;
  final String? price;
  final List<PortfolioItem>? portfolio;
  final String? description;
  final String? availability;
  final String? location;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.status,
    this.phoneNumber,
    this.organizationName,
    this.address,
    this.website,
    this.socialLinks,
    this.about,
    this.experience,
    this.eventCategories,
    this.logo,
    this.serviceProvided,
    this.docs,
    this.rating,
    this.price,
    this.portfolio,
    this.description,
    this.availability,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      avatar: json['avatar']?.toString(),
      status: json['status']?.toString() ?? 'active',
      phoneNumber: json['phoneNumber']?.toString(),
      organizationName: json['organizationName']?.toString(),
      address: json['address']?.toString(),
      website: json['website']?.toString(),
      socialLinks: (json['socialLinks'] as List<dynamic>?)?.cast<String>(),
      about: json['about']?.toString(),
      experience: json['experience']?.toString(),
      eventCategories: (json['eventCategories'] as List<dynamic>?)?.cast<String>(),
      logo: json['logo']?.toString(),
      serviceProvided: json['serviceProvided']?.toString(),
      docs: (json['docs'] as List<dynamic>?)
          ?.map((doc) => Document.fromJson(doc as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num?)?.toDouble(),
      price: json['price']?.toString(),
      portfolio: (json['portfolio'] as List<dynamic>?)
          ?.map((item) => PortfolioItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      description: json['description']?.toString(),
      availability: json['availability']?.toString(),
      location: json['location']?.toString(),
    );
  }
}

class Document {
  final String url;
  final String type;
  final String? previewUrl;

  Document({
    required this.url,
    required this.type,
    this.previewUrl,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      previewUrl: json['previewUrl']?.toString(),
    );
  }
}

class PortfolioItem {
  final String? title;
  final String? image;
  final String? description;

  PortfolioItem({
    this.title,
    this.image,
    this.description,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      title: json['title']?.toString(),
      image: json['image']?.toString(),
      description: json['description']?.toString(),
    );
  }
}