#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Template;
use Template::Stash;
use XML::Simple;
use File::Copy;
use File::Basename;
use Locale::TextDomain ( 'ptable' ,  './locale/' );
use POSIX qw (setlocale LC_ALL);
use Locale::Messages qw (nl_putenv);
use Encode;
Locale::Messages->select_package ('gettext_pp');

$Template::Stash::ROOT_OPS->{ 'l' }    = sub {
    return decode('UTF-8', __(shift));
};

my @langs = get_langs();

my $xml = new XML::Simple;

my $druhy = $xml->XMLin("psp/xml/druhy.xml");

my $skupiny = $xml->XMLin("psp/xml/skupiny.xml");

my $periody = $xml->XMLin("psp/xml/periody.xml");

my $skupenstvi = $xml->XMLin("psp/xml/skupenstvi.xml");

my $manifest = $xml->XMLin("AndroidManifest.xml");

my $strings = $xml->XMLin("res/values/strings.xml");

#my $appname = $strings->{'string'}{'content'};

my $OUT = "assets/www";

my $t = Template->new({
		INCLUDE_PATH => 'psp',
		ENCODING => 'utf8',
});

foreach my $lang (@langs){
	nl_putenv("LANGUAGE=$lang");
	nl_putenv("LANG=$lang");
	setlocale(LC_ALL, $lang);
	mkdir("$OUT/$lang");

	my $appname = 'Periodic Table';

	my @prvky;

	for my $druh (@{$druhy->{druh}}){

		my $data = $xml->XMLin("psp/xml/$druh->{'zkratka'}.xml");

		$t->process('druh.html',
			{ 'prvky' => $data,
				'cur' => $druh->{'zkratka'},
				'cur_l' => $druh->{'nazev'},
				'title' => $appname,
				'druhy' => $druhy->{druh}
			},
			"$OUT/$lang/$druh->{'zkratka'}.html",
			{ binmode => ':utf8' }) or die $t->error;

		for my $prvek (@{$data->{prvek}}){
		 $t->process('prvek.html',
			 { 'prvek' => $prvek,
				 'skupenstvi' => $skupenstvi->{'skupenstvi'},
				 'cur' => $druh->{'zkratka'},
				 'cur_l' => $druh->{'nazev'},
				 title => $appname
			 },
			 "$OUT/$lang/".lc($prvek->{'lnazev'}).".html",
			 { binmode => ':utf8' }) or die $t->error;

		 push(@prvky,$prvek);
		}

	}


	my @sortedbyname = sort {$a->{cnazev} cmp $b->{cnazev}} @prvky;
	my @sortedbyprotcislo = sort {$a->{protcislo} <=> $b->{protcislo}} @prvky;
	my @sortedbyln = sort {$a->{lnazev} cmp $b->{lnazev}} @prvky;
	my @sortedbyzn = sort {$a->{znacka} cmp $b->{znacka}} @prvky;
	my @sortedbyah = sort {$a->{athmot} =~ s/,/./r <=> $b->{athmot} =~ s/,/./r} @prvky;

	for my $skupina (@{$skupiny->{skupina}}){

		$t->process('skupina.html',
			{ 'prvky' => [@sortedbyname],
				'cur' => $skupina->{'zkratka'},
				'cur_l' => $skupina->{'nazev'},
				'title' => $appname,
				'skupiny' => $skupiny->{skupina}
			},
			"$OUT/$lang/$skupina->{'zkratka'}.html",
			{ binmode => ':utf8' }) or die $t->error;
	}

	$t->process('index-name.html',
		{ 'prvky' => [@sortedbyname],
			'title' => $appname,
			'nohomelink' => 'true'
		},
		"$OUT/$lang/index.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('index-pc.html',
		{ 'prvky' => [@sortedbyprotcislo],
			'title' => $appname,
		},
		"$OUT/$lang/index-pc.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('index-ln.html',
		{ 'prvky' => [@sortedbyln],
			'title' => $appname,
		},
		"$OUT/$lang/index-ln.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('index-zn.html',
		{ 'prvky' => [@sortedbyzn],
			'title' => $appname,
		},
		"$OUT/$lang/index-zn.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('index-ah.html',
		{ 'prvky' => [@sortedbyah],
			'title' => $appname,
		},
		"$OUT/$lang/index-ah.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('menu.html',
		{
			'title' => 'Menu',
			'nomenulink' => 'true'
		},
		"$OUT/$lang/menu.html",
		{ binmode => ':utf8' }) or die $t->error;

	for my $perioda (@{$periody->{perioda}}){
		$t->process('perioda.html',
			{ 'prvky' => [@sortedbyname],
				'periody' => $periody->{perioda},
				'perioda' => $perioda->{'cislo'},
				'title' => $appname
			},
			"$OUT/$lang/p$perioda->{'cislo'}.html",
			{ binmode => ':utf8' }) or die $t->error;
	}

	$t->process('perioda.html',
		{ 'periody' => $periody->{perioda},
			'title' => $appname
		},
		"$OUT/$lang/p.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('druh.html',
		{	'title' => $appname,
			'druhy' => $druhy->{druh}
		},
		"$OUT/$lang/d.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('skupina.html',
		{	'title' => $appname,
			'skupiny' => $skupiny->{skupina}
		},
		"$OUT/$lang/s.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('about.html',
		{	'title' => $appname,
			'version' => $manifest->{'android:versionName'},
		},
		"$OUT/$lang/about.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('mohs.html',
		{	'title' => $appname,
		},
		"$OUT/$lang/mohs.html",
		{ binmode => ':utf8' }) or die $t->error;

	$t->process('settings.html',
		{	'title' => $appname,
		},
		"$OUT/$lang/settings.html",
		{ binmode => ':utf8' }) or die $t->error;
}

$t->process('index.html',
	{ 'langs' => [@langs]
	},
	"$OUT/index.html",
	{ binmode => ':utf8' }) or die $t->error;

copy("psp/t.css","$OUT/t.css");
copy("psp/img/right.png","$OUT/right.png");
copy("psp/img/z.png","$OUT/z.png");
copy("psp/roboto-regular.ttf","$OUT/roboto-regular.ttf");

sub get_langs{
	my @langs = ();
	my @files = glob("po/*.po");
	foreach my $foo(@files){
		push(@langs, basename($foo, ('.po')));
	}
	return @langs;
}

