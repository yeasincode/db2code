#/usr/bin/perl
package JavaBean;
use Utils;
use v5.18.0;
use Encode;
my $fieldTemplate='
/**
*{comment}
*/
private {type} {name};
';

sub path{}

sub process{
  my $context=shift;
  my @tables=$context->tables_map();
  foreach my $row (@tables){
    my $content='';
    my $tableId=$row->{id};
    my $className=$row->{pascalCaseName};
    Encode::_utf8_on($className);
    $content.="public class $className\{
";
    my @columns=$context->columns_map($tableId);
    foreach my $column (@columns){
      my $filedContent=$fieldTemplate;
      $filedContent=~s/{comment}/$column->{comment}/g;
      $filedContent=~s/{type}/$column->{type}/g;
      $filedContent=~s/{name}/$column->{camelName}/g;
      $content.=$filedContent;
    }

    $content.="
\}"; 
    say $content;

    #$context->saveTo($content,$row->{pascalCaseName}.".java")
  }

  
}