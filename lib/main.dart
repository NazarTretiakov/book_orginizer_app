import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const BookOrganizerApp());
}

class Book {
  final String title;
  final String author;
  final String genre;
  final String description;
  final int totalPages;
  int pagesRead;
  bool isRead;
  double? rating;

  Book({
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.totalPages,
    this.pagesRead = 0,
    this.isRead = false,
    this.rating,
  });
}

class BookOrganizerApp extends StatelessWidget {
  const BookOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const BookListScreen(title: 'Book Organizer'),
    );
  }
}

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key, required this.title});

  final String title;

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final List<Book> books = [];
  final List<Book> readBooks = [];
  List<Book> filteredBooks = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearchPerformed = false;

  void _addBook(Book book) {
    setState(() {
      books.add(book);
    });
  }

  void _markAsRead(Book book) {
    setState(() {
      books.remove(book);
      book.isRead = true;
      readBooks.add(book);
    });
  }

  void _addRating(Book book, double rating) {
    setState(() {
      book.rating = rating;
    });
  }

  void _updateReadPages(Book book, int pages) {
    setState(() {
      book.pagesRead = pages;
    });
  }

  void _performSearch() {
    setState(() {
      filteredBooks = books.where((book) =>
      book.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
          book.author.toLowerCase().contains(searchController.text.toLowerCase())
      ).toList();
      isSearchPerformed = true;
    });
  }

  void _clearSearch() {
    setState(() {
      searchController.clear();
      filteredBooks.clear();
      isSearchPerformed = false;
    });
  }

  Widget _buildEmptyState(bool isReadList) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isReadList ? Icons.book : Icons.menu_book,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            isReadList
                ? 'No books have been read yet'
                : 'Your reading wishlist is empty',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isReadList
                ? 'Mark the books as read to see them here'
                : 'Tap + to add the new book to your list',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Want to Read'),
              Tab(text: 'Read Books'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildBookList(books, false),
            _buildBookList(readBooks, true),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddBookDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBookList(List<Book> bookList, bool isReadList) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: isSearchPerformed
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                        : null,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _performSearch,
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        Expanded(
          child: (isSearchPerformed ? filteredBooks.isEmpty : bookList.isEmpty)
              ? _buildEmptyState(isReadList)
              : ListView.builder(
            itemCount: isSearchPerformed ? filteredBooks.length : bookList.length,
            itemBuilder: (context, index) {
              Book book = isSearchPerformed ? filteredBooks[index] : bookList[index];

              // Check if book is fully read
              bool isFullyRead = book.pagesRead == book.totalPages;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(book.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.author),
                          const SizedBox(height: 4),
                          Text('Pages: ${book.pagesRead}/${book.totalPages}'),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: book.totalPages > 0
                                ? book.pagesRead / book.totalPages
                                : 0,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isFullyRead ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      trailing: isReadList
                          ? _buildRatingWidget(book)
                          : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFullyRead ? Colors.green : null,
                        ),
                        onPressed: () => _markAsRead(book),
                        child: const Text('Mark as Read'),
                      ),
                      onTap: () => _showBookDetailsDialog(context, book, isReadList),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingWidget(Book book) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < (book.rating ?? 0) ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
          onPressed: () => _addRating(book, index + 1.0),
        );
      }),
    );
  }

  void _showAddBookDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final genreController = TextEditingController();
    final descriptionController = TextEditingController();
    final totalPagesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Book'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Book Title'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter book title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: authorController,
                  decoration: const InputDecoration(hintText: 'Author'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter author name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: genreController,
                  decoration: const InputDecoration(hintText: 'Genre'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter book genre';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please add book description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: totalPagesController,
                  decoration: const InputDecoration(hintText: 'Total Pages'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter total pages';
                    }
                    int? pages = int.tryParse(value);
                    if (pages == null || pages <= 0) {
                      return 'Total pages must be a positive number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newBook = Book(
                  title: titleController.text.trim(),
                  author: authorController.text.trim(),
                  genre: genreController.text.trim(),
                  description: descriptionController.text.trim(),
                  totalPages: int.parse(totalPagesController.text.trim()),
                );
                _addBook(newBook);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showBookDetailsDialog(BuildContext context, Book book, bool isReadList) {
    final pagesReadController = TextEditingController(text: book.pagesRead.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Author: ${book.author}'),
            Text('Genre: ${book.genre}'),
            Text('Description: ${book.description}'),
            const SizedBox(height: 16),
            Text('Total Pages: ${book.totalPages}'),
            const SizedBox(height: 8),
            if (!isReadList)
              TextField(
                controller: pagesReadController,
                decoration: const InputDecoration(
                  labelText: 'Pages Read',
                  helperText: 'Enter the number of pages you have read',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  final pages = int.tryParse(value) ?? 0;
                  if (pages <= book.totalPages) {
                    _updateReadPages(book, pages);
                  }
                },
              ),
            if (isReadList)
              Text('Pages Read: ${book.pagesRead}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: book.totalPages > 0 ? book.pagesRead / book.totalPages : 0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                book.pagesRead == book.totalPages ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${((book.totalPages > 0 ? book.pagesRead / book.totalPages : 0) * 100).toStringAsFixed(1)}% completed',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}