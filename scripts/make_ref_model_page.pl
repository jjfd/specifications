#!/usr/bin/perl
#
# $Source: C:/project/openehr/spec-dev/scripts/SCCS/s.make_ref_model_page.pl $
# $Date: 04/01/20 23:59:45+10:00 $
# $Revision: 1.2 $
#
# Example usage: make_ref_model_page.pl
# Copyright (C) 2004, Ocean Informatics Pty Ltd
#----------------------------------------------------------------

use Getopt::Long;

#----------------------------------------------------------------
# Definitions
my @reject_patterns = ("SCCS", "\.gif", "\.css", "\.jpg", "\.log", "index.html");

#----------------------------------------------------------------
# html_break_paras
#
# Wrap the argument in <p></p> tags, adding end/start pairs for
# blank lines

sub html_break_paras {
  my($str) = @_;
  chomp($str);

  $str =~ s/\\n/<br\\>/;
#  if ($str =~ /\\n/) {
#	  $str =~ s/^/<p>/;
#	  $str =~ s/$/<\/p>/;
#	  $str =~ s/\\n/<\/p><p>/;
#  }

  return $str;
}

#----------------------------------------------------------------
# html_escape
#
# Escape special characters in a string so that it can appear
# in HTML PCDATA.

sub html_escape {
  my($str) = @_;

  $str =~ s/\&/\&amp;/g;
  $str =~ s/\</\&lt;/g;
  $str =~ s/\>/\&gt;/g;

  return $str;
}

#----------------------------------------------------------------
# Process command line switches

sub process_arguments {
  my($version_ref, $changeset_ref) = @_;

  my $opt_help;

  $Getopt::Long::ignorecase = 0;
  local($result) = GetOptions ("help" => \$opt_help,
					"version=s" => $version_ref,
					"changeset=s" => $changeset_ref);
  if (! $result) {
    die "$prog: Usage error: --help for help\n";
  }

  if ($opt_help) {
    $opt_help = 1; # to shutup warnings when run with perl -w option
    print "Usage: $0 [options]\n";
    print "Options:\n";
    print "  --help             display this help message\n";
    print "  --version          repository version\n";
    print "  --changeset        repository change set\n";
    exit(0);
  }

  if (!defined($version_ref)) {
    die "Error: version must be supplied (see --help)\n";
  }

  if (!defined($changeset_ref)) {
    die "Error: change set must be supplied (see --help)\n";
  }

}

#------------------------------------
# print table of file names with links

sub convert_rev_hist {
  my ($file_hash_ref) = @_;

  # open the file REV_HIST.html

  open (INPUT, "REV_HIST.html") || die "can't open REV_HIST.html: $!";
  open (OUTPUT, "> index.html") || die "can't create index.html: $!";

  my $readme = "";
  my $readme_done=0;
  my $desc_hdr = "<h6 class=\"Heading\">Description</h6>";

  if (-r "README.txt") {
	  open (README, "README.txt") || die "can't open README.txt: $!";
	  while (<README>) {
		if ($_) {
			$readme = "$readme $_";
		} 
		else {
			$readme = "$readme<div><div>";
		}
	  }
  }

  my @key_matches;

  while (<INPUT>) {
	$line = $_;

	# detect 'class="Heading"' and insert README text before it; first check if not already done
	# due to script being rerun
	if ($line =~ $desc_hdr) {
		$readme_done=1;
		print "\t(Description already done)\n";
	}
	if (!$readme_done && $readme && $line =~ "class=\"Heading\"") {
		print OUTPUT "$desc_hdr<p class=\"Body\">\n$readme\n</p>";
		$readme_done=1;
	}

	foreach my $key (keys %$file_hash_ref) {
		# detect version pattern and insert link
		if ($line =~ $key) {
			my $str = "><a href=\"$file_hash_ref->{$key}\"$key/a><";
			if ($line =~ $str) {	# not already substituted due to be run multiple times
				print "\t(Link for $key already done)\n";
			}
			else {
				$line =~ s/$key/$str/;
			}
			push @key_matches, $key;
			last;
		}
	}
	print OUTPUT $line;
  } 
  
  foreach my $key (keys %$file_hash_ref) {
	my $found = 0;
  	foreach my $matched_key (@key_matches) {
		if ($key eq $matched_key) {
			$found = 1;
		}
	}
	if (! $found) {
		print "\tunmatched key: $key\n";
	}
  }

  close(INPUT) || die "can't close $file: $!";
  close(OUTPUT) || die "can't close $file: $!";

  # overwrite the REV_HIST.html file with the result
  my @args;
  if (! -w "REV_HIST.html") {
      @args = ("bk", "edit", "REV_HIST.html");
	print "@args\n";
      system(@args) == 0 || die "system @args failed: $?";
  }
  @args = ("cp", "REV_HIST.html", "REV_HIST.html.bak");
  system(@args) == 0 || die "system @args failed: $?";
  @args = ("mv", "index.html", "REV_HIST.html");
  system(@args) == 0 || die "system @args failed: $?";
}

#----------------------------------------------------------------

sub main {
  my $version = "1.0";
  my $changeset = "1.1";

  my $root_dir = "$ENV{OPENEHR}/spec-0.9_D";
  my $outfile = "index.html";
  my $page_title = "Summary";
  print "root_dir is: $root_dir\n";

  process_arguments(\@version, \@changeset);

  # get a list of directories to go into
  my @dir_list = `find $root_dir/publishing ! -name SCCS -type d -print`;

  print "dir list is: @dir_list\n";

  foreach my $dir (@dir_list) {
  	chomp($dir);
	if (-e "$dir\/REV_HIST.html") {
		my %file_list;
		chdir $dir;
		print "generating page for directory $dir\n";

		# generate file list for this directory
		foreach my $fname (`ls -1`) {
			chomp($fname);
			my $keep = 1;
			if (! -d $fname) {
				foreach my $rejpat (@reject_patterns) {
					if (! $keep || ($fname =~ /$rejpat/)) {
						$keep = 0;
					}
				}
				if ($keep) {
					# if it's a versioned filename like "ehr_im-0_9_7.pdf" then
					# generate a version key like "0.97" to find in the REV_HIST.html file,
					# which is generated from the Frame TOC file of the doc
					if ($fname =~ /[a-zA-Z0-9_]+-[0-9_]+\.pdf/) {
						my $key = $fname;
						$key =~ s/^[a-zA-Z0-9_]+-([0-9_]+)\.pdf$/$1/;	# get the version
						$key =~ s/_/./g;						# convert dots to underscores
						$key = ">$key<";						# to guarantee precise match in HTML text
						$file_list{$key} = $fname;
					}
				}
			}
		}
	
		convert_rev_hist(\%file_list);
		chdir "$root_dir/publishing";
	}
  }
}

#----------------------------------------------------------------

exit main();

#----------------------------------------------------------------
#EOF

