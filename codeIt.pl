#/usr/bin/perl
sub rootPath{
    my $path=__FILE__;
    $path=~s/codeIt\.pl//;
    $path=~s/\\/\//g;
    $path; 
}

BEGIN{
    unshift @INC,rootPath.'core';
}
use v5.18.0;
use DB::DbConfig;
use Config::IniFiles;
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

sub main{
    my $cfg = Config::IniFiles->new( -file => rootPath.'config.ini' );
    my $db=DB::DbConfig->new(
        $cfg->val('db','server'),
        $cfg->val('db','database'),
        $cfg->val('db','username'),
        $cfg->val('db','password'),
        $cfg->val('db','dbtype'));
    $db->tables;
    $db->columns('bcontact');
    say camelStyle 'DEFAULT_COLLATE_NAME';
    say pascalCaseStyle 'DEFAULT_COLLATE_NAME';
}


#while(my ($key,$value)=each %INC) {
#	say $key.'---'.$value;
#}
main;
