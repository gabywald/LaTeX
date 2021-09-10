#!/usr/bin/perl -w

use strict;

## rechercheDeadDrops.pl -l paris -d 5000 -p All

## ## ## this script is an example of use of HTTP user agent, 
## ## ""
## ## [^éèêëàâùûôîïçÇêÉÈËÊÀÙÛÔÂÎÏ]

use LWP::UserAgent;
use HTTP::Cookies;
use HTML::Parser;
use HTML::Form;

use Data::Dumper;

use Switch;

my %listeLinks = (
	'deadropsComDB'	=> 'http://deaddrops.com/db', ## **
	'deadropSearch' => 'http://deaddrops.com/db/?location=paris&maxdistance=5000&pagelen=25&action=Search', 
	'deaddropDetai' => 'http://deaddrops.com/db/?page=view&id=', 
);

print "\nParsing arguments... ";
my $state = 0;
my %arguments = (
	'location'	=> undef, ## location
	'distance'	=> undef, ## maximal distance
		## ';500;1000;5000;10000;50000;100000'
		## 'unlimited;500m;1km;5km;10km;50km;100km'
	'dropspag'	=> undef, ## drops per pages
		## ';25;50;100;99999'
		## 'default;25;50;100;All'
);
foreach my $arg (@ARGV) {
	print "\t'".$arg."'";
	switch($state) {
		case "1" { $arguments{location} = (($arg =~ /\-/)?undef:$arg);$state = 0; }
		case "2" { $arguments{distance} = (($arg =~ /\-/)?undef:$arg);$state = 0; }
		case "3" { $arguments{dropspag} = (($arg =~ /\-/)?undef:$arg);$state = 0; }
	}
	if ( ($arg =~ /\-/) && ($state eq "0") ) { $state = getStateValue($arg); }
	## ## print "\t".$arg."\t".$state."\n";
}
print "\n";
		

my ($location, $distance, $dropspag) = _applyMenu();

	$arguments{location} = $location;
	$arguments{distance} = $distance;
	$arguments{dropspag} = $dropspag;

	if (!defined $arguments{location}) { $arguments{location} = ""; }
	else { ; }
	if (!defined $arguments{distance}) { $arguments{distance} = 5000; } 
	else { 
		if ($arguments{distance} eq "unlimited")	{ $arguments{distance} = ""; }
		if ($arguments{distance} eq "500m")			{ $arguments{distance} = "500"; }
		if ($arguments{distance} eq "1km")			{ $arguments{distance} = "1000"; }
		if ($arguments{distance} eq "5km")			{ $arguments{distance} = "5000"; }
		if ($arguments{distance} eq "10km")			{ $arguments{distance} = "10000"; }
		if ($arguments{distance} eq "50km")			{ $arguments{distance} = "50000"; }
		if ($arguments{distance} eq "100km")		{ $arguments{distance} = "100000"; }
	}
	if (!defined $arguments{dropspag}) { $arguments{dropspag} = ""; } 
	else {
		if ($arguments{dropspag} eq "default")	{ $arguments{dropspag} = ""; }
		if ($arguments{dropspag} eq "25")		{ $arguments{dropspag} = "25"; }
		if ($arguments{dropspag} eq "50")		{ $arguments{dropspag} = "50"; }
		if ($arguments{dropspag} eq "100")		{ $arguments{dropspag} = "100"; }
		if ($arguments{dropspag} eq "All")		{ $arguments{dropspag} = "99999"; }
	}


my $link = $listeLinks{deadropsComDB};

## ## affichage demande
print "\n=================================\n";
print "Location : \t\t'".$arguments{location}."'\n";
print "Distance : \t\t'".$arguments{distance}."'\n";
print "Perpages : \t\t'".$arguments{dropspag}."'\n";
print "\n=================================\n";

## ## ## ## ## getc();

my $UA = getUserAgent();

## ## print Dumper(\%arguments);die;
my $content	= connectTo($UA,$link,"");
my @forms	= HTML::Form->parse( $content, $link );

## print $content."\n";
## describeForms(\@forms);
my $form = $forms[0];

## ## use Data::Dumper;print Dumper ($form->find_input( 'proximite' )->possible_values());
## print $form;

$form->value( location					=> $arguments{location} );
$form->value( maxdistance				=> $arguments{distance} );
$form->value( pagelen					=> $arguments{dropspag} );

## use Data::Dumper;print Dumper($form);getc();

## $form->value( username => $user);
$content = submit($UA,$form->click());
## $content = connectTo($UA,$link,"");
## print $content."\n";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
my $fullYear	= 1900+$year;
my $month		= $mon+1;
my $dirname		= $fullYear.(($month < 10)?"0":"").$month.(($mday < 10)?"0":"").$mday
					.(($hour < 10)?"0":"").$hour.(($min < 10)?"0":"").$min.(($sec < 10)?"0":"").$sec
					."-".$arguments{location}."-".$arguments{distance}."-".$arguments{dropspag};
mkdir ($dirname);
mkdir ($dirname."/img");

my $fileOutput = $dirname."/index.txt"; ## ."/results".int(rand(42)).".txt";

my @resultats		= _parseResult($content,$fileOutput);
## my @moreResultats	= _parseMoreResult(\@resultats);
## use Data::Dumper;print Dumper(\@resultats);

my $resultat = _toString(\@resultats);
print $resultat;

open (OUTPUT,">".$fileOutput);
print OUTPUT $resultat;
close OUTPUT;

open (OUTPUT, ">".$dirname."/document.tex");
print OUTPUT _getLaTeXheader();
print OUTPUT _parseMoreResult(\@resultats);
print OUTPUT _getLaTeXfooter();
close OUTPUT;

open (OUTPUT, ">".$dirname."/Makefile");
print OUTPUT _getLaTeXMakefile();
close OUTPUT;

system("cp -rv example/img/glider ".$dirname."/img/");
chdir($dirname);
system("make");
system("make clean");
chdir("..");

## ## ## ## ## 
## ## Exemples de User-Agent's : http://fr.wikipedia.org/wiki/User-Agent#Exemples
## ## voir aussi : http://www.anybrowser.org/
## ## voir aussi : http://fr.wikipedia.org/wiki/Fichier_d%27exclusion_des_robots
sub getUserAgent {
	my $cookiesFile = 'cookies.txt';
	if (-f $cookiesFile) {
		unlink($cookiesFile) 
			or die ("Erreur suppression Cookies\n");
	}
	## ## 'Mozilla/5.0 [en] (X11; i; Linux 2.2.16 i6876; Nav)'
	my $userAgent = LWP::UserAgent->new(
		agent		=> "Mozilla/5.0 [en] (X11; i; Linux 2.2.16 i6876; Nav) Sandbender 0.1 -- ".int(rand(100)),
		cookie_jar	=> HTTP::Cookies->new(
			file			=> $cookiesFile, 
			autosave		=> 1, 
			ignore_discard	=> 1, 
		)
	);
	return $userAgent;
}

sub getStateValue {
	my $arg = shift;
	if ( ($arg eq '-l') || ($arg eq '--location') )			{ return 1; }
	elsif ( ($arg eq '-d') || ($arg eq '--distance') )		{ return 2; }
	elsif ( ($arg eq '-p') || ($arg eq '--dropsperpage') )	{ return 3; }
	return 0;
}

sub submit {
	my $userAge = shift;
	my $request	= shift;
	my $result	= $userAge->request($request);
	
	## print "\t'".$result->is_success."'\n";
	
	if (!$result->is_success) { return $result->status_line; }
	## print Dumper(\$res);
	my $headers	= $result->headers();
	my $content	= $result->content();
	my %headers	= %{$headers};
	# print "\tHEADER : \n";
	# foreach my $key (keys %headers) 
	# 	{ print "\t\t".$key."\t".$headers{$key}."\n"; }
	# print "\n\n";
	# print "\tCONTENT\n";
	# print $content."\n\n";
	return $content;
}


sub connectTo {
	my $userAge = shift;
	my $link	= shift;
	my $subpage	= shift;
	if (!$subpage) { $subpage = ""; }
	
	print "\t'".$link.$subpage."'\n";
	
	my $request = HTTP::Request->new( GET => $link.$subpage );
	return submit($userAge,$request);
}

sub describeForms {
	my $forms = shift;
	my @forms = @{$forms};
	foreach my $form (@forms) { 
		print $form."\n";
		my %form = %{$form};
		foreach my $key (sort keys %form) { 
			if ($key eq "inputs") {
				my @inputs = @{$form{$key}};
				print "\tINPUTS\n";
				foreach my $elt (@inputs) { 
					my %elt = %{$elt};
					print "\t\t\t".(($elt{name})?$elt{name}:"-----")."\t".$elt{type}."\n";
				}
			} else { print "\t".$key."\t".$form{$key}."\n"; }
		}
	}
}

sub _toString {
	my $results = shift;
	my @results = @{$results};
	my $string = "";
	
	foreach my $elt (@results) {
		## print "\t".$elt->[0]."\t".$elt->[1]."\t".$elt->[2].
		## 		"\t".$elt->[3]."\t".$elt->[4]."\t".$elt->[5].
		## 		"\t".$elt->[6]."\t".$elt->[7]."\t".$elt->[8]."\n";
		$string .= "\t".$elt->[0]."\t".$elt->[1]."\t".$elt->[2].
				"\t".$elt->[3]."\t".$elt->[4]."\t".$elt->[5].
				"\t".$elt->[6]."\t".$elt->[7]."\t".$elt->[8]."\n";
	}

	return $string;
}

sub _parseResult {
	my $contenu			= shift;
	my $output			= shift;
	my @results			= ();
	
		my %currentResult	= (
			'date'			=> undef, ## <td align="center">([0-9]{4})-([0-9]{2})-([0-9]{2})</td>
			'name'			=> undef, ## <td><a href="?page=view&id=(.*?)">(.*?)</a></td>	=> $2
			'iden'			=> undef, ## <td><a href="?page=view&id=(.*?)">(.*?)</a></td>	=> $1
			'addrPart1'		=> undef, ## <td>(.*?)</td>
			'addrPart2'		=> undef, ## <td>(.*?)</td>
			'addrPart3'		=> undef, ## <td>(.*?)</td>
			'accrPart1'		=> undef, ## <td><acronym title="(.*?)">(.*?)</acronym></td>	=> $1
			'accrPart2'		=> undef, ## <td><acronym title="(.*?)">(.*?)</acronym></td>	=> $2
			'size'			=> undef, ## <td align="center">(.*?)</td>
		);
	
	my ($date, $name, $iden, $addrPart1, $addrPart2, $addrPart3, $accrPart1, $accrPart2, $size);
	my @contenuLignes = split("\n",$contenu);
	foreach my $line (@contenuLignes) {
		chomp($line);
		if ( ($line =~ /<\/tr><tr>/) && (defined $date) ) {
			push (@results, [$date, $name, $iden, $addrPart1, $addrPart2, $addrPart3, $accrPart1, $accrPart2, $size]);
			
			## print "\t'".$date."'\n";
			## print "\t'".$name."'\n";
			## print "\t'".$iden."'\n";
			## print "\t'".$addrPart1."'\n";
			## print "\t'".$addrPart2."'\n";
			## print "\t'".$addrPart3."'\n";
			## print "\t'".$accrPart1."'\n";
			## print "\t'".$accrPart2."'\n";
			## print "\t'".$size."'\n";
			## getc();
			
			$date		= undef;$name		= undef;$iden		= undef;
			$addrPart1	= undef;$addrPart2	= undef;$addrPart3	= undef;
			$accrPart1	= undef;$accrPart2	= undef;$size		= undef;
		}
		elsif ($line =~ /<td align="center">(([0-9]{4})-([0-9]{2})-([0-9]{2}))<\/td>/) 
			{ $date = $1; }
		elsif (defined $date) {
			if ($line =~ /<td><a href="\?page=view&id=(.*?)">(.*?)<\/a><\/td>/) 
				{ $name = $2; $iden = $1; }
			elsif ($line =~ /<td><acronym title="(.*?)">(.*?)<\/acronym><\/td>/) 
				{ $accrPart1 = $1; $accrPart2 = $2; }
			elsif ( ($line =~ /<td>(.*?)<\/td>/) && (!defined $addrPart1) ) 
				{ $addrPart1 = $1; }
			elsif ( ($line =~ /<td>(.*?)<\/td>/) && (!defined $addrPart2) ) 
				{ $addrPart2 = $1; }
			elsif ( ($line =~ /<td>(.*?)<\/td>/) && (!defined $addrPart3) ) 
				{ $addrPart3 = $1; }
			elsif ($line =~ /<td align="center">(.*?)<\/td>/) 
				{ $size = $1; }
		}
			
		## else { print "\t'".$line."'\n";getc(); }
	} ## END foreach my $line...
	## for the last one...
	if (defined $date) {
		push (@results, [$date, $name, $iden, $addrPart1, $addrPart2, $addrPart3, $accrPart1, $accrPart2, $size]);
		$date		= undef;$name		= undef;$iden		= undef;
		$addrPart1	= undef;$addrPart2	= undef;$addrPart3	= undef;
		$accrPart1	= undef;$accrPart2	= undef;$size		= undef;
	}
	
	return @results;
}

sub _parseMoreResult {
	my $results		= shift;
	my @results		= @{$results};
	
		my $idenKey = "Id: ";
		my $nameKey = "Name: ";
		my $dropKey = "Drop-Type: ";
		my $sizeKey = "Size: ";
		my $dateKey = "Date Created: ";
		my $addrKey = "Address: ";
		my $coorKey = "Coordinates: ";
		my $permKey = "Permalink: ";
		my $abouKey = "About: ";
	
	## my @moreResults	= ();
	my $i			= 0;
	my $string		= "";
	
	$string .= "\\begin{enumerate}\n";
	foreach my $res (@results) {
		my $date = $res->[0];
		my $name = $res->[1];
		my $iden = $res->[2];
		my $add1 = $res->[3];
		my $add2 = $res->[4];
		my $add3 = $res->[5];
		my $acc1 = $res->[6];
		my $acc2 = $res->[7];
		my $size = $res->[8];
		
		$string .= convertFormatsLaTeX("\t\\item ".$name." -- ".$iden." -- ".$date." -- ".$size."\n");
		
	} ## END 'foreach my $res (@results)' ## END first roll
	$string .= "\\end{enumerate}\n\\clearpage\n";
	
	foreach my $res (@results) {
		my $date = $res->[0];
		my $name = $res->[1];
		my $iden = $res->[2];
		my $add1 = $res->[3];
		my $add2 = $res->[4];
		my $add3 = $res->[5];
		my $acc1 = $res->[6];
		my $acc2 = $res->[7];
		my $size = $res->[8];
		print "\t[".$listeLinks{deaddropDetai}.$iden."]\n";
		## getc();
		my $contenu = connectTo($UA, $listeLinks{deaddropDetai}, $iden);
		
		my $flagForInfos = 0;
		my $flagForPicts = 0;
		my $flagForAbout = 0;
		my %contentToAdd = ();
		
		my @contenuLignes = split("\n",$contenu);
		foreach my $line (@contenuLignes) {
			chomp($line);
			if ($line =~ /<tr><td colspan="2" class="td_menu"><b>Information<\/b><\/td><\/tr>/)
				{ $flagForInfos = 1; }
			elsif ($flagForInfos == 1) {
				if ($line =~ /<\/table>/) { $flagForInfos = 0;print "\n\n"; }
				if ($line =~ /<tr><td style="width: 200px;"><b>Coordinates: <\/b><\/td><td><a href=".*?">(.*?)<\/a><\/td><\/tr>/)
					{ my $key = "Coordinates: ";$contentToAdd{$key} = $1;print "\t[".$key."] => [".$1."]\n"; }
				elsif ($line =~ /<tr><td style="width: 200px;"><b>(.*?)<\/b><\/td><td>(.*?)<\/td><\/tr>/) 
					{ $contentToAdd{$1} = $2;print "\t[".$1."] => [".$2."]\n"; }
			} ## END 'elsif ($flagForInfos == 1)'

			
			elsif ($line =~ /<tr><td colspan="3" class="td_menu"><b>Pictures<\/b><\/td><\/tr>/)
				{ $flagForPicts = 1; }
			elsif ($flagForPicts == 1) {
				if ($line =~ /<\/table>/) { $flagForPicts = 0; } ## print "\n\n";
				## <td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px"><\/td><td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px"><\/td><td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px">
				## <td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px"><\/td><td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px">
				if ($line =~ /<td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px"><\/td><td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px"><\/td><td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px">/) {
					print "\t 1- [".$1."]\n\t 2- [".$2."]\n\t 3- [".$3."]\n\t 4- [".$4."]\n\t 5- [".$5."]\n\t 6- [".$6."]\n";
					my $fullSize1 = $1;
					my $fullSize2 = $3;
					my $fullSize3 = $5;
					
					$contentToAdd{"fullSize1"} = $fullSize1;
					$contentToAdd{"fullSize2"} = $fullSize2;
					$contentToAdd{"fullSize3"} = $fullSize3;
					$contentToAdd{"fullSize1"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					$contentToAdd{"fullSize2"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					$contentToAdd{"fullSize3"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					
					my $image1 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize1);
					open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize1"});
					print IMAGE $image1;
					close IMAGE;
					
					my $image2 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize2);
					open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize2"});
					print IMAGE $image2;
					close IMAGE;
					
					my $image3 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize3);
					open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize3"});
					print IMAGE $image3;
					close IMAGE;
				}
				elsif ($line =~ /<td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px"><\/td><td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px">/) {
					print "\t 1- [".$1."]\n\t 2- [".$2."]\n\t 3- [".$3."]\n\t 4- [".$4."]\n"; ## "\t 5- [".$5."]\n\t 6- [".$6."]\n";
					my $fullSize1 = $1;
					my $fullSize2 = $3;
					## my $fullSize3 = $5;
					
					$contentToAdd{"fullSize1"} = $fullSize1;
					$contentToAdd{"fullSize2"} = $fullSize2;
					## $contentToAdd{"fullSize3"} = $fullSize3;
					$contentToAdd{"fullSize1"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					$contentToAdd{"fullSize2"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					## $contentToAdd{"fullSize3"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					
					my $image1 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize1);
					open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize1"});
					print IMAGE $image1;
					close IMAGE;
					
					my $image2 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize2);
					open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize2"});
					print IMAGE $image2;
					close IMAGE;
					
					## my $image3 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize3);
					## open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize3"});
					## print IMAGE $image3;
					## close IMAGE;
				}
				elsif ($line =~ /<td align="left" valign="center"><a href="(.*?)" target="_blank" title="click to see fullsize picture"><img src="(.*?)" border="0" width="250px" height="250px">/) {
					print "\t 1- [".$1."]\n\t 2- [".$2."]\n"; ## ""\t 3- [".$3."]\n\t 4- [".$4."]\n"; ## "\t 5- [".$5."]\n\t 6- [".$6."]\n";
					my $fullSize1 = $1;
					## my $fullSize2 = $3;
					## my $fullSize3 = $5;
					
					$contentToAdd{"fullSize1"} = $fullSize1;
					## $contentToAdd{"fullSize2"} = $fullSize2;
					## $contentToAdd{"fullSize3"} = $fullSize3;
					$contentToAdd{"fullSize1"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					## $contentToAdd{"fullSize2"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					## $contentToAdd{"fullSize3"} =~ s/images\/fullsize\/(.*?)\/(.*?)/$1-$2/;
					
					my $image1 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize1);
					open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize1"});
					print IMAGE $image1;
					close IMAGE;
					
					## my $image2 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize2);
					## open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize2"});
					## print IMAGE $image2;
					## close IMAGE;
					
					## my $image3 = connectTo($UA, $listeLinks{deadropsComDB}, "/".$fullSize3);
					## open (IMAGE, ">".$dirname."/img/".$contentToAdd{"fullSize3"});
					## print IMAGE $image3;
					## close IMAGE;
				}
			} ## END 'elsif ($flagForPicts == 1)'
			
			elsif ($line =~ /<td class="td_menu"><b>About<\/b><\/td>/) 
				{ $flagForAbout = 1; }
			elsif ($flagForAbout == 1) {
				
				if ($line =~ /<td>(.*?)<\/td>/)		{ $contentToAdd{$abouKey} .= $1; }
				elsif ($line =~ /<td>(.*?)/)		{ $contentToAdd{$abouKey} .= $1; }
				elsif ($line =~ /<br>(.*?)<\/td>/)	{ $contentToAdd{$abouKey} .= $1; }
				elsif ($line =~ /<td>(.*?)/)		{ $contentToAdd{$abouKey} .= $1; }
				## else { print "\t\t//".$line."//\n"; }
				
				if ($line =~ /<\/table>/) { 
					$flagForAbout = 0;print "\n\n";
					## print "\t::::".$contentToAdd{$abouKey}."\n";
					$contentToAdd{$idenKey} = convertFormatsLaTeX($contentToAdd{$idenKey});
					$contentToAdd{$nameKey} = convertFormatsLaTeX($contentToAdd{$nameKey});
					$contentToAdd{$dropKey} = convertFormatsLaTeX($contentToAdd{$dropKey});
					$contentToAdd{$sizeKey} = convertFormatsLaTeX($contentToAdd{$sizeKey});
					$contentToAdd{$dateKey} = convertFormatsLaTeX($contentToAdd{$dateKey});
					$contentToAdd{$addrKey} = convertFormatsLaTeX($contentToAdd{$addrKey});
					$contentToAdd{$coorKey} = convertFormatsLaTeX($contentToAdd{$coorKey});
					$contentToAdd{$permKey} = convertFormatsLaTeX($contentToAdd{$permKey});
					$contentToAdd{$abouKey} = convertFormatsLaTeX($contentToAdd{$abouKey});
					$contentToAdd{$abouKey} =~ s/<br>/\n/g;
					## print "\t => ".$contentToAdd{$abouKey}."\n";
					print "\t[".$contentToAdd{$abouKey}."]\n";
					
					if (!defined $contentToAdd{"fullSize1"}) { $contentToAdd{"fullSize1"} = "glider/logo-glider.png"; }
					if (!defined $contentToAdd{"fullSize2"}) { $contentToAdd{"fullSize2"} = "glider/logo-glider.png"; }
					if (!defined $contentToAdd{"fullSize3"}) { $contentToAdd{"fullSize3"} = "glider/logo-glider.png"; }
					
					$string .= "\\begin{minipage}[ht]{0.45\\textwidth}\n";
					$string .= "\t\t\\textbf{Information}~\\\\\n\n"; ## \\scriptsize
					$string .= "\t\\begin{tabular}[ht]{ p{3cm} p{5cm} }\n";
					$string .= "\t\t\\textbf{".$idenKey."}\t\t\t&\t\t"	.$contentToAdd{$idenKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$nameKey."}\t\t\t&\t\t"	.$contentToAdd{$nameKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$dropKey."}\t\t&\t"		.$contentToAdd{$dropKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$sizeKey."}\t\t\t&\t\t"	.$contentToAdd{$sizeKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$dateKey."}\t&\t\t"		.$contentToAdd{$dateKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$addrKey."}\t\t&\t\t"	.$contentToAdd{$addrKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$coorKey."}\t&\t\t"		.$contentToAdd{$coorKey}."\t\\\\\n";
					$string .= "\t\t\\textbf{".$permKey."}\t&\t\t--\t\\\\\n";
					$string .= "\t\t\\multicolumn{2}{ p{8cm} }{\\texttt{".$contentToAdd{$permKey}."}}\t\\\\\n";
					$string .= "\t\t\\textbf{".$abouKey."}\t&\t\t--\t\\\\\n";
					$string .= "\t\t\\multicolumn{2}{ p{8cm} }{"		 .$contentToAdd{$abouKey}."}\t\\\\\n";
					$string .= "\t\\end{tabular}\n";
					$string .= "\\end{minipage} \\hfill \\begin{minipage}[ht]{0.45\\textwidth}\n";
					$string .= "\t\\textbf{Picture -- Overview}\n";
					$string .= "\t\\begin{center} \\includegraphics[width=8.00cm, height=5.00cm]{img/".$contentToAdd{"fullSize1"}."} \\end{center}\n";
					$string .= "\\end{minipage}~\\\\~\\\\\n\n";
					$string .= "\\begin{minipage}[ht]{0.45\\textwidth}\n";
					$string .= "\t\\textbf{Picture -- Medium distance}\n";
					$string .= "\t\\begin{center} \\includegraphics[width=8.00cm, height=5.00cm]{img/".$contentToAdd{"fullSize2"}."} \\end{center}\n";
					$string .= "\\end{minipage} \\hfill \\begin{minipage}[ht]{0.45\\textwidth}\n";
					$string .= "\t\\textbf{Picture -- Closeup}\n";
					$string .= "\t\\begin{center} \\includegraphics[width=8.00cm, height=5.00cm]{img/".$contentToAdd{"fullSize3"}."} \\end{center}\n";
					$string .= "\\end{minipage}\n\n";
					
					$string .= "\\begin{center} \\rule{0.75\\textwidth}{0.01cm} \\end{center}\n\n\\clearpage\n\n";
					
					## if ( ($i == 0) || ($i%2 == 0) ) 
					## 	{ $string .= "\\begin{center} \\rule{0.75\\textwidth}{0.01cm} \\end{center}\n\n"; }
					## else 
					## 	{ $string .= "\\clearpage %% \\begin{center} \\rule{0.75\\textwidth}{0.01cm} \\end{center}\n\n"; }
					$contentToAdd{$idenKey} = undef;
					$contentToAdd{$nameKey} = undef;
					$contentToAdd{$dropKey} = undef;
					$contentToAdd{$sizeKey} = undef;
					$contentToAdd{$dateKey} = undef;
					$contentToAdd{$addrKey} = undef;
					$contentToAdd{$coorKey} = undef;
					$contentToAdd{$permKey} = undef;
					$contentToAdd{$abouKey} = "";
					
					$contentToAdd{"fullSize1"} = undef;
					$contentToAdd{"fullSize2"} = undef;
					$contentToAdd{"fullSize3"} = undef;
				
				} ## END 'if ($line =~ /<\/table>/)' // END of about !!
			}
		}
		## push (@moreResults, [$date, $name, $iden, $add1, $add2, $add3, $acc1, $acc2, $size, %contentToAdd]);
		$i++;
	}
	
	## return @moreResults;
	return $string;
}

sub _applyMenu {
	my $location = undef;
	if (defined $arguments{location}) { $location = $arguments{location}; }
	else {
		print "Location ? ";
		$location = <STDIN>;
		chomp($location);
	}
	my $distance = undef;
	if (defined $arguments{distance}) { $distance = $arguments{distance}; }
	else {
		while ( (!defined $distance) || ($distance !~ /[1-7]/) ) {
			print "=======================================\n";
			print "\t1 : unlimited\n";
			print "\t2 : 500m\n";
			print "\t3 : 1km\n";
			print "\t4 : 5km\n";
			print "\t5 : 10km\n";
			print "\t6 : 50km\n";
			print "\t7 : 100km\n";
			print "=======================================\n";
			print "Distance ? ";

			$distance = <STDIN>;
			chomp($distance);
			## ';500;1000;5000;10000;50000;100000'
			## 'unlimited;500m;1km;5km;10km;50km;100km'
		}
		switch($distance) {
			case 1 { $distance = "unlimited"; }
			case 2 { $distance = "500m"; }
			case 3 { $distance = "1km"; }
			case 4 { $distance = "5km"; }
			case 5 { $distance = "10km"; }
			case 6 { $distance = "50km"; }
			case 7 { $distance = "100km"; }
		}
	}
	my $dropspag = undef;
	if (defined $arguments{dropspag}) { $dropspag = $arguments{dropspag}; }
	else {
		while ( (!defined $dropspag) || ($dropspag !~ /[1-5]/) ) {
			print "=======================================\n";
			print "\t1 : default\n";
			print "\t2 : 25\n";
			print "\t3 : 50\n";
			print "\t4 : 100\n";
			print "\t5 : All\n";
			print "=======================================\n";
			print "Drop per pages ? ";
			$dropspag = <STDIN>;
			chomp($dropspag);
			## ';25;50;100;99999'
			## 'default;25;50;100;All'

		}
		switch($dropspag) {
			case 1 { $dropspag = ""; }
			case 2 { $dropspag = "25"; }
			case 3 { $dropspag = "50"; }
			case 4 { $dropspag = "100"; }
			case 5 { $dropspag = "All"; }
		}
	}
	
	return ($location, $distance, $dropspag);
}

sub _setFormat { 
	my $libelle				= shift;
	my $encodeDestination	= shift;
	## text ; "iso-8859-1" ; "utf8" ; 
	$libelle = Encode::encode($encodeDestination, $libelle);
	return $libelle;
}

sub _setFormatFR { 
	my $libelle				= shift;
	## text ; "iso-8859-1" ; "utf8" ; 
	$libelle = Encode::encode("iso-8859-1", $libelle);
	return $libelle;
}

sub convertFormatsChar {
	my $cont = shift;

	if ($cont !~ /[éèêëàâùûôîïçÇêÉÈËÊÀÙÛÔÂÎÏ]+/) 
		{ $cont = Encode::encode_utf8($cont); }
		
	if ($cont =~ /Ã/) {
		$cont =~ s/Ã´/ô/g;
		$cont =~ s/Ã©/é/g;
		$cont =~ s/Ã¨/è/g;
		$cont =~ s/Ã«/ë/g;
		$cont =~ s/Ã¢/â/g;
		$cont =~ s/Â / /g;
		if ($cont =~ /Ã/) { print "\t'".$cont."'\n";getc(); }
	}
	
	return $cont;
}

sub convertFormatsLaTeX {
	my $cont = shift;

	## if ($cont !~ /[éèêëàâùûôîïçÇêÉÈËÊÀÙÛÔÂÎÏ]+/) {
		$cont =~ s/ê/\{\\^e\}/g;
		$cont =~ s/é/\{\\'e\}/g;
		$cont =~ s/è/\{\\`e\}/g;
		$cont =~ s/à/\{\\`a\}/g;
		$cont =~ s/â/\{\\^a\}/g;
		$cont =~ s/û/\{\\^u\}/g;
		$cont =~ s/ù/\{\\`u\}/g;
		$cont =~ s/ô/\{\\^o\}/g;
		$cont =~ s/î/\{\\^i\}/g;
		$cont =~ s/ç/\\c\{c\}/g;
		$cont =~ s/ä/{\\"a\}/g;
		$cont =~ s/ë/{\\"e\}/g;
		$cont =~ s/ï/{\\"i\}/g;
		$cont =~ s/ö/{\\"o\}/g;
		$cont =~ s/ü/{\\"u\}/g;
		
		$cont =~ s/Ê/\{\\^E\}/g;
		$cont =~ s/É/\{\\'E\}/g;
		$cont =~ s/È/\{\\`E\}/g;
		$cont =~ s/Î/\{\\^I\}/g;
		$cont =~ s/Ì/\{\\`I\}/g;
		$cont =~ s/Ï/\{\\"I\}/g;
		$cont =~ s/À/\{\\`A\}/g;
		$cont =~ s/Â/\{\\^A\}/g;
		$cont =~ s/Û/\{\\^U\}/g;
		$cont =~ s/Ù/\{\\`U\}/g;
		$cont =~ s/Ô/\{\\^O\}/g;
		$cont =~ s/Ç/\\c\{C\}/g;
	## }
	
	$cont =~ s/<a href="(.*?)" target="_blank">(.*?)<\/a>/\\texttt{$2}/g;
	$cont =~ s/#/\\#/g;
	$cont =~ s/&/\\&/g;
	$cont =~ s/_/\\_/g;
	$cont =~ s/~/\\textasciitilde /g;
	$cont =~ s/•/\$\\bullet\$/g;
	$cont =~ s/▲/\$\\bigtriangleup\$/g;
	$cont =~ s/ø/\$\\oslash\$/g;
	$cont =~ s/▬/--/g;
	$cont =~ s/’/'/g;
	$cont =~ s/…/.../g;
	
	
	
	
	return $cont;
}

sub _getLaTeXfooter {
	my $string = "";
	$string .= "\\end{document}\n";
	return $string;
}


sub _getLaTeXheader {
	my $string = "";
	$string .= "\\documentclass[11pt,twoside,a4paper]{article}\n";
	$string .= "% http://www-h.eng.cam.ac.uk/help/tpl/textprocessing/latex_maths+pix/node6.html symboles de math\n";
	$string .= "% http://fr.wikibooks.org/wiki/Programmation_LaTeX Programmation latex (wikibook)\n";
	$string .= "%=========================== En-Tete =================================\n";
	$string .= "%--- Insertion de paquetages (optionnel) ---\n";
	$string .= "\\usepackage[french]{babel}   % pour dire que le texte est en fran{\\c{c}}ais\n";
	$string .= "\\usepackage{a4}	             % pour la taille \n";  
	$string .= "\\usepackage[T1]{fontenc}     % pour les font postscript\n";
	$string .= "\\usepackage{epsfig}          % pour gerer les images\n";
	$string .= "%\\usepackage{psfig}\n";
	$string .= "\\usepackage{amsmath, amsthm} % tres bon mode mathematique\n";
	$string .= "\\usepackage{amsfonts,amssymb}% permet la definition des ensembles\n";
	$string .= "\\usepackage{float}           % pour le placement des figure\n";
	$string .= "\\usepackage{verbatim}\n\n";
	$string .= "\\usepackage{longtable} % pour les tableaux de plusieurs pages\n";
	$string .= "\\usepackage[table]{xcolor} % couleur de fond des cellules de tableaux\n";
	$string .= "\\usepackage{lastpage}\n";
	$string .= "\\usepackage{multirow}\n";
	$string .= "\\usepackage{multicol} % pour {\\'e}crire dans certaines zones en colonnes : \\begin{multicols}{nb colonnes}...\\end{multicols}\n\n"; 
	$string .= "% \\usepackage[top=1.5cm, bottom=1.5cm, left=1.5cm, right=1.5cm]{geometry}\n";
	$string .= "% gauche, haut, droite, bas, entete, ente2txt, pied, txt2pied\n";
	$string .= "\\usepackage{vmargin}\n";
	$string .= "\\setmarginsrb{1.00cm}{1.00cm}{1.00cm}{1.00cm}{15pt}{3pt}{50pt}{20pt}\n\n";
	$string .= "\\usepackage{lscape} % changement orientation page\n";
	$string .= "%\\usepackage{frbib} % enlever pour obtenir references en anglais\n";
	$string .= "% --- style de page (pour les en-tete) ---\n";
	$string .= "\\pagestyle{empty}\n\n";
	$string .= "\\def\\txtTITLE{List of Dead Drops} %%%%% !! TITRE !! %%%%%\n";
	$string .= "\\def\\imgCORNER{\\includegraphics[width=0.25cm]{img/glider/logo-glider.png}}\n";
	$string .= "\\def\\imgGLIDERLEFTT{\\includegraphics[width=1.95cm]{img/glider/logo-glider-left.png}}\n";
	$string .= "\\def\\imgGLIDERRIGHT{\\includegraphics[width=1.95cm]{img/glider/logo-glider-right.png}}\n";
	$string .= "\\def\\imgGLIDERLEFTTsmall{\\includegraphics[width=0.25cm]{img/glider/logo-glider-left.png}}\n";
	$string .= "\\def\\imgGLIDERRIGHTsmall{\\includegraphics[width=0.25cm]{img/glider/logo-glider-right.png}}\n\n";
	$string .= "%--- Definitions de nouvelles couleurs ---\n";
	$string .= "\\definecolor{verylightgrey}{rgb}{0.8,0.8,0.8}\n";
	$string .= "\\definecolor{verylightgray}{gray}{0.80}\n";
	$string .= "\\definecolor{lightgrey}{rgb}{0.6,0.6,0.6}\n";
	$string .= "\\definecolor{lightgray}{gray}{0.6}\n\n";
	$string .= "% % % en-tete et pieds de page configurables : fancyhdr.sty\n";
	$string .= "% http://www.trustonme.net/didactels/250.html\n";
	$string .= "% http://ww3.ac-poitiers.fr/math/tex/pratique/entete/entete.htm\n";
	$string .= "% http://www.ctan.org/tex-archive/macros/latex/contrib/fancyhdr/fancyhdr.pdf\n";
	$string .= "\\usepackage{fancyhdr}\n";
	$string .= "\\pagestyle{fancy}\n";
	$string .= "% \\newcommand{\\chaptermark}[1]{\\markboth{\#1}{}}\n";
	$string .= "% \\newcommand{\\sectionmark}[1]{\\markright{\\thesection\ \#1}}\n";
	$string .= "\\fancyhf{}\n";
	$string .= "\\fancyhead[LE,RO]{\\bfseries\\thepage}\n";
	$string .= "\\fancyhead[LO]{\\bfseries\\rightmark}\n";
	$string .= "\\fancyhead[RE]{\\bfseries\\leftmark}\n";
	$string .= "\\fancyfoot[LE]{\\thepage /\\pageref{LastPage} \\hfill\n";
	$string .= "\\t\\scriptsize{\\txtTITLE} % TITLE\n";
	$string .= "\\hfill \\imgGLIDERLEFTTsmall }\n";
	$string .= "\\fancyfoot[RO]{\\imgGLIDERRIGHTsmall \\hfill\n";
	$string .= "\t\\scriptsize{\\txtTITLE} % TITLE\n";
	$string .= "\\hfill \\thepage /\\pageref{LastPage}}\n";
	$string .= "\\renewcommand{\\headrulewidth}{0.5pt}\n";
	$string .= "\\renewcommand{\\footrulewidth}{0.5pt}\n";
	$string .= "\\addtolength{\\headheight}{0.5pt}\n";
	$string .= "% \\fancypagestyle{plain}{\n";
	$string .= "\t% \\fancyhead{}\n";
	$string .= "\t% \\renewcommand{\\headrulewidth}{0pt}\n";
	$string .= "% }\n\n";
	$string .= "\\title{\\txtTITLE}\n";
	$string .= "\\date{ --- }\n\n";
	$string .= "%============================= Corps =================================\n";
	$string .= "\\begin{document}\n\n";
	$string .= "\\setlength\\parindent{0pt} % \\noindent for all document\n\n";
	$string .= "~\\\\\n\n";
	$string .= "\\vfill\n\n";
	$string .= "\\begin{center}\n";
	$string .= "\t\\textbf{\\huge \\txtTITLE}\n";
	$string .= "\\end{center}\n\n";
	$string .= "\\vfill\n\n";
	$string .= "\\clearpage\n\n";
	return $string;	
}

sub _getLaTeXMakefile {
	my $string = "";
	$string .= "## naming WITHOUT the extensions [.tex] or [.bib]\n";
	$string .= "LATEXFILE=document\n\n";
	$string .= "## the local software...\n";
	$string .= "CCPDFLA=pdflatex\n";
	$string .= "CCLATEX=latex\n";
	$string .= "CCBIBTE=bibtex\n";
	$string .= "CCPDFTE=dvipdf\n";
	$string .= "CCPSTEX=dvips\n\n";
	$string .= "all : pdflatex\n\n";
	$string .= "pdf : \$(LATEXFILE).dvi\n";
	$string .= "\t\$(CCPDFTE) \$(LATEXFILE).dvi\n\n";
	$string .= "ps : \$(LATEXFILE).dvi\n";
	$string .= "\t\$(CCPSTEX) \$(LATEXFILE).dvi\n\n";
	$string .= "cleanpdf : clean\n";
	$string .= "\trm \$(LATEXFILE).pdf\n\n";
	$string .= "clean : mrproper\n";
	$string .= "\t# rm \$(LATEXFILE).dvi\n\n";
	$string .= "mrproper : \$(LATEXFILE).aux \$(LATEXFILE).log \n";
	$string .= "\trm \$(LATEXFILE).aux\n";
	$string .= "\trm \$(LATEXFILE).log\n\n";
	$string .= "$(LATEXFILE).dvi : \$(LATEXFILE).tex\n";
	$string .= "\t\$(CCLATEX) \$(LATEXFILE).tex\n";
	$string .= "\t\$(CCLATEX) \$(LATEXFILE).tex\n";
	$string .= "\t\$(CCLATEX) \$(LATEXFILE).tex\n\n";
	$string .= "pdflatex : \$(LATEXFILE).tex\n";
	$string .= "\t\$(CCPDFLA) \$(LATEXFILE).tex\n";
	$string .= "\t\$(CCPDFLA) \$(LATEXFILE).tex\n";
	$string .= "\t\$(CCPDFLA) \$(LATEXFILE).tex\n\n";
	return $string;
}


