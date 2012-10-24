package Test::Ika;
use strict;
use warnings;
use 5.010001;
our $VERSION = '0.01';

use Try::Tiny;
use Module::Load;
use Test::Name::FromLine;

use Test::Ika::Context;
use Test::Ika::It;

use parent qw/Exporter/;

our @EXPORT = (qw(
    describe it context
    before_all after_all before_each after_each
    runtests
));


our $FINISHED;
our $ROOT = our $CURRENT = Test::Ika::Context->new(name => 'root');

our $REPORTER = do {
    my $module = $ENV{TEST_MAX_REPORTER};
    unless ($module) {
        $module = $ENV{HARNESS_ACTIVE} || $^O eq 'MSWin32' ? 'TAP' : 'Spec';
    }
    $module = $module =~ s/^\+// ? $module : "Test::Ika::Reporter::$module";
    Module::Load::load($module);
    $module->new();
};

sub describe {
    my ($name, $code) = @_;

    my $current = $CURRENT;
    my $context = Test::Ika::Context->new(
        name   => $name,
        parent => $current,
    );
    {
        local $CURRENT = $context;
        $code->();
    }
    $current->push_context($context);
}
*context = *describe;

sub it {
    my ($name, $code) = @_;
    my $it = Test::Ika::It->new(name => $name, code => $code);
    $CURRENT->push_it($it);
}

sub before_all(&) {
    my $code = shift;
    $CURRENT->add_trigger(before_all => $code);
}

sub after_all(&) {
    my $code = shift;
    $CURRENT->add_trigger(after_all => $code);
}

sub before_each(&) {
    my $code = shift;
    $CURRENT->add_trigger(before_each => $code);
}

sub after_each(&) {
    my $code = shift;
    $CURRENT->add_trigger(after_each => $code);
}

sub runtests {
    $ROOT->run();

    $FINISHED++;
    $REPORTER->finalize();
}

END {
    unless ($FINISHED) {
        runtests();
    }
}

1;
__END__

=encoding utf8

=head1 NAME

Test::Ika - B!D!D! B!D!D!

=head1 SYNOPSIS

    use Test::Ika;
    use Test::Expects;

    describe 'MessageFilter' => sub {
        my $filter;

        before_each {
            $filter = MessageFilter->new();
        };

        it 'should detect message with NG word' => sub {
            my $filter = MessageFilter->new('foo');
            expect($filter->detect('hello foo'))->ok;
        };
        it 'should detect message with NG word' => sub {
            my $filter = MessageFilter->new('foo');
            expect($filter->detect('hello foo'))->ok;
        };
    };

    runtests;

=head1 DESCRIPTION

Test::Ika is yet another BDD framework for Perl5.

This module provides pretty output for testing.

=over 4

=item The spec mode(default)

=begin html

<div><img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/spec.png"></div>

<div><img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/spec2.png"></div>

=end html

=item TAP output(it's enabled under $ENV{HARNESS_ACTIVE} is true)

=begin html

<img src="https://raw.github.com/tokuhirom/Test-Ika/master/img/tap.png">

=end html

=back

=head1 Why Ika?

This module is dedicated to ikasam_a, a famous Japanese testing engineer.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut