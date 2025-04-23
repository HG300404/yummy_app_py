import 'package:flutter/material.dart';
import 'package:food_app/constants.dart';


class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late TextEditingController _searchController;
  late List<Map<String, dynamic>> searchResults;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    searchResults = _getSearchResults(widget.query);
  }

  void _performSearch(String query) {
    setState(() {
      searchResults = _getSearchResults(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm...',
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
          style: TextStyle(color: Constants.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Constants.white),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          var result = searchResults[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        result['avatar'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result['name'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Constants.textColor),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  "${result['rating']}",
                                  style: TextStyle(fontSize: 16, color: Constants.textColor),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${result['distance']}km",
                                  style: TextStyle(fontSize: 16, color: Constants.textColor),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "${result['time']} phút",
                                  style: TextStyle(fontSize: 16, color: Constants.textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result['dishes'].map<Widget>((dish) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 60),
                            Image.asset(
                              dish['image'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dish['name'],
                                    style: TextStyle(fontSize: 17, color: Constants.textColor),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    "${dish['price']}đ",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Constants.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSearchResults(String query) {
    // Dữ liệu giả dựa trên từ khóa tìm kiếm
    if (query.toLowerCase().contains("ga ran")) {
      return [
        {
          "name": "Gà Rán KFC",
          "avatar": "assets/images/res_1.png",
          "rating": 4.8,
          "distance": 1.2,
          "time": 15,
          "dishes": [
            {"name": "Gà rán phần nhỏ", "price": 45000, "image": "assets/images/res_2.png"},
            {"name": "Gà rán phần lớn", "price": 85000, "oldPrice": 100000, "image": "assets/images/res_3.png"},
          ],
        },
        {
          "name": "Gà Rán Lotteria",
          "avatar": "assets/images/res_1.png",
          "rating": 4.7,
          "distance": 1.5,
          "time": 18,
          "dishes": [
            {"name": "Gà rán phần nhỏ", "price": 40000, "image": "assets/images/res_2.png"},
            {"name": "Gà rán phần lớn", "price": 80000, "image": "assets/images/res_3.png"},
          ],
        },
      ];
    } else if (query.toLowerCase().contains("com")) {
      return [
        {
          "name": "Cơm Tấm Sài Gòn",
          "avatar": "assets/images/res_1.png",
          "rating": 4.9,
          "distance": 0.8,
          "time": 20,
          "dishes": [
            {"name": "Cơm tấm đặc biệt", "price": 55000, "image": "assets/images/res_2.png"},
            {"name": "Cơm tấm thường", "price": 35000, "image": "assets/images/res_3.png"},
          ],
        },
      ];
    } else {
      return [
        {
          "name": "Bếp Quê - Bún Đậu Mắm Tôm",
          "avatar": "assets/images/cat_3.png",
          "rating": 4.9,
          "distance": 0.7,
          "time": 22,
          "dishes": [
            {"name": "Bún đậu mắm tôm - nhỏ", "price": 29000, "image": "assets/images/res_1.png"},
            {"name": "Bún đậu mắm tôm - đặc biệt", "price": 43500, "oldPrice": 58000, "image": "assets/images/cat_4.png"},
          ],
        },
        {
          "name": "BiBi - Bún Đậu Mắm Tôm",
          "avatar": "assets/images/item_3.png",
          "rating": 4.9,
          "distance": 0.7,
          "time": 20,
          "dishes": [
            {"name": "Bún đậu mắm tôm - phần nhỏ", "price": 30000, "image": "assets/images/item_1.png"},
            {"name": "Bún đậu thập cẩm (đủ topping)", "price": 38000, "image": "assets/images/item_2.png"},
          ],
        },
      ];
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: SearchResultsPage(query: ''),
  ));
}
