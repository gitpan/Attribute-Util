#!/usr/bin/perl

use warnings;
use strict;
use Test;

BEGIN { plan tests => 3 }

use Attribute::Util;

sub myalrm : SigHandler(ALRM, VTALRM) {
	our $whereabouts = 'in myalrm';
}

sub mywarn : SigHandler(__WARN__) {
	our $whereabouts = 'in mywarn';
}

sub mywarn2 : SigHandler(__WARN__) {
	our $whereabouts = 'in mywarn2';
}

our $whereabouts;
ok($whereabouts, undef);

warn "oh no!";
ok($whereabouts, 'in mywarn2');

alarm(1);
sleep(2);
ok($whereabouts, 'in myalrm');
