import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:sharexev2/config/theme.dart';
import 'package:sharexev2/presentation/widgets/passenger/passenger_trip_card.dart';

/// Passenger History View - Uses SharedPreferences for local storage
class PassengerHistoryView extends StatefulWidget {
  const PassengerHistoryView({super.key});

  @override
  State<PassengerHistoryView> createState() => _PassengerHistoryViewState();
}

class _PassengerHistoryViewState extends State<PassengerHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTripHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTripHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tripsJson = prefs.getString('passenger_trip_history') ?? '[]';
      final trips = List<Map<String, dynamic>>.from(json.decode(tripsJson));
      
      // If no trips exist, show empty state instead of mock data
      if (trips.isEmpty) {
        setState(() {
          _allTrips = [];
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _allTrips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _allTrips = []; // Empty list instead of mock data
        _isLoading = false;
      });
    }
  }

  Future<void> _saveTripHistory(List<Map<String, dynamic>> trips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('passenger_trip_history', json.encode(trips));
  }

  // Remove mock data function - use real data from repository

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Tab bar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.passengerPrimary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.passengerPrimary,
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'Hoàn thành'),
              Tab(text: 'Đã hủy'),
              Tab(text: 'Sắp tới'),
            ],
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTripList(_allTrips),
              _buildTripList(_filterTrips('completed')),
              _buildTripList(_filterTrips('cancelled')),
              _buildTripList(_filterTrips('pending')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> trips) {
    if (trips.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadTripHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildTripCard(trip),
          );
        },
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(trip['status']),
              Text(
                _formatDate(trip['date']),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Route
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.grabGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: Colors.grey.shade300,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.grabOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip['departure'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      trip['destination'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                '${trip['price']}đ',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.passengerPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Driver info and actions
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.passengerPrimary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: AppColors.passengerPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip['driverName'],
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              if (trip['status'] == 'completed') ...[
                if (trip['rating'] == 0)
                  TextButton(
                    onPressed: () => _showRatingDialog(trip),
                    child: const Text('Đánh giá'),
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text('${trip['rating']}'),
                    ],
                  ),
              ] else if (trip['status'] == 'pending') ...[
                TextButton(
                  onPressed: () => _cancelTrip(trip),
                  child: const Text('Hủy chuyến'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'completed':
        color = AppColors.success;
        text = 'Hoàn thành';
        break;
      case 'cancelled':
        color = AppColors.error;
        text = 'Đã hủy';
        break;
      case 'pending':
        color = AppColors.warning;
        text = 'Sắp tới';
        break;
      default:
        color = AppColors.info;
        text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có lịch sử chuyến đi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterTrips(String status) {
    return _allTrips.where((trip) => trip['status'] == status).toList();
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showRatingDialog(Map<String, dynamic> trip) {
    // TODO: Implement rating dialog
  }

  void _cancelTrip(Map<String, dynamic> trip) {
    // TODO: Implement trip cancellation
  }
}
