#!usr/bin/perl -w
package Invoke;
use v5.18.0;

sub new{
	my $class=shift;
	my $self={
		_path=>shift,
		_filename=>shift
	};
	bless $self,$class;
	$self;
}

sub execute{
	my $self=shift;
	
	my $context=shift;
	unless(-f $self->{_path}){
		return '';
	}
	require "$self->{_path}";
	
	my $process=\&{"$self->{_filename}::process"};
	&$process($context);
}


1;
