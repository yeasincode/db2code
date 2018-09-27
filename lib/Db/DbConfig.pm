#!/usr/bin/perl 
package Db::DbConfig;
use DBI;
use strict;
use v5.18.0;
use Db::DbType::Lang::JavaMap;
# 驱动程序对象的句柄
my %dsn_map=(
  mysql=>'DBI:mysql:database={db};host={host}',
  sqlserver=>'DBI:ODBC:driver={SQL Server};Server={host};Database={db};',
  oracle=>'DBI:Oracle:host={host};service_name={db}'
);

my %table_sql_map=(
  mysql=>'select table_name as tableId,table_name as tableName,table_comment as tableComment
      from information_schema.tables 
      where table_schema={db}',
  sqlserver=>'',
  oracle=>''
);

my %column_sql_map=(
  mysql=>"select col.column_name as `name`, 
       col.data_type  as `type`, 
       col.character_maximum_length as `length`, 
       col.numeric_precision             as `precision`, 
       col.numeric_scale as `isScale`,
       col.is_nullable as `isNull`,
       if(col.column_key='pri',1 , 0) as `isPrimaryKey`,
       col.column_comment as `coment`,
	   if(col.extra='auto_increment',1,0) as `isIdentity` 
from information_schema.columns col where table_schema={db} and col.table_name={tableId}",
  sqlserver=>'',
  oracle=>''
);

sub format_sql{
  my ($sql,$hash)=@_;
  while(my ($k,$v)=each %{$hash}){
    $sql=~s/\{$k\}/'$v'/g;
  }
  $sql;
}

#host db username password dbtype tableNames
sub new{
  my $class=shift;
  my $self={
      host=>shift,
      db=>shift,
      username=>shift,
      password=>shift,
      dbtype=>shift
  };
  bless $self,$class;
  $self; 
}

sub getConnect{
  my $self=shift;
  my $dsn=$dsn_map{$self->{dbtype}};
  $dsn=~s/\{host\}/$self->{host}/;
  $dsn=~s/\{db\}/$self->{db}/;

  my $dbh=DBI->connect($dsn,$self->{username},$self->{password}) or die "couldn't open database: DBI->errstr";
  $dbh->do("SET NAMES utf8");
  if ($dbh->err()) { 
    die "$DBI::errstr\n"; 
  }
  return $dbh;
}

sub getTables{
  my $self=shift;
  my $dbh=$self->getConnect;
  my @tableNames=();
  my $sql=format_sql($table_sql_map{$self->{dbtype}},{db=>$self->{db}});
  my $sth = $dbh->prepare($sql);
  $sth->execute;
  while(my $row = $sth->fetchrow_hashref){
    unless($row->{tableName}=~/[a-zA-Z_]/){
        say "error table name to used,it will be pass!";
        next;
    }
    push @tableNames,{
        tableId=>$row->{tableId},
        tableName=>$row->{tableName},
        tableComment=>$row->{tableComment}
      };
  }
  $sth->finish();
  return @tableNames;
}

sub getColumns{
  my ($self,$tableId)=@_;
  my @tableColumns=();
  my $sqlMap=Db::DbType::Lang::JavaMap->new($self->{dbtype});
  my $lang=$sqlMap->lang;
  my $dbh=$self->getConnect;
  my $sql=format_sql($column_sql_map{$self->{dbtype}},{db=>$self->{db},tableId=>$tableId});
  my $sth = $dbh->prepare($sql);
  $sth->execute;
  while(my $row = $sth->fetchrow_hashref){
    my ($package,$type)=$sqlMap->mapTo($row->{type});
    push @tableColumns,{
        name=>$row->{name},
        type=>$row->{type},
        length=>$row->{length},
        precision=>$row->{precision},
        isScale=>$row->{isScale},
        isNull=>$row->{isNull},
        isPrimaryKey=>$row->{isPrimaryKey},
        coment=>$row->{coment},
        isIdentity=>$row->{isIdentity},
        lang=>$lang,
        langPackage=>$package,
        langType=>$type
      };
  }
  $sth->finish();
  return @tableColumns;
}
