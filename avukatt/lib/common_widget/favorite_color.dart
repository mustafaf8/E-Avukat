import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback onFavoriteChanged;

  const FavoriteButton({
    Key? key,
    required this.isFavorited,
    required this.onFavoriteChanged,
  }) : super(key: key);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorited;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorited ? Icons.star : Icons.star_border,
        color: _isFavorited ? const Color.fromARGB(255, 255, 154, 59) : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          _isFavorited = !_isFavorited;
        });
        widget.onFavoriteChanged();
      },
    );
  }
}
