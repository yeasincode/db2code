#!/usr/bin/perl 
package Db::DbType::SqlMap;
use v5.18.0;

sub new{
    my $class=shift;
    my $self={
        _lang=>shift,
        _dbtype=>shift,
        _typesMap=>shift
    };
    
    
    bless $self,$class;
}

sub lang{
    my $self=shift;
    return $self->{_lang};
}

sub mapTo{
  my $self=shift;
  my $type=shift;
  my $result=$self->{_typesMap}{$type};
  return @{$result} if $result;
  return ($type,$type);
}

1;