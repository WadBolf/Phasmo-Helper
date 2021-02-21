#!/usr/bin/perl

use warnings;
use strict;

use Cwd qw(cwd);
use CGI qw(:all);
use CGI::Session;
use Template qw(:template );
use Data::Dumper;
use DBI;
use JSON;

# SITE LOCATION----------------------------------------------------------------

        # The following within the BEGIN block is used in order to dynamically set the lib location:
        my $site_dir;
        my $lib_dir;
        my $siteLocation;
        BEGIN
        {
                $site_dir = cwd;		# Get surrent working directory
                $site_dir =~ s/htdocs//;	# remove htdocs to get the stire directory
                $site_dir = $site_dir . "app";	# Add app folder.
                $lib_dir = $site_dir . "/lib";	# add /lib to create the lib directory
                eval "use lib('$lib_dir')";	# use lib directory
        }

        # Add Phasmo Library
        use Phasmo;

        # Set database and template-path
        my $db = "$site_dir/database/phasmo.sqlite";
        my $templatepath = "$site_dir/template";

# SITE LOCATION----------------------------------------------------------------


# CGI Setup
my $cgi = CGI->new;
my $session = new CGI::Session(undef, $cgi);
my $cookie = $cgi->cookie(CGISESSID => $session->id);
print $cgi->header( -cookie=>$cookie );

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


