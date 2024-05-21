import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/constants.dart';
import 'package:forum/pages/workfield.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';
import '../components/auto_switch_pageview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/localStorage.dart';

class SearchPage extends StatefulWidget {
  final String query;
  SearchPage({super.key, required this.query});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin {
  List<CarouselCard> cards = [
  ];

  List<ContentCard> content_cards = [
  ];
  // SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    getSearchWorks();
    _searchController = SearchController();
    _searchController.addListener(_onQueryChanged);
  }

  void getSearchWorks() async{
    requestGet("/api/search/search_post", {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query:  {
      'content': widget.query,
    }).then((http.Response res) {
      if(res.statusCode == 200){
        content_cards.clear();
        if (json.decode(res.body)['posts'] == null) {
          return;
        }
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString) as Map;
        List posts = body['posts'];
        for(var i in posts){
          requestGet('/api/user/get_user',
              {
                'Authorization': 'Bearer ${LocalStorage.getString('token')}',
              },query: {
                'userId': i['userId']
              }).then((http.Response res2){
            if(res2.statusCode == 200) {
              String decodedString2 = utf8.decode(res2.bodyBytes);
              Map body2 = jsonDecode(decodedString2) as Map;
              ContentCard card = ContentCard(title: i['title'], content: i['content'], postId: i['postId'],avatar: body2['content']['userAvatar'],username: body2['content']['userName'],media_urls: i['urls'].cast<String>(),type: 'home',);
              setState(() {
                content_cards.add(card);
              });
            }
          });
        }
      }

    });
  }

  late SearchController _searchController;



  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    if (_searchController.value.text.isNotEmpty) {
      // Assuming that the user submits with the 'Enter' key
      // This is a simple workaround, better logic might be needed based on your requirements
      if (_searchController.value.text.endsWith('\n')) {
        final query = _searchController.value.text.trim();
        performSearch(query);
      }
    }
  }

  void performSearch(String query) {
    // Do something with the query, e.g., execute the search
    print('Search submitted: $query');
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage(query: query)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(5, 10, 45, 10),
          child: SearchBar(
            controller: _searchController,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onTap: () {

            },
            onSubmitted: (value) {
              performSearch(value);
            },
            leading: const Icon(Icons.search),
            trailing: <Widget>[
              Tooltip(
                message: 'Clear content',
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child:
                    Column(
                      children: [
                        if (content_cards.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'No results found for "${widget.query}"',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        CardList(cards: content_cards,)
                      ],
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
