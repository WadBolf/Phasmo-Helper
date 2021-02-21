#! /usr/bin/env perl

#
# Phasmo Helper by Clare Jonsson (wadbolf@gmail.com) 18/02/2021
# If you use this project in any form, please keep this info here.
# Thank you.
#

use warnings;
use strict;

# SITE LOCATION----------------------------------------------------------------

	# Site Location (Change this path to match your site location)

	my $siteLocation; BEGIN { $siteLocation = "/var/www/phasmo"; };

# SITE LOCATION----------------------------------------------------------------


# PATHS -----------------------------------------------------------------------

	# Normally you won't have to change anything here as the site path 
	# is defined above.

	use lib "$siteLocation/app/lib";
	my $db = "$siteLocation/app/database/phasmo.sqlite";
	my $templatepath = "$siteLocation/app/template";

# PATHS -----------------------------------------------------------------------

# DEPENDANCIES AND LIBS -------------------------------------------------------

	use Phasmo;
	use CGI qw(:all);
	use CGI::Session;
	use Template qw(:template );
	use Data::Dumper;
	use DBI;
	use Quantum::Superpositions;
	use JSON;

# DEPENDANCIES AND LIBS -------------------------------------------------------


# CGI Setup -------------------------------------------------------------------

	my $cgi = CGI->new;
	my $session = new CGI::Session(undef, $cgi);
	my $cookie = $cgi->cookie(CGISESSID => $session->id);
	print $cgi->header( -cookie=>$cookie );

	# Attempt to connect to database
	my $phasmo = new Phasmo($db) or die "Database not found";

# CGI Setup -------------------------------------------------------------------


# TEMPLATE START --------------------------------------------------------------

        # Launch the template.
	# We're not sending any variables to template toolkit as it's handled by AJAX
        my $template = Template->new({
                RELATIVE => 1,
                INCLUDE_PATH => $templatepath,
        });

        $template->process('index.tpl')
                || die "Template process failed: ", $template->error(), "\n";

# TEMPLATE END ----------------------------------------------------------------
