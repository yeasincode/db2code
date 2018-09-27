#/usr/bin/perl
package CodeIt;
sub rootPath{
    my $path=__FILE__;
    $path=~s/codeIt\.pl//;
    $path=~s/\\/\//g;
    $path; 
}


BEGIN{
    unshift @INC,rootPath.'lib';
}
use v5.18.0;
use Db::DbConfig;
use Config::IniFiles;
use Data::Dumper;
use Path::Class;
use Invoke;
use Utils;

my $templet;
my $path;

sub new{
  my ($class,$db)=@_;
  my $self={
    _db=>$db,
  };

  bless $self,$class;
  $self; 
}

sub tables_map{
   my ($self)=@_;
   my @table_maps=();
   my @tables=$self->{_db}->getTables;
   
   foreach my $row (@tables){
      my $camelName=Utils::camelStyle($row->{tableName});
      my $pascalCaseName=Utils::pascalCaseStyle($row->{tableName});
      push @table_maps,{
        id=>$row->{tableId},
        rawName=>$row->{tableName},
        camelName=>$camelName,
        pascalCaseName=>$pascalCaseName,
        comment=>$row->{tableComment}
      };
   }
   
   return @table_maps;
}

sub columns_map{
  my ($self,$tableId)=@_;
  my @column_maps=();
  my @columns=$self->{_db}->getColumns($tableId);
  foreach my $row (@columns){
     my $camelName=Utils::camelStyle($row->{name});
     my $pascalCaseName=Utils::pascalCaseStyle($row->{name});
     push @column_maps,{
        isIdentity=>$row->{isIdentity},
        rawName=>$row->{name},
        camelName=>$camelName,
        pascalCaseName=>$pascalCaseName,
        type=>$row->{type},
        length=>$row->{length},
        precision=>$row->{precision},
        isScale=>$row->{isScale},
        isNull=>$row->{isNull},
        isPrimaryKey=>$row->{isPrimaryKey},
        comment=>$row->{coment}
      };
  }
   
  return @column_maps;
}

sub saveTo{
  my ($self,$content,$fileName,$subPath)=@_;
  my $newPath=$path;
  if($subPath){
    $newPath=&$subPath($path)||$path;
  }
  
  my $dir=dir($newPath);
  if($dir->is_relative){
      $dir=dir(rootPath(),$newPath);
  }
  $dir->mkpath unless(-d $dir->stringify);
  my $file=file($dir->stringify,$fileName);
  $file->spew(iomode => '>:raw', $content);
}

sub loadFiles{
	my $dir=dir(&rootPath,"$templet");
  my @files=();
  return @files unless -d $dir;
	while(my $file=$dir->next){
		my $fileName=$file;
		next if($file->is_dir||$fileName!~/\.pm$/);
		$fileName=~s/^.+[\/\\]//;
		$fileName=~s/\.pm//;
    push @files,{fileName=>$fileName,path=>$file->absolute};
	}
  return @files;
}

sub main{
    my $cfg = Config::IniFiles->new( -file => &rootPath().'config.ini' );
    $templet=$cfg->val('code','templet');
    $path=$cfg->val('code','path');
    my $db=Db::DbConfig->new(
        $cfg->val('db','server'),
        $cfg->val('db','database'),
        $cfg->val('db','username'),
        $cfg->val('db','password'),
        $cfg->val('db','dbtype'));
        
    my $context=CodeIt->new($db);

    my @files=loadFiles;

    foreach(@files){
      Invoke->new($_->{path},$_->{fileName})->execute($context);
    }
}

main;
