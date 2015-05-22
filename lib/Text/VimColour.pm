#!/usr/bin/env perl6
use v6;
use File::Temp;
class Text::VimColour:ver<0.1> {
    subset File   of Str where -> $x { so $x && $x.IO.e };
    subset Path  of Str where -> $x { so $x && $x.IO.dirname.IO.e } 
    has Path  $!out;
    has File  $!in;
    has Str   $!lang;
    
    method BUILDALL(|z) {
	my $version = .shift given split /','/, q:x/ex --version/;
	die "didn't find a recent vim/ex"  unless $version ~~ /' Vi IMproved 7.4 '/;
	callsame;
    }

    method !proceed-file {
	$!lang //= 'perl6';
	my $cmd = qq«
		vim -c 'set bg=light|set ft=$!lang|TOhtml|wq! $!out|quit' $!in 2>&1 >/dev/null 
	»;
	my $proc = shell $cmd;
	fail "failed to run '$cmd', exit code {$proc.exitcode}" unless $proc.exitcode == 0;
    }
    
    multi submethod BUILD(Str :$!lang, File :$!in,  Path :$!out) {
	self!proceed-file;
    }
    
    multi submethod BUILD(Str :$!lang, File :$!in) {
	$!out = tempfile[0];
	self!proceed-file;
    }
    multi submethod BUILD(Str  :$!lang, Str :$code where $code.chars > 0) {
	$!in  = tempfile[0];
	$!in.IO.spurt: $code;
	$!out = tempfile[0];
	self!proceed-file;
    }
    
    method html-full-page returns Str{
	$!out.IO.slurp;
    }
    method html  {
	my $html = $!out.IO.slurp;
	$html ~~  m/  '<body>'  (.*) '</body>' / && ~$0;
    }

    method css   {
	my $html = $!out.IO.slurp;
	$html ~~  m/  '<style type="text/css">'  (.*?) '</style>' / && ~$0;
    }
    
}
