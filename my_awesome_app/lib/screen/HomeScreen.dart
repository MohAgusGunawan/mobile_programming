// import 'package:flutter/material.dart';
// import 'package:my_awesome_app/service/movie.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final MovieService movieService = MovieService();
//   List<Movie> movies = [];

//   @override
//   void initState() {
//     super.initState();
//     loadMovies();
//   }

//   Future<void> loadMovies() async {
//     final movies = await movieService.getPopularMovies();
//     setState(() {
//       this.movies = movies;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Popular Movies')),
//       body: ListView.builder(
//         itemCount: movies.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(movies[index].tittle),
//             onTap: () {
//               Navigator.pushNamed(context, '/detail', arguments: movies[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }
