import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CinéVerse',
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
        title: Text('CinéVerse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Rechercher des films'),
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
                          builder: (context) => MoviesDetailFilms(movie: _movies[index]),
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




// Class pour afficher les détails des films

class MoviesDetailFilms extends StatefulWidget {
  final Movie movie;

  MoviesDetailFilms({required this.movie});

  @override
  _MoviesDetailFilmsState createState() => _MoviesDetailFilmsState();
}

class _MoviesDetailFilmsState extends State<MoviesDetailFilms> {
  Map<String, dynamic>? _movieDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _MoviesDetailPlus(widget.movie.imdbID);
  }

  Future<void> _MoviesDetailPlus(String imdbID) async {
    const apiKey = 'a9cf029';
    final apiUrl = 'http://www.omdbapi.com/?apikey=$apiKey&i=$imdbID';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _movieDetails = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load movie details');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _movieDetails != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.network(
                          _movieDetails!['Poster'],
                          height: 300,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 100);
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      
                      // Center le texte en gras 
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          _movieDetails!['Title'],
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8.0),
                      Text('Année: ${_movieDetails!['Year']}'),
                      const SizedBox(height: 7.0),
                      Text('Type: ${_movieDetails!['Genre']}'),
                      const SizedBox(height: 7.0),
                      Text('Réalisateur: ${_movieDetails!['Director']}'),
                      const SizedBox(height: 7.0),
                      Text('Prix: ${_movieDetails!['Awards']}'),
                      const SizedBox(height: 7.0),
                      Text('Temps: ${_movieDetails!['Runtime']}'),
                      const SizedBox(height: 16.0),


                       // Center le texte en gras 
                      const Center(
                        child: Text(
                          'Résumé :',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(_movieDetails!['Plot']),
                    ],
                  ),
                )
              : const Center(child: Text('Failed to load movie details')),
    );
  }
}

