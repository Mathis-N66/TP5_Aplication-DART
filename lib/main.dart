import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies App',
      debugShowCheckedModeBanner: false,
      home: MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

// Class pour faire afficher les films genre les nom l'année et l'image

class _MovieListScreenState extends State<MovieListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Movie> _movies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Movies'),
              onSubmitted: (value) {
                _searchMovies(value);
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_movies[index].title),
                    subtitle: Text(_movies[index].year),
                    trailing: Text(_movies[index].type),
                    leading: Image.network(_movies[index].image),
                    onTap: () {
                      // Navigate to detail screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailFilms(movie: _movies[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// Systeme API

  Future<void> _searchMovies(String query) async {
    const apiKey = 'a9cf029';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&s=$query';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> movies = data['Search'];

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}

  // Class pour les films

class Movie {
  final String title;
  final String year;
  final String image;
  final String type;
  final String imdbID;

  Movie({required this.title, required this.year, required this.image, required this.type, required this.imdbID});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      year: json['Year'],
      image: json['Poster'],
      type: json['Type'],
      imdbID: json['imdbID'],
    );
  }
}

// Partie pour les details des films
class DetailFilms extends StatefulWidget {
  @override
  _DetailFilmsState createState() => _DetailFilmsState();
}

abstract class _DetailFilmsState extends State<DetailFilms> {
  
  dynamic DetailFilms({required dynamic movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.network(movie.image),
              ),
              const SizedBox(height: 16.0),
              Text(
                textAlign: TextAlign.center,
                'Titre: ${movie.title}',
                style:  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Année de diffusion: ${movie.year}',
                style: const TextStyle(fontSize: 16.0, fontWeight:  FontWeight.bold),
              ),
              Text(
                'Categorie: ${movie.type}',
                style: const TextStyle(fontSize: 16.0, fontWeight:  FontWeight.bold),
              ),
              Text(
                'Description: ${movie.imdbID}',
                style: const TextStyle(fontSize: 16.0),
              ), 
          ],
        ),
      ),
    );
  }

  Future<void> _detailMoviePlus(String imdbID) async {
    const apiKey = 'a9cf029';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&i=$imdbID';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      setState(() {
        _movies = movies.map((movie) => Movie.fromJson(movie)).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }
}