part 'expression.dart';

class QueryBuilder{
  Expression where;
  String orderBy;
  String asc;

  QueryBuilder(this.where, [this.orderBy, this.asc = 'ASC']);

  String get order{
    if(this.orderBy == null) return null;
    StringBuffer orderBy = StringBuffer(this.orderBy);
    if(asc?.isNotEmpty ?? false) orderBy..write(' ')..write(asc);
    return orderBy.toString();
  }

}