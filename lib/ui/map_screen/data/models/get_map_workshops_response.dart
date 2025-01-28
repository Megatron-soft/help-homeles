class GetMapWorkshopsResponse {
  bool? status;
  String? message;
  List<Data>? data;

  GetMapWorkshopsResponse({this.status, this.message, this.data});

  GetMapWorkshopsResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? latitude;
  String? image;
  String? longitude;
  List<Categories>? categories;
  String? address;
  double? distance;

  Data(
      {this.id,
        this.latitude,
        this.longitude,
        this.image,
        this.categories,
        this.address,
        this.distance});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    latitude = json['latitude'];
    image = json['image'];
    longitude = json['longitude'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
    address = json['address'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['latitude'] = this.latitude;
    data['image'] = this.image;
    data['longitude'] = this.longitude;
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    data['address'] = this.address;
    data['distance'] = this.distance;
    return data;
  }
}

class Categories {
  int? id;
  dynamic name;

  Categories({this.id, this.name});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}
