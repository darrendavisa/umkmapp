class PaginatedResult<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;

  PaginatedResult({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonItem,
  ) {
    final items = (json['data'] as List<dynamic>? ?? [])
        .map((e) => fromJsonItem(e as Map<String, dynamic>))
        .toList();
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedResult(
      data: items,
      page: meta['page'] as int? ?? 1,
      limit: meta['limit'] as int? ?? items.length,
      total: meta['total'] as int? ?? items.length,
    );
  }

  bool get masihAdaHalamanBerikutnya => page * limit < total;
}