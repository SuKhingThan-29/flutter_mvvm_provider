import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/data_viewmodel.dart';
import 'login_view.dart';

class DataViewScreen extends StatefulWidget {
  const DataViewScreen({super.key});

  @override
  _DataViewScreenState createState() => _DataViewScreenState();
}

class _DataViewScreenState extends State<DataViewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isLogoutClick=false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Set initialIndex to 1
   // _checkAndRefreshToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pickup on way'),
            Tab(text: 'Pickup completed'),
            Tab(text: 'Pickup cancel'),
          ],
        ),
        actions: [
          GestureDetector(
              onTap: () async {
                isLogoutClick=true;
                await authViewModel.logout(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginView()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 18)),
              )
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PickupComplete(),
          PickupComplete(),
          PickupComplete(),
        ],
      ),

    );
  }
}

class PickupComplete extends StatefulWidget {
  const PickupComplete({super.key});

  @override
  _PickupCompleteState createState() => _PickupCompleteState();
}

class _PickupCompleteState extends State<PickupComplete> {
  final ScrollController _scrollController = ScrollController();
  bool isScroll=false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _scrollController.addListener(_onScroll);
  }
  void _startTimer()async {
    _timer?.cancel(); // Cancel any existing timer
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token= prefs.getString('access_token');
    Provider.of<DataViewModel>(context,listen:false).loadData(token,context);
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      print("Timer 1min: ");
      _onTimerTick();
    });
  }
  void _onTimerTick() {
    // Perform the action you want to trigger every 10 minutes
    Provider.of<DataViewModel>(context,listen:false).checkExpireTime(context);
  }
  @override
  void dispose() {
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    isScroll=true;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      Provider.of<DataViewModel>(context, listen: false).loadMoreData(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final dataViewModel = Provider.of<DataViewModel>(context);

    if (authViewModel.user == null) {
      Future.microtask(() => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginView()),
      ));
    }

    return Scaffold(
      body:  RefreshIndicator(
        onRefresh: () => dataViewModel.refreshData(context),
    child: Consumer<DataViewModel>(
        builder: (context, dataViewModel, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: dataViewModel.data.length + (dataViewModel.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == dataViewModel.data.length) {
                      return Padding(padding: EdgeInsets.all(4),child: Center(child: CircularProgressIndicator()),);
                    }
                    try {
                      final item = dataViewModel.data[index];
                      return Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['trackingId']!,style: TextStyle(color: Colors.blue),),
                                    Text(item['osName']!),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['osTownshipName']!),
                                    Text(item['osPrimaryPhone']!),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(item['pickupDate']!),
                                    Text(item['totalWays']!.toString()+' ways',style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text('${++index} of ${dataViewModel.data.length}')
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } catch (e) {
                      print(e);
                    }

                  },
                ),
              ),
              if (!dataViewModel.hasMore && !isScroll)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('There is no more data'),
                  ),
                ),
            ],
          );

        },
      ),
    )
    );
  }
}
