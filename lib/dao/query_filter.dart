/*
import 'package:jaguar_query/jaguar_query.dart';

abstract class Expression {
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
}
*/

class QueryExpression{
  bool distinct;
  List<String> columns;
  String where;
  List<dynamic> whereArgs;
  String groupBy;
  String having;
  String orderBy;
  int limit;
  int offset;

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }

}

class WhereExpression{
  StringBuffer _buffer = StringBuffer();
  List<dynamic> _args = <dynamic>[];

  String get where => _buffer.toString();
  List<dynamic> get whereArgs => _args;

  /// Adds an AND expression with [other]
  WhereExpression operator &(WhereExpression exp) => _operator(exp, 'AND');
  void and(String arg){
    _buffer.write(' AND $arg');
    _args.add(arg);
  }

  /// Adds an OR expression with [other]
  WhereExpression operator |(WhereExpression exp) => _operator(exp, 'OR');

  /// Adds a LIKE expression with [other]
  WhereExpression operator %(WhereExpression exp) => _operator(exp, 'LIKE');

  WhereExpression _operator(WhereExpression exp, String operator) {
    _buffer.write(' $operator ${exp.where}');
    _args.addAll(exp.whereArgs);
    return this;
  }
}