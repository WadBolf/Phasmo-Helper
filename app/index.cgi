#! /usr/bin/env perl

#
# Phasmo Helper by Clare Jonsson (wadbolf@gmail.com) 18/02/2021
# If you use this project in any form, please keep this info here.
# Thank you.
#

# DEPENDANCIES AND LIBS -------------------------------------------------------

	use warnings;
	use strict;
	use Cwd qw(cwd);
	use CGI qw(:all);
	use CGI::Session;
	use Template qw(:template );
	use Data::Dumper;
	use DBI;
	use Quantum::Superpositions;
	use JSON;

# DEPENDANCIES AND LIBS -------------------------------------------------------


# SITE LOCATION----------------------------------------------------------------

	# The following within the BEGIN block is used in order to dynamically set the lib location:
	my $site_dir;
	my $lib_dir;
	my $siteLocation;
	BEGIN
	{
		$site_dir = cwd;		# Get surrent working directory
		$site_dir =~ s/htdocs//;	# remove htdocs to get the stire directory
		$site_dir = $site_dir . "app";	# Add app folder
		$lib_dir = $site_dir . "/lib";	# add "/lib" to create the lib directory
		eval "use lib('$lib_dir')";	# use lib directory
	}

	# Add Phasmo Library
	use Phasmo;

	# Set database and template-path
	my $db = "$site_dir/database/phasmo.sqlite";
	my $templatepath = "$site_dir/template";

# SITE LOCATION----------------------------------------------------------------


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
	# We're not sending any variables to template toolkit 
	# as the dynamic content is handled by AJAX.
        my $template = Template->new({
                RELATIVE => 1,
                INCLUDE_PATH => $templatepath,
        });

        $template->process('index.tpl')
                || die "Template process failed: ", $template->error(), "\n";

# TEMPLATE END ----------------------------------------------------------------
