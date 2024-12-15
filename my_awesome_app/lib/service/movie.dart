import 'dart:convert';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String tittle;
  final String overview;
  final String poster_path;

  Movie(
      {required this.id,
      required this.tittle,
      required this.overview,
      required this.poster_path});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
        id: json['id'],
        tittle: json['tittle'],
        overview: json['overview'],
        poster_path: json['poster_path']);
  }
}

class MovieService {
  final String apiKey = '5da99474acb8c719807edd4b7fd606a3';
  final String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getPopularMovies() async {
    final response =
        await http.get(Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final List<dynamic> result = jsonDecode(response.body)['results'];
      return result.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }
}
