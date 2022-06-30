import 'package:json_annotation/json_annotation.dart';

part 'days.g.dart';

@JsonSerializable(explicitToJson: true)
class Days {
  Days(this.data, this.href);

  DaysData data;
  String href;

  factory Days.fromJson(Map<String, dynamic> json) => _$DaysFromJson(json);

  Map<String, dynamic> toJson() => _$DaysToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DaysData {
  DaysData(this.date, this.dateDisplayed, this.liturgicTitle,
      this.specialLiturgy, this.readings, this.commentary);

  String date;
  @JsonKey(name: "date_displayed")
  String? dateDisplayed;
  @JsonKey(name: "liturgic_title")
  String? liturgicTitle;
  @JsonKey(name: "special_liturgy")
  String? specialLiturgy;
  List<Readings>? readings;
  Commentary? commentary;

  factory DaysData.fromJson(Map<String, dynamic> json) =>
      _$DaysDataFromJson(json);

  Map<String, dynamic> toJson() => _$DaysDataToJson(this);
}

@JsonSerializable()
class Readings {
  Readings(
      this.id,
      this.readingCode,
      this.beforeReading,
      this.chorus,
      this.type,
      this.audioUrl,
      this.referenceDisplayed,
      this.text,
      this.href,
      this.source,
      this.bookType,
      this.title);

  String id;
  @JsonKey(name: "reading_code")
  String? readingCode;
  @JsonKey(name: "before_reading")
  String? beforeReading;
  String? chorus;
  String? type;
  @JsonKey(name: "audio_url")
  String? audioUrl;
  @JsonKey(name: "reference_displayed")
  String? referenceDisplayed;
  String? text;
  String? href;
  String? source;
  @JsonKey(name: "book_type")
  String? bookType;
  String? title;

  factory Readings.fromJson(Map<String, dynamic> json) =>
      _$ReadingsFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingsToJson(this);
}

@JsonSerializable()
class Commentary {
  Commentary(this.id, this.title, this.description, this.source, this.href,
      this.bookType);

  String id;
  String? title, description, source, href;
  @JsonKey(name: "book_type")
  String? bookType;

  factory Commentary.fromJson(Map<String, dynamic> json) =>
      _$CommentaryFromJson(json);

  Map<String, dynamic> toJson() => _$CommentaryToJson(this);
}
