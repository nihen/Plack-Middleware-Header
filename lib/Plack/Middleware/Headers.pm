package Plack::Middleware::Headers;
#ABSTRACT: modify HTTP response headers

use strict;
use 5.008_001;
use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(set append unset code when);

use Plack::Util;
use Scalar::Util qw(reftype);

#VERSION

sub call {
    my $self = shift; 
    my $res  = $self->app->(@_);

    $self->response_cb(
        $res,
        sub {
            my $res = shift;

            if ($self->code and $self->code ne $res->[0]) {
                return;
            }

            my $headers = $res->[1];

            if ($self->when) {
                my @when  = @{$self->when};
                my $match = 0;
                while (my($key, $check) = splice @when, 0, 2) {
                    my $value = Plack::Util::header_get($headers, $key);
                    if (!defined $check) {            # missing header check
                        next if defined $value;     
                    } elsif( !defined $value ) {      # header missing
                        next;
                    } elsif( ref $check ) {           # regex match header
                        next if $value !~ $check;
                    } elsif ( $value ne $check ) {    # exact header
                        next;
                    }
                    $match = 1; 
                    last;
                }
                return unless $match;
            }
            if ( $self->set ) {
                Plack::Util::header_iter(
                    $self->set, sub {Plack::Util::header_set($headers, @_)}
                );
            }
            if ( $self->append ) {
                push @$headers, @{$self->append};
            }
            if ( $self->unset ) {
                Plack::Util::header_remove($headers, $_) for @{$self->unset};
            }
        }
    );
}

1;

__END__

=head1 SYNOPSIS

  use Plack::Builder;

  builder {
      enable 'Headers',
        set    => ['X-Plack-One' => '1'],
        append => ['X-Plack-Two' => '2'],
        unset  => ['X-Plack-Three'];
      enable 'Headers',
        code   => '404',
        set    => ['X-Robots-Tag' => 'noindex, noarchive, follow'];
      enable 'Headers',
        when   => ['Content-Type' => qr{^text/}],
        set    => ['Content-Type' => 'text/plain'];

      sub {['200', [], ['hello']]};
  };

=head1 DESCRIPTION

This L<Plack::Middleware> simplifies creation (C<set> or C<append>), deletion
(C<unset>), and modification (C<set>) of L<PSGI> response headers. The
modification can be enabled based on response code (C<code>) or existing
response headers(C<when>). Use L<Plack::Middleware::Conditional> to enable the
middleware based in I<request> headers.

Plack::Middleware::Headers

=head1 CONTRIBUTORS

This module is an extened fork of L<Plack::Middleware::Header>, originally
created by Masahiro Chiba. Additional contributions by Wallace Reis.

=head1 SEE ALSO

L<Plack::Middleware>, L<Plack::Builder>

=encoding utf8

=cut
