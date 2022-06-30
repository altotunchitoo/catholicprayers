// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'days.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Days _$DaysFromJson(Map<String, dynamic> json) => Days(
      DaysData.fromJson(json['data'] as Map<String, dynamic>),
      json['href'] as String,
    );

Map<String, dynamic> _$DaysToJson(Days instance) => <String, dynamic>{
      'data': instance.data.toJson(),
      'href': instance.href,
    };

DaysData _$DaysDataFromJson(Map<String, dynamic> json) => DaysData(
      json['date'] as String,
      json['date_displayed'] as String?,
      json['liturgic_title'] as String?,
      json['special_liturgy'] as String?,
      (json['readings'] as List<dynamic>?)
          ?.map((e) => Readings.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['commentary'] == null
          ? null
          : Commentary.fromJson(json['commentary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DaysDataToJson(DaysData instance) => <String, dynamic>{
      'date': instance.date,
      'date_displayed': instance.dateDisplayed,
      'liturgic_title': instance.liturgicTitle,
      'special_liturgy': instance.specialLiturgy,
      'readings': instance.readings?.map((e) => e.toJson()).toList(),
      'commentary': instance.commentary?.toJson(),
    };

Readings _$ReadingsFromJson(Map<String, dynamic> json) => Readings(
      json['id'] as String,
      json['reading_code'] as String?,
      json['before_reading'] as String?,
      json['chorus'] as String?,
      json['type'] as String?,
      json['audio_url'] as String?,
      json['reference_displayed'] as String?,
      json['text'] as String?,
      json['href'] as String?,
      json['source'] as String?,
      json['book_type'] as String?,
      json['title'] as String?,
    );

Map<String, dynamic> _$ReadingsToJson(Readings instance) => <String, dynamic>{
      'id': instance.id,
      'reading_code': instance.readingCode,
      'before_reading': instance.beforeReading,
      'chorus': instance.chorus,
      'type': instance.type,
      'audio_url': instance.audioUrl,
      'reference_displayed': instance.referenceDisplayed,
      'text': instance.text,
      'href': instance.href,
      'source': instance.source,
      'book_type': instance.bookType,
      'title': instance.title,
    };

Commentary _$CommentaryFromJson(Map<String, dynamic> json) => Commentary(
      json['id'] as String,
      json['title'] as String?,
      json['description'] as String?,
      json['source'] as String?,
      json['href'] as String?,
      json['book_type'] as String?,
    );

Map<String, dynamic> _$CommentaryToJson(Commentary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'source': instance.source,
      'href': instance.href,
      'book_type': instance.bookType,
    };
