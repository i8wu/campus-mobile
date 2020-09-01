import 'package:campus_mobile_experimental/core/models/spot_types_model.dart';
import 'package:campus_mobile_experimental/core/services/networking.dart';
import 'dart:convert';

class SpotTypesService {
  SpotTypesService() {
    fetchSpotTypesData();
  }
  bool _isLoading = false;
  Map<String, String> _data;
  DateTime _lastUpdated;
  String _error;
  final NetworkHelper _networkHelper = NetworkHelper();
  final Map<String, String> headers = {
    "accept": "application/json",
  };

  SpotTypeModel _spotTypeModel = SpotTypeModel();

  final String endpoint =
      "https://cqeg04fl07.execute-api.us-west-2.amazonaws.com/spot-types";
  Future<bool> fetchSpotTypesData() async {
    _error = null;
    _isLoading = true;
    try {
      /// fetch data
      String _response = await _networkHelper.fetchData(endpoint);
      _spotTypeModel = spotTypeModelFromJson(_response);
      _isLoading = false;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      return false;
    }
  }

  Map<String, String> get data => _data;
  bool get isLoading => _isLoading;
  String get error => _error;
  DateTime get lastUpdated => _lastUpdated;
  SpotTypeModel get spotTypeModel => _spotTypeModel;
}