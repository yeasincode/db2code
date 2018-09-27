#!/usr/bin/perl -w
package Utils;
use v5.18.0;
use Data::Dumper;

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

1;