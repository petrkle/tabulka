#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Template;
use XML::Simple;
use File::Copy;

my $xml = new XML::Simple;

my $skupiny = $xml->XMLin("psp/xml/skupiny.xml");

my $periody = $xml->XMLin("psp/xml/periody.xml");

my $skupenstvi = $xml->XMLin("psp/xml/skupenstvi.xml");

my $manifest = $xml->XMLin("AndroidManifest.xml");

my $strings = $xml->XMLin("res/values/strings.xml");

my $appname = $strings->{'string'}->{'app_name'}->{'content'};
my $OUT = "assets/www";

my $t = Template->new({
		INCLUDE_PATH => 'psp',
		ENCODING => 'utf8',
});

my @prvky;

for my $skup (@{$skupiny->{skupina}}){

	my $data = $xml->XMLin("psp/xml/$skup->{'zkratka'}.xml");

	$t->process('skupina.html',
		{ 'prvky' => $data,
			'cur' => $skup->{'zkratka'},
			'cur_l' => $skup->{'nazev'},
			'title' => $appname,
			'skupiny' => $skupiny->{skupina}
		},
		"$OUT/$skup->{'zkratka'}.html",
		{ binmode => ':utf8' }) or die $t->error;

	for my $prvek (@{$data->{prvek}}){
	 $t->process('prvek.html',
		 { 'prvek' => $prvek,
			 'skupenstvi' => $skupenstvi->{'skupenstvi'},
			 'cur' => $skup->{'zkratka'},
			 'cur_l' => $skup->{'nazev'},
			 title => $appname
		 },
		 "$OUT/".lc($prvek->{'lnazev'}).".html",
		 { binmode => ':utf8' }) or die $t->error;

	 push(@prvky,$prvek);
	}

}

my @sortedbyname = sort {$a->{cnazev} cmp $b->{cnazev}} @prvky;
my @sortedbyprotcislo = sort {$a->{protcislo} <=> $b->{protcislo}} @prvky;
my @sortedbyln = sort {$a->{lnazev} cmp $b->{lnazev}} @prvky;
my @sortedbyzn = sort {$a->{znacka} cmp $b->{znacka}} @prvky;
my @sortedbyah = sort {$a->{athmot} =~ s/,/./r <=> $b->{athmot} =~ s/,/./r} @prvky;


$t->process('index.html',
	{ 'prvky' => [@sortedbyname],
		'title' => $appname,
		'nohomelink' => 'true'
	},
	"$OUT/index.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('index-pc.html',
	{ 'prvky' => [@sortedbyprotcislo],
		'title' => $appname,
	},
	"$OUT/index-pc.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('index-ln.html',
	{ 'prvky' => [@sortedbyln],
		'title' => $appname,
	},
	"$OUT/index-ln.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('index-zn.html',
	{ 'prvky' => [@sortedbyzn],
		'title' => $appname,
	},
	"$OUT/index-zn.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('index-ah.html',
	{ 'prvky' => [@sortedbyah],
		'title' => $appname,
	},
	"$OUT/index-ah.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('menu.html',
	{
		'title' => 'Menu',
		'nomenulink' => 'true'
	},
	"$OUT/menu.html",
	{ binmode => ':utf8' }) or die $t->error;

for my $perioda (@{$periody->{perioda}}){
	$t->process('perioda.html',
		{ 'prvky' => [@sortedbyname],
			'periody' => $periody->{perioda},
			'perioda' => $perioda->{'cislo'},
			'title' => $appname
		},
		"$OUT/p$perioda->{'cislo'}.html",
		{ binmode => ':utf8' }) or die $t->error;
}

$t->process('perioda.html',
	{ 'periody' => $periody->{perioda},
		'title' => $appname
	},
	"$OUT/p.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('skupina.html',
	{	'title' => $appname,
		'skupiny' => $skupiny->{skupina}
	},
	"$OUT/s.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('about.html',
	{	'title' => $appname,
		'version' => $manifest->{'android:versionName'},
	},
	"$OUT/about.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('mohs.html',
	{	'title' => $appname,
	},
	"$OUT/mohs.html",
	{ binmode => ':utf8' }) or die $t->error;

copy("psp/t.css","$OUT/t.css");
copy("psp/img/right.png","$OUT/right.png");
copy("psp/roboto-regular.ttf","$OUT/roboto-regular.ttf");
