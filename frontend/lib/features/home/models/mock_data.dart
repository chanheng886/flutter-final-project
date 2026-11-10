class MockData {
  const MockData({required this.title, required this.subTitle});

  final String title;
  final String subTitle;

  static const List<MockData> mockData = [
    MockData(title: 'Project Report.pdf', subTitle: '18 Sep 2025  2.4MB'),

    MockData(title: 'Receipt Photo.pdf', subTitle: '17 Sep 2025  1.1MB'),
    MockData(title: 'ឯកសារដ្ឋបាល.pdf', subTitle: '16 Sep 2025  860KB'),
  ];
}
