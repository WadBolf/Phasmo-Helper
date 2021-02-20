#! /usr/bin/env perl

#
# Phasmo Helper by Clare Jonsson 18/02/2021
#

use warnings;
use strict;


use lib "/var/www/phasmo/app/lib";

use Phasmo;

use CGI qw(:all);
use CGI::Session;
use Template qw(:template );
use Data::Dumper;
use DBI;
use Quantum::Superpositions;
use JSON;

# CGI Setup 
my $cgi = CGI->new;
my $session = new CGI::Session(undef, $cgi);
my $cookie = $cgi->cookie(CGISESSID => $session->id);
print $cgi->header( -cookie=>$cookie );

my $db = "/var/www/phasmo/app/database/phasmo.sqlite";
my $phasmo = new Phasmo($db) or die "DB NOT FOUND";


my @evidence = (
	"",
	"",
	"",
);

my $returner = $phasmo->getData( @evidence );

my $inf = "";


my $template_vars = {
	#dataJSON => encode_json $returner,
	inf 	 => $inf,
};

# TEMPLATE START --------------------------------------------------------------
        # Launch the template using $template_vars defined in earlier in the script.
        my $templatepath = "/var/www/phasmo/app/template/";
        my $template = Template->new({
                RELATIVE => 1,
                INCLUDE_PATH => $templatepath,
        });

        $template->process('index.tpl', $template_vars)
                || die "Template process failed: ", $template->error(), "\n";
# TEMPLATE END ----------------------------------------------------------------


