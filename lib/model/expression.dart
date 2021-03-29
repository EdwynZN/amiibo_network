part of 'search_result.dart';

abstract class Expression extends Equatable {
  const Expression();

  /// Returns the number of sub-expressions this expression has if this expression
  /// is a composite expression
  int get length;

  /// Adds an AND expression with [other]
  And operator &(Expression other) => and(other);
  And and(Expression exp);

  /// Adds an OR expression with [other]
  Or operator |(Expression other) => or(other);
  Or or(Expression exp);

  List<dynamic> get args;
}

class And extends Expression {
  final _expression = <Expression>[];

  int get length => _expression.length;

  List<dynamic> get args {
    if(this._expression.isEmpty) return [];
    List<dynamic> arg = <dynamic>[];
    arg = this._expression.expand((i) => i?.args).toList();
    return arg;
  }

  And and(Expression other){
    if (other is And) {
      _expression.addAll(other._expression);
    } else {
      _expression.add(other);
    }

    return this;
  }

  Or or(Expression other){
    Or ret = Or();
    if (this.length != 0) ret = ret.or(this);
    return ret.or(other);
  }

  @override
  toString(){
    StringBuffer _buffer = StringBuffer();
    _buffer.writeAll(_expression, ' AND ');
    return _buffer.toString();
  }

  @override
  List<Object> get props => _expression;
}

class Or extends Expression{
  final _expression = <Expression>[];

  int get length => _expression.length;

  List<dynamic> get args {
    if(this._expression.isEmpty) return [];
    List<dynamic> arg = <dynamic>[];
    arg = this._expression.expand((i) => i?.args).toList();
    return arg;
  }

  And and(Expression other){
    And ret = And();
    if (this.length != 0) ret = ret.and(this);
    return ret.and(other);
  }

  Or or(Expression other){
    if (other is Or) {
      _expression.addAll(other._expression);
    } else {
      _expression.add(other);
    }

    return this;
  }

  @override
  toString(){
    StringBuffer _buffer = StringBuffer();
    _buffer.writeAll(_expression, ' OR ');
    return _buffer.toString();
  }

  @override
  List<Object> get props => _expression;

}

class Bracket extends Expression{
  final Expression _expression;

  Bracket(this._expression);

  int get length => _expression.length;

  List<dynamic> get args => _expression.args;

  /// Creates a 'logical and' expression of this expression and the [other]
  And and(Expression exp) {
    And ret = And();
    return ret.and(this).and(exp);
  }

  /// Creates a 'logical or' expression of this expression and the [other]
  Or or(Expression exp) {
    Or ret = Or();
    return ret.or(this).or(exp);
  }

  @override
  toString(){
    StringBuffer _buffer = StringBuffer('(');
    _buffer..write(_expression)..write(')');
    return _buffer.toString();
  }

  @override
  List<Object> get props => [_expression];

}

class Cond extends Expression {
  /// The field/column of the condition
  final String field;

  /// The operator of the relational expression
  final String op;

  /// The value of the relational expression the [field] is being compared against
  final String value;

  const Cond._(this.field, this.op, this.value) : assert(field != null), assert(value != null);

  /// Always returns 1 because relational condition is not a composite expressions
  int get length => 1;

  List<dynamic> get args {
    List<dynamic> arg = <dynamic>[];
    return arg..add(value);
  }

  /// Creates a 'logical and' expression of this expression and the [other]
  And and(Expression exp) {
    And ret = And();
    return ret.and(this).and(exp);
  }

  /// Creates a 'logical or' expression of this expression and the [other]
  Or or(Expression exp) {
    Or ret = Or();
    return ret.or(this).or(exp);
  }

  @override
  List<Object> get props => [field, op, value];

  @override
  toString() => args.isEmpty ? '' : '$field $op ?';

  factory Cond.eq(String field, String value) => Cond._(field, '=', value);
  factory Cond.iss(String field, String value) => Cond._(field, 'IS', value);
  factory Cond.isNot(String field, String value) => Cond._(field, 'IS NOT', value);
  factory Cond.ne(String field, String value) => Cond._(field, '!=', value);
  factory Cond.gt(String field, String value) => Cond._(field, '>', value);
  factory Cond.gtEq(String field, String value) => Cond._(field, '>=', value);
  factory Cond.lt(String field, String value) => Cond._(field, '<', value);
  factory Cond.ltEq(String field, String value) => Cond._(field, '>=', value);
  factory Cond.like(String field, String value) => Cond._(field, 'LIKE', value);
  factory Cond.notLike(String field, String value) => Cond._(field, 'NOT LIKE', value);
}

class BetweenCond extends Expression {
  /// The field/column of the condition
  final String field;

  /// The operator of the relational expression
  final String op;

  /// The value of the relational expression the [field] is being compared against
  final double low;

  /// The value of the relational expression the [field] is being compared against
  final double high;

  const BetweenCond._(this.field, this.op, this.low, this.high) :
        assert(low != null),
        assert(high != null),
        assert(low < high);

  /// Always returns 1 because relational condition is not a composite expressions
  int get length => 1;

  List<dynamic> get args {
    List<dynamic> arg = <dynamic>[];
    return arg..add(low)..add(high);
  }

  /// Creates a 'logical and' expression of this expression and the [other]
  And and(Expression exp) {
    And ret = And();
    return ret.and(this).and(exp);
  }

  /// Creates a 'logical or' expression of this expression and the [other]
  Or or(Expression exp) {
    Or ret = Or();
    return ret.or(this).or(exp);
  }

  @override
  List<Object> get props => [field, op, low, high];

  @override
  toString() => args.isEmpty ? '' : '$field $op ? AND ?';

  factory BetweenCond.between(String field, double low, double high) => BetweenCond._(field, 'BETWEEN', low, high);
  factory BetweenCond.notBetween(String field, double low, double high) => BetweenCond._(field, 'NOT BETWEEN', low, high);
}

class InCond extends Expression {
  /// The field/column of the condition
  final String field;

  /// The operator of the relational expression
  final String op;

  /// List of conditions
  final List<dynamic> inside;

  const InCond._(this.field, this.op, this.inside) : assert(inside != null);

  /// Always returns 1 because relational condition is not a composite expressions
  int get length => 1;

  List<dynamic> get args => inside.isEmpty ? [''] : inside;

  /// Creates a 'logical and' expression of this expression and the [other]
  And and(Expression exp) {
    And ret = And();
    return ret.and(this).and(exp);
  }

  /// Creates a 'logical or' expression of this expression and the [other]
  Or or(Expression exp) {
    Or ret = Or();
    return ret.or(this).or(exp);
  }

  @override
  List<Object> get props => [field, op, inside];

  @override
  toString() {
    if(inside.isEmpty) return '$field $op(?)';
    final String args = inside?.skip(1)?.fold<String>('?', (curr, next) => curr + ',?');
    return '$field $op($args)';
  }

  factory InCond.inn(String field, List<dynamic> inside) => InCond._(field, 'IN', inside);
  factory InCond.notInn(String field, List<dynamic> inside) => InCond._(field, 'NOT IN', inside);
}