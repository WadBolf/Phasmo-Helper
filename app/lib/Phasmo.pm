package Phasmo;

use warnings;
use strict;

use DBI;
use MIME::Base64;
use Data::Dumper;
use HTTP::Request::Common qw{ POST };
use CGI;
use JSON;


sub new
{
        my ($self, $dbfile) = @_;
        $self = {
                db => undef,
                err => "No Error",
        };

        bless $self;

        return "database file not found"
                        unless (-e $dbfile);
                $self->{db} = DBI->connect("dbi:SQLite:dbname=$dbfile","","", {
                        AutoCommit => 1,
                        sqlite_use_immediate_transaction => 1,
                });
                return "Failed to connect to database: $DBI::errstr"
                        unless (defined($self->{db}));

        return $self;
}

sub err
{
        my ($self) = @_;
        return $self->{err};
}

sub getData
{
        my ( $self, $params ) = @_;


	my $returner = {};

	my @searchForDB;

	my $totalSearchFor = 0;

	$returner->{itemsFound} = [];


	foreach my $item( @{$params->{searchFor}} )
	{
		push ( @searchForDB, "%" . $item . "%" );

		if ( $item ne "" )
		{
			$totalSearchFor ++;
			push ( @{$returner->{itemsFound}}, getEvidence( $self, $item ) );
		}
	}

	$returner->{totalItemsFound} = $totalSearchFor;

	my $q = $self->{db}->prepare(q{
		        SELECT * FROM Ghosts WHERE items LIKE ? AND items LIKE ? AND items LIKE ? ORDER BY ghost_name ASC;
		});
	if ( !defined($q) || !$q->execute($searchForDB[0], $searchForDB[1], $searchForDB[2] ) )
	{
		$self->{err} = $DBI::errstr;
		return undef;
	}
	while( defined ( my $row = $q->fetchrow_hashref ) )
	{
		$row->{Eliminated} = 0;
		my @evidenceRequired = split("/", $row->{items});
		my @result;
		foreach my $e ( @evidenceRequired)
		{
			my $found = 0;
			foreach my $s (@{$params->{searchFor}})
			{
				if ($s eq $e) {	$found = 1; }
			}

			if (!$found) { push (@result, getEvidence($self, $e) ); }
		}
		$row->{itemsRequired} =  \@result;
		push ( @{ $returner->{ghosts} }, $row );
	}

	# Iterate through above results for items left to find.
	my $q2 = $self->{db}->prepare(q{
                        SELECT * FROM Ghosts ORDER BY ghost_name ASC;
                });
        if ( !defined($q2) || !$q2->execute() )
        {
                $self->{err} = $DBI::errstr;
                return undef;
        }

        while( defined ( my $row = $q2->fetchrow_hashref ) )
        {
                my @evidenceRequired = split("/", $row->{items});
                my @result;
                foreach my $e ( @evidenceRequired)
                {
                        my $found = 0;
                        foreach my $s (@{$params->{searchFor}})
                        {
                                if ($s eq $e) { $found = 1; }
                        }

                        if (!$found) { push (@result, getEvidence($self, $e) ); }
                }
                $row->{itemsRequired} =  \@result;
                push ( @{ $returner->{allGhosts} }, $row );
        }


	my $allEvidence = $self->getAllEvidence($self);

	#$returner->{WOOOOOOO} = Dumper(@{$allEvidence}[0]);



	my $totalTTT = scalar @{$allEvidence};
	my @eliminated;


	if (!$params->{eliminated})
	{
		foreach my $item (@{$allEvidence})
		{
			$returner->{ItemsEliminated}->{$item->{item_code}} = 0;
		}
		#for (my $i = 0; $i < scalar @{$allEvidence}; $i++)
		#{
		#	push (@eliminated, 0);		
		#}
	}
	else
	{
		$returner->{ItemsEliminated} = $params->{eliminated}; 
	}

	my @allItemsLeft;

	foreach my $row ( @{$allEvidence} )
	{
		my $found = 0;
		foreach my $ghost  ( @{ $returner->{ghosts} } )
		{

			foreach my $item ( @{$ghost->{itemsRequired}} )
			{
				if ( $item->{item_code} eq $row->{item_code} )
				{
					$found = 1;
				}
			}
		}		
		
		if ( $found )
		{
			push( @allItemsLeft, getEvidence($self, $row->{item_code}) );
		}

		

	}
	$returner->{itemsLeft} = \@allItemsLeft;

        $q = $self->{db}->prepare(q{
                        SELECT * FROM Objectives ORDER BY item_code ASC;
                });
        if ( !defined($q) || !$q->execute() )
        {
                $self->{err} = $DBI::errstr;
                return undef;
        }
        my @objectives;
        while( defined ( my $row = $q->fetchrow_hashref ) )
        {
		push( @objectives, $row );
        }

        $returner->{objectives} = \@objectives;

	return $returner;
}


sub getAllEvidence
{
	my ($self) = @_;
	my $q = $self->{db}->prepare(q{
        	SELECT * FROM Evidence ORDER BY item_code ASC;
        });
        if ( !defined($q) || !$q->execute() )
        {
                $self->{err} = $DBI::errstr;
                return undef;
        }
	
	my @allEvidence;
	while( defined ( my $row = $q->fetchrow_hashref ) )
        {
		push (@allEvidence, $row);
	}

	return \@allEvidence;
}

sub getEvidence
{
        my ( $self, $getEv ) = @_;

	if ( defined( $getEv ))
	{
		my $q = $self->{db}->prepare(q{
			SELECT * FROM Evidence where item_code = ?;
		});

		if ( !defined($q) || !$q->execute( $getEv ) )
		{
		        $self->{err} = $DBI::errstr;
		        return undef;
		}
		while( defined ( my $row = $q->fetchrow_hashref ) )
		{
		        return $row;
		}
	}
}



1;
