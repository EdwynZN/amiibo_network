sealed class AffiliationFailure {
  const AffiliationFailure();
}

class NoAffiliationTag extends AffiliationFailure {
  const NoAffiliationTag();

  @override
  String toString() => 'No Amazon Afiliation tag';
}

class NoAffiliationLink extends AffiliationFailure {
  const NoAffiliationLink();

  @override
  String toString() => 'No links match this search';
}

class NoAmiiboFound extends AffiliationFailure {
  final int id;

  const NoAmiiboFound(this.id);

  @override
  String toString() => 'No Amiibo with id $id';
}
