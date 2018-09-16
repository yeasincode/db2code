#!/usr/bin/perl -w
package DB::DbConfig;
use DBI;
use strict;
use v5.18.0;
# 驱动程序对象的句柄
my %dsn_map=(
  mysql=>'DBI:mysql:database={db};host={host}',
  sqlserver=>'DBI:ODBC:driver={SQL Server};Server={host};Database={db};',
  oracle=>'DBI:Oracle:host={host};service_name={db}'
);

#host db username password
sub new{
  my $class=shift;
  my $self={
      host=>shift,
      db=>shift,
      username=>shift,
      password=>shift,
      dbtype=>shift,
      tableNames=>[]
  };
  bless $self,$class;
  $self; 
}

sub camelStyle{
  my $word=lc(shift);
  $word=~s/[a-z]/\U/;
  $word=~s/\_[a-z]/\U/;
  $word;
}

sub getConnect{
  my $self=shift;
  my $dsn=$dsn_map{$self->{dbtype}};
  $dsn=~s/\{host\}/$self->{host}/;
  $dsn=~s/\{db\}/$self->{db}/;

  my $dbh=DBI->connect($dsn,$self->{username},$self->{password}) or die "couldn't open database: DBI->errstr";
  if ($dbh->err()) { 
    die "$DBI::errstr\n"; 
  }
  return $dbh;
}

sub tables{
  my $self=shift;
  my $dbh=$self->getConnect;
  my $sth = $dbh->prepare("select table_name as tableId,table_name as tableName 
      from information_schema.tables 
      where table_schema='$self->{db}'");
  $sth->execute;
  while(my $row = $sth->fetchrow_hashref){
    push @{$self->{tableNames}},{tableId=>$row->{tableId},tableName=>$row->{tableName}};
  }

  $sth->finish();

}

sub columns{
  my ($self,$tableId)=@_;
  my @tableColumns=();
  my $dbh=$self->getConnect;
  my $sth = $dbh->prepare("select col.column_name as `name`, 
       col.data_type  as `type`, 
       col.character_maximum_length as `length`, 
       col.numeric_precision             as `precision`, 
       col.numeric_scale as `isScale`,
       col.is_nullable as `Isnull`,
       if(col.column_key='pri',1 , 0) as `isPrimaryKey`,
       col.column_comment as `coment`,
	   if(col.extra='auto_increment',1,0) as `isIdentity` 
from information_schema.columns col where table_schema='$self->{db}' and col.table_name='$tableId'");
  $sth->execute;
  while(my $row = $sth->fetchrow_hashref){
    push @tableColumns,{name=>$row->{name},type=>$row->{type},length=>$row->{length},precision=>$row->{precision},isScale=>$row->{isScale},Isnull=>$row->{Isnull},isPrimaryKey=>$row->{isPrimaryKey},coment=>$row->{coment},isIdentity=>$row->{isIdentity}};
  }

  $sth->finish();
  foreach(@tableColumns){
    print camelStyle lc($_->{name})."\n";
  }
}
