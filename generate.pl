#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Template;
use XML::Simple;
use File::Copy;

my $xml = new XML::Simple;

my $skupiny = $xml->XMLin("psp/xml/skupiny.xml");

my $manifest = $xml->XMLin("AndroidManifest.xml");

my $title = "Periodická soustva prvků";
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
			'title' => $title,
			'skupiny' => $skupiny->{skupina}
		},
		"$OUT/$skup->{'zkratka'}.html",
		{ binmode => ':utf8' }) or die $t->error;

	for my $prvek (@{$data->{prvek}}){
	 $t->process('prvek.html',
		 { 'prvek' => $prvek,
			 'cur' => $skup->{'zkratka'},
			 'cur_l' => $skup->{'nazev'},
			 title => $title
		 },
		 "$OUT/".lc($prvek->{'lnazev'}).".html",
		 { binmode => ':utf8' }) or die $t->error;

	 push(@prvky,$prvek);
	}

}

my @sorted = sort {$a->{cnazev} cmp $b->{cnazev}} @prvky;


$t->process('index.html',
	{ 'prvky' => [@sorted],
		'title' => $title,
		'nohomelink' => 'true'
	},
	"$OUT/index.html",
	{ binmode => ':utf8' }) or die $t->error;

$t->process('about.html',
	{	'title' => $title,
		'version' => $manifest->{'android:versionName'},
	},
	"$OUT/about.html",
	{ binmode => ':utf8' }) or die $t->error;

copy("psp/t.css","$OUT/t.css");
copy("psp/img/right.png","$OUT/right.png");
copy("psp/img/down.png","$OUT/down.png");
copy("psp/img/left.png","$OUT/left.png");
copy("psp/img/home.png","$OUT/home.png");
