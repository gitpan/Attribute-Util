package Attribute::Util;

use warnings;
use strict;
use Attribute::Handlers;

our $VERSION = '0.02';

sub UNIVERSAL::Memoize :ATTR(CODE) {
	my ($pkg, $symbol, $options) = @_[0,1,4];
	$options = [ $options || () ] unless ref $options eq 'ARRAY';
	require Memoize;
	Memoize::memoize($pkg . '::' . *{$symbol}{NAME}, @$options);
}

sub UNIVERSAL::Abstract :ATTR(CODE) {
	my ($pkg, $symbol) = @_;
	no strict 'refs';
	my $sub = $pkg . '::' . *{$symbol}{NAME};
	*{$sub} = sub {
		my ($file, $line) = (caller)[1,2];
		die "call to abstract method $sub at $file line $line.\n";
	};
}

sub UNIVERSAL::Alias : ATTR {
	my ($pkg, $symbol, $data) = @_[0,1,4];
	no strict 'refs';
	*{"$pkg\::$_"} = $symbol for ref $data eq 'ARRAY' ? @$data : $data;
}

sub UNIVERSAL::SigHandler : ATTR(CODE) {
	my ($symbol, $data) = @_[1,4];
	$SIG{$_} = *{$symbol}{NAME} for ref $data eq 'ARRAY' ? @$data : $data;
}

"Rosebud";

__END__

=head1 NAME

Attribute::Util - A selection of general-utility attributes

=head1 SYNOPSIS

  use Attribute::Util;

  # Alias

  sub color : Alias(colour) { return 'red' }

  # Abstract

  package MyObj;
  sub new { ... }
  sub somesub: Abstract;

  package MyObj::Better;
  use base 'MyObj';
  sub somesub { return "I'm implemented!" }

  # Memoize

  sub fib :Memoize {
          my $n = shift;
          return $n if $n < 2;
          fib($n-1) + fib($n-2);
  }
  
  $|++;
  print fib($_),"\n" for 1..50;

  # SigHandler

  sub myalrm : SigHandler(ALRM, VTALRM) { ...  }
  sub mywarn : SigHandler(__WARN__) { ... }

=head1 DESCRIPTION

This module provides four universally accessible attributes of
general interest:

=over 4

=item Memoize

This attribute makes it slightly easier (and modern) to memoize a
function by providing an attribute, C<:Memoize> that makes it
unnecessary for you to explicitly call C<Memoize::memoize()>.
Options can be passed via the attribute per usual (see the
C<Attribute::Handlers> manpage for details, and the C<Memoize>
manpage for information on memoizing options):

  sub f :Memoize(NORMALIZER => 'main::normalize_f') {
  	...
  }

However, since the call to C<memoize()> is now done in a different
package, it is necessary to include the package name in any function
names passed as options to the attribute, as shown above.

=item Abstract

Declaring a subroutine to be abstract using this attribute causes
a call to it to die with a suitable exception. Subclasses are
expected to implement the abstract method.

Using the attribute makes it visually distinctive that a method is
abstract, as opposed to declaring it without any attribute or method
body, or providing a method body that might make it look as though
it was implemented after all.

=item Alias

If you need a variable or subroutine to be known by another name,
use this attribute. Internally, the attribute's handler assigns
typeglobs to each other. As such, the C<Alias> attribute provides
a layer of abstraction. If the underlying mechanism changes in a
future version of Perl (say, one that might not have the concept
of typeglobs anymore :), a new version of this module will take
care of that, but your C<Alias> declarations are going to stay the
same.

Note that assigning typeglobs means that you can't specify a synonym
for one element of the glob and use the same synonym for a different
target name in a different slot. I.e.,

  sub color :Alias(colour) { ... }
  my $farbe :Alias(colour);

doesn't make sense, since the sub declaration aliases the whole
C<colour> glob to C<color>, but then the scalar declaration aliases
the whole C<colour> glob to C<farbe>, so the first alias is lost.

=item SigHandler

When used on a subroutine, this attribute declares that subroutine
to be a signal handler for the signal(s) given as options for this
attribute. It thereby frees you from the implementation details of
defining sig handlers and keeps the handler definitions where they
belong, namely with the handler subroutine.

=back

=head1 BUGS

None known so far. If you find any bugs or oddities, please do inform the
author.

=head1 AUTHOR

Marcel Grunauer, <marcel@codewerk.com>

=head1 COPYRIGHT

Copyright 2001 Marcel Grunauer. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Attribute::Handlers(3pm), Memoize(3pm).

=cut
