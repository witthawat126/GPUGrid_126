class GpuJob {
  final String? id;
  final String experimentName;
  final String framework;
  final String researcherEmail;
  final int allocatedGpus;
  final int maxComputeHours;

  GpuJob({
    this.id,
    required this.experimentName,
    required this.framework,
    required this.researcherEmail,
    required this.allocatedGpus,
    required this.maxComputeHours,
  });

  Map<String, dynamic> toMap() {
    return {
      'experimentName': experimentName,
      'framework': framework,
      'researcherEmail': researcherEmail,
      'allocatedGpus': allocatedGpus,
      'maxComputeHours': maxComputeHours,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory GpuJob.fromMap(String id, Map<String, dynamic> map) {
    return GpuJob(
      id: id,
      experimentName: map['experimentName'] ?? '',
      framework: map['framework'] ?? '',
      researcherEmail: map['researcherEmail'] ?? '',
      allocatedGpus: (map['allocatedGpus'] ?? 0) is int 
          ? map['allocatedGpus'] 
          : int.tryParse(map['allocatedGpus'].toString()) ?? 0,
      maxComputeHours: (map['maxComputeHours'] ?? 0) is int 
          ? map['maxComputeHours'] 
          : int.tryParse(map['maxComputeHours'].toString()) ?? 0,
    );
  }
}