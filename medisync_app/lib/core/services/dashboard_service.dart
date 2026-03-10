import '../services/api_client.dart';

/// Fetches dashboard data from Django REST endpoints.
/// Each method returns the raw JSON map; the dashboards parse it themselves.
class DashboardService {
  final ApiClient _apiClient;

  DashboardService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Map<String, dynamic>> fetchDoctorDashboard() async {
    final response = await _apiClient.dio.get('/dashboard/doctor/');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchHospitalAdminDashboard() async {
    final response = await _apiClient.dio.get('/dashboard/hospital-admin/');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchTechnicianDashboard() async {
    final response = await _apiClient.dio.get('/dashboard/lab-tech/');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchSuperAdminDashboard() async {
    final response = await _apiClient.dio.get('/dashboard/super-admin/');
    return response.data as Map<String, dynamic>;
  }
}
