#!/usr/bin/perl

use warnings;
use strict;

use lib "/var/www/phasmo/app/lib";
use Phasmo;
use CGI qw(:all);
use CGI::Session;
use Template qw(:template );
use Data::Dumper;
use DBI;
use JSON;

# CGI Setup
my $cgi = CGI->new;
my $session = new CGI::Session(undef, $cgi);
my $cookie = $cgi->cookie(CGISESSID => $session->id);
print $cgi->header( -cookie=>$cookie );

my $db = "/var/www/phasmo/app/database/phasmo.sqlite";
my $phasmo = new Phasmo($db) or die "DB NOT FOUND";


# Setup Dispatch functions ------------------------------------------------------------
my $dispatch = {
        getdata => \&GETDATA,
        DEFAULT => sub { print "YOU SHOULD NOT BE HERE"; exit(0); }
};
# End of Dispatch Setup ---------------------------------------------------------------


my $params= {};

if ($cgi=param())
{
        #$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
        if (uc $ENV{'REQUEST_METHOD'} eq "POST")
        {
                if (param('func'))
                {
                        $params->{"function"} = param('func');
                }

                if (param('getdata'))
                {
                        $params->{"getData"} = param('getdata');
                }
	}
}


# Launch dispatch function ----------------------------------------------------------
my $func = $dispatch->{ $params->{"function"} } || $dispatch->{DEFAULT};
$func->();
exit(0);
# -----------------------------------------------------------------------------------

sub GETDATA
{
	my $data = decode_json( $params->{getData} );
	
	my $returner = $phasmo->getData( @{$data} );


	my $json = encode_json( $returner );
	print $json;
}


