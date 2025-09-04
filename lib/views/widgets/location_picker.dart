import 'package:flutter/material.dart';

class LocationPicker extends StatefulWidget {
  final String title;
  final IconData icon;
  final String hintText;
  final Function(String) onLocationSelected;
  final String? initialValue;

  const LocationPicker({
    Key? key,
    required this.title,
    required this.icon,
    required this.hintText,
    required this.onLocationSelected,
    this.initialValue,
  }) : super(key: key);

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _locations = [
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bạc Liêu',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cần Thơ',
    'Cao Bằng',
    'Đà Nẵng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Nội',
    'Hà Tĩnh',
    'Hải Dương',
    'Hải Phòng',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'TP Hồ Chí Minh',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];
  List<String> _filteredLocations = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
    }

    _filteredLocations = _locations;

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
    });

    _controller.addListener(() {
      _filterLocations();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterLocations() {
    if (_controller.text.isEmpty) {
      setState(() {
        _filteredLocations = _locations;
      });
    } else {
      setState(() {
        _filteredLocations =
            _locations
                .where(
                  (location) => location.toLowerCase().contains(
                    _controller.text.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  void _selectLocation(String location) {
    _controller.text = location;
    widget.onLocationSelected(location);
    setState(() {
      _showSuggestions = false;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  _filterLocations();
                },
                onTap: () {
                  setState(() {
                    _showSuggestions = true;
                  });
                },
              ),
            ),
          ],
        ),
        if (_showSuggestions && _filteredLocations.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(left: 32),
            height: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  dense: true,
                  title: Text(_filteredLocations[index]),
                  onTap: () => _selectLocation(_filteredLocations[index]),
                );
              },
            ),
          ),
      ],
    );
  }
}
