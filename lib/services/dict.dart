/// This file contains the dictionary service.
/// It is used to get the meaning of a word from the dictionary api.
///
/// All the models are defined according to the API response.
/// More info: https://api.dictionaryapi.dev

import 'dart:convert';

import 'package:http/http.dart';

class Dictionary {
  String word;

  Future<Word?> getWord() async {
    final r = await get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );
    if (r.statusCode != 200) {
      return null;
    }
    final List<dynamic> json = jsonDecode(r.body) as List<dynamic>;
    return Word.fromJson(json[0]);
  }

  Dictionary(this.word);

  static Future<bool> existingWord(String word) async {
    final r = await get(
      Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
    );
    return r.statusCode == 200;
  }
}

class Word {
  String word;
  List<Phonetic>? phonetics;
  List<Meaning>? meanings;
  License? license;
  List<String>? sourceUrls;

  Word({
    required this.word,
    this.phonetics,
    this.meanings,
    this.license,
    this.sourceUrls,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['word'],
      phonetics: List<Phonetic>.from(
        json['phonetics'].map(
          (x) => Phonetic.fromJson(x),
        ),
      ),
      meanings: List<Meaning>.from(
        json['meanings'].map(
          (x) => Meaning.fromJson(x),
        ),
      ),
      license: License.fromJson(json['license']),
      sourceUrls: List<String>.from(json['sourceUrls']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['word'] = word;
    data['phonetics'] = phonetics!.map((x) => x.toJson()).toList();
    data['meanings'] = meanings!.map((x) => x.toJson()).toList();
    data['license'] = license!.toJson();
    data['sourceUrls'] = sourceUrls;
    return data;
  }

  String formattedFirstMeaning() {
    String formatted = '<b>$word</b>';
    final meaning = meanings!.first;
    formatted += ' - <i>${meaning.partOfSpeech}</i>\n\n';
    formatted +=
        '<b>Definition</b>: ${meaning.definitions.first.definition}\n\n';
    if (meaning.definitions.first.example != null) {
      formatted += 'Example: ${meaning.definitions.first.example}\n\n';
    }
    if (meaning.definitions.first.synonyms.isNotEmpty) {
      formatted +=
          'Synonyms: ${meaning.definitions.first.synonyms.join(', ')}\n\n';
    }

    if (meaning.definitions.first.antonyms.isNotEmpty) {
      formatted +=
          'Antonyms: ${meaning.definitions.first.antonyms.join(', ')}\n\n';
    }

    return formatted;
  }
}

class Phonetic {
  String? text;
  String? audio;
  String? sourceUrl;
  License? license;

  Phonetic({this.text, this.audio, this.sourceUrl, this.license});

  factory Phonetic.fromJson(Map<String, dynamic> json) {
    return Phonetic(
      text: json['text'],
      audio: json['audio'],
      sourceUrl: json['sourceUrl'],
      license:
          json['license'] != null ? License.fromJson(json['license']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['audio'] = audio;
    data['sourceUrl'] = sourceUrl;
    data['license'] = license?.toJson();
    return data;
  }
}

class License {
  String name;
  String url;

  License({required this.name, required this.url});

  factory License.fromJson(Map<String, dynamic> json) {
    return License(
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class Meaning {
  String partOfSpeech;
  List<Definition> definitions;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'],
      definitions: List<Definition>.from(
        json['definitions'].map(
          (x) => Definition.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['partOfSpeech'] = partOfSpeech;
    data['definitions'] = definitions.map((x) => x.toJson()).toList();
    return data;
  }
}

class Definition {
  String definition;
  List<String> synonyms;
  List<String> antonyms;
  String? example;

  Definition({
    required this.definition,
    this.synonyms = const [],
    this.antonyms = const [],
    this.example,
  });

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'],
      synonyms: List<String>.from(json['synonyms']),
      antonyms: List<String>.from(json['antonyms']),
      example: json['example'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['definition'] = definition;
    data['synonyms'] = synonyms;
    data['antonyms'] = antonyms;
    data['example'] = example;
    return data;
  }
}
