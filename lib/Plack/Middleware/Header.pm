package Plack::Middleware::Headers;

use strict;
use 5.008_001;
use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(set append unset code when);

use Plack::Util;
use Scalar::Util qw(reftype);

our $VERSION = '0.06';

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
                    if (!defined $check) {            # missing header
                        next if defined $value;     
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
                Plack::Util::header_iter($self->set, sub {Plack::Util::header_set($headers, @_)});
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

=head1 NAME

Plack::Middleware::Headers - modify HTTP response headers

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

Plack::Middleware::Headers

=head1 AUTHOR

Masahiro Chiba

=head1 CONTRIBUTORS

Wallace Reis C<wreis@cpan.org>,
Jakob Voß

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Plack::Middleware>, L<Plack::Builder>

=encoding utf8

=cut
