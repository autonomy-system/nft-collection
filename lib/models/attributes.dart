class Attributes {
  bool? scrollable;
  Attributes({
    this.scrollable,
  });

  Attributes copyWith({
    bool? scrollable,
  }) {
    return Attributes(
      scrollable: scrollable ?? this.scrollable,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scrollable': scrollable,
    };
  }

  factory Attributes.fromJson(Map<String, dynamic> map) {
    return Attributes(
      scrollable: map['scrollable'] != null ? map['scrollable'] as bool : null,
    );
  }

  @override
  String toString() => 'Attributes(scrollable: $scrollable)';

  @override
  bool operator ==(covariant Attributes other) {
    if (identical(this, other)) return true;

    return other.scrollable == scrollable;
  }

  @override
  int get hashCode => scrollable.hashCode;
}
