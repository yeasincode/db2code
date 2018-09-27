#!/usr/bin/perl 
package Db::DbType::Lang::JavaMap;
use v5.18.0;
use Db::DbType::SqlMap;
use Data::Dumper;
our @ISA = ('Db::DbType::SqlMap');

my %dbsMap=(
  mysql=>{
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
  }
);

sub new{
    my $class=shift;
    my $dbtype=shift;
    my $self=Db::DbType::SqlMap->new('java',$dbtype,$dbsMap{$dbtype});
    bless $self;
    return $self;
}

1;
