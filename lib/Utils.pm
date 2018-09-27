#!/usr/bin/perl -w
package Utils;
use v5.18.0;
use Data::Dumper;
my %javaTypeMap=(
  varchar=>["java.lang.String","String"],
  char=>["java.lang.String","String"],
  blob=>["java.lang.byte[]","byte[]"],
  text=>["java.lang.String","String"],
  integer=>["java.lang.Long","Long"],
  tinyint=>["java.lang.Integer","Integer"],
  smallint=>["java.lang.Integer","Integer"],
  mediumint=>["java.lang.Integer","Integer"],
  bit=>["java.lang.Boolean","Boolean"],
  bigint=>["java.math.BigInteger","BigInteger"],
  float=>["java.lang.Float","Float"],
  double=>["java.lang.Double","Double"],
  decimal=>["java.math.BigDecimal","BigDecimal"],
  boolean=>["java.lang.Boolean","Boolean"],
  date=>["java.sql.Date","Date"],
  time=>["java.sql.Time","Time"],
  datetime=>["java.sql.Timestamp","Timestamp"],
  timestamp=>["java.sql.Timestamp","Timestamp"],
  year=>["java.sql.Date","Date"]
);

sub camelStyle{
  my $word=lc(shift);
  $word=~s/\_[a-z]/\U$&/g;
  $word=~s/\_//g;
  $word;
}

sub pascalCaseStyle{
  my $word=lc(shift);
  $word=~s/^[a-z]/\U$&/;
  $word=~s/\_[a-z]/\U$&/g;
  $word=~s/\_//g;
  $word;
}

sub mysqlMapJava{
  my $type=shift;
  my $arr=$javaTypeMap{$type};
  return @{$arr} if $arr;
  return ($type,$type);
}

1;