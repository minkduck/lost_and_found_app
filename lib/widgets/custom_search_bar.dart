import 'package:flutter/material.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';

class CustomSearchBar extends StatefulWidget {
  final String filterText;
  final Function(String) onFilterTextChanged;
  final Function() onSubmitted;

  CustomSearchBar({
    required this.filterText,
    required this.onFilterTextChanged,
    required this.onSubmitted,
  });

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool isSearching = false;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _textController.text = widget.filterText; // Set the text controller value

    return AnimatedContainer(
      duration: Duration(milliseconds: 500), // Adjust the duration as needed
      curve: Curves.easeInOut, // Adjust the curve as needed
      width: isSearching ? AppLayout.getWidth(320) : AppLayout.getWidth(48), // Adjust the width values
      decoration: BoxDecoration(
        color: AppColors.primaryColor, // Customize the background color
        borderRadius: BorderRadius.circular(isSearching ? 30 : 24), // Customize the border radius
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500), // Adjust the duration as needed
            child: isSearching
                ? IconButton(
              key: ValueKey('clear-icon'),
              icon: Icon(Icons.clear, color: Colors.white), // Customize clear button icon
              onPressed: () {
                setState(() {
                  isSearching = false;
                  _textController.clear(); // Clear the text controller
                  widget.onFilterTextChanged(''); // Clear the filter text
                });
              },
            )
                : IconButton(
              key: ValueKey('search-icon'),
              icon: Icon(Icons.search, color: Colors.white), // Customize search icon
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
          ),
          Expanded(
            child: isSearching
                ? TextField(
              controller: _textController, // Bind the controller
              onChanged: widget.onFilterTextChanged, // Update filter text
              autofocus: true,
              onSubmitted: (value) {
                setState(() {
                  isSearching = false;
                  widget.onSubmitted();
                });
              },
              style: TextStyle(color: Colors.white), // Customize text color
              decoration: InputDecoration(
                hintText: "Search Text...",
                hintStyle: TextStyle(color: Colors.white), // Customize hint text color
                border: InputBorder.none, // Remove the input border
              ),
            )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

