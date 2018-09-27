#/usr/bin/perl
package JavaBean;
use Utils;
use v5.18.0;

my $fieldTemplate='
  /**
  *{comment}
  */
  private {type} {name};

  /**
  *获取{comment}
  */
  public {type} get{pname}(){
    return {name};
  }

  /**
  *设置{comment}
  */
  public void set{pname}({type} {name}){
    this.{name}={name};
  }
';

sub path{}

sub process{
  my $context=shift;
  say "JavaBean process are runing.";
  
  my @tables=$context->tables_map();
  foreach my $row (@tables){
    my $content='';
    my %imports=();
    my $tableId=$row->{id};
    my $className=$row->{pascalCaseName};
    
    say 'Create class:'.$className;
    
    $content.="
public class $className\{
";
    my @columns=$context->columns_map($tableId);
    foreach my $column (@columns){
      my $filedContent=$fieldTemplate;
      my ($packageName,$typeName) =Utils::mysqlMapJava($column->{type});
      $imports{$typeName}=$packageName;
      $filedContent=~s/{comment}/$column->{comment}/g;
      $filedContent=~s/{type}/$typeName/g;
      $filedContent=~s/{name}/$column->{camelName}/g;
      $filedContent=~s/{pname}/$column->{pascalCaseName}/g;
      $content.=$filedContent;
    }

    $content.="
\}"; 

    foreach(keys %imports){
      $content="import $_;
".$content;
    }

    $context->saveTo($content,$row->{pascalCaseName}.".java")
  }

  say "JavaBean process will be stopping.";
}