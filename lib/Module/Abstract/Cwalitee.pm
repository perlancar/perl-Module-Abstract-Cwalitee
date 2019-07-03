package Module::Abstract::Cwalitee;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use Log::ger;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       calc_module_abstract_cwalitee
                       list_module_abstract_cwalitee_indicators
               );

our %SPEC;

$SPEC{list_module_abstract_cwalitee_indicators} = {
    v => 1.1,
    args => {
        detail => {
            schema => 'bool*',
            cmdline_aliases=>{l=>{}},
        },
        # XXX filter by severity
        # XXX filter by module
        # XXX filter by status
    },
};
sub list_module_abstract_cwalitee_indicators {
    require PERLANCAR::Module::List;

    my %args = @_;

    my @res;

    my $mods = PERLANCAR::Module::List::list_modules(
        'Module::Abstract::Cwalitee::', {list_modules=>1, recurse=>1});
    for my $mod (sort keys %$mods) {
        (my $mod_pm = "$mod.pm") =~ s!::!/!g;
        require $mod_pm;
        my $spec = \%{"$mod\::SPEC"};
        for my $func (sort keys %$spec) {
            next unless $func =~ /\Aindicator_/;
            my $funcmeta = $spec->{$func};
            (my $name = $func) =~ s/\Aindicator_//;
            my $rec = {
                name => $name,
                summary  => $funcmeta->{summary},
                priority => $funcmeta->{'x.indicator.priority'} // 50,
                severity => $funcmeta->{'x.indicator.severity'} // 3,
                status   => $funcmeta->{'x.indicator.status'} // 'stable',
            };
            if ($args{_return_coderef}) {
                $rec->{code} = \&{"$mod\::$func"};
            }
            push @res, $rec;
        }
    }

    unless ($args{detail}) {
        @res = map { $_->{name} } @res;
    }

    [200, "OK", \@res];
}

$SPEC{calc_module_abstract_cwalitee} = {
    v => 1.1,
    args => {
        abstract => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
    },
};
sub calc_module_abstract_cwalitee {
    my %args = @_;

    my $res = list_module_abstract_cwalitee_indicators(
        detail => 1,
        _return_coderef => 1,
    );
    return $res unless $res->[0] == 200;

    my @res;
    my $r = {
        # module => ...
        abstract => $args{abstract},
    };
    my $num_run = 0;
    my $num_success = 0;
    my $num_fail = 0;
    for my $ind (sort {
        $a->{priority} <=> $b->{priority} ||
            $a->{name} cmp $b->{name}
        } @{ $res->[2] }) {
        my $indres = $ind->{code}->(r => $r);
        $num_run++;
        my ($result, $result_summary);
        if ($indres->[0] == 200) {
            if ($indres->[2]) {
                $result = 0;
                $num_fail++;
                $result_summary = $indres->[2];
            } else {
                $result = 1;
                $num_success++;
                $result_summary = '';
            }
        } elsif ($indres->[0] == 412) {
            $result = undef;
            $result_summary = "Cannot be run".($indres->[1] ? ": $indres->[1]" : "");
        } else {
            return [500, "Unexpected result when checking indicator ".
                        "'$ind->{name}': $indres->[0] - $indres->[1]"];
        }
        my $res = {
            num => $num_run,
            indicator => $ind->{name},
            priority => $ind->{priority},
            severity => $ind->{severity},
            summary  => $ind->{summary},
            result => $result,
            result_summary => $result_summary,
        };
        push @res, $res;
    }

    push @res, {
        indicator      => 'Score',
        result         => sprintf("%.2f", $num_run ? ($num_success / $num_run)*100 : 0),
        result_summary => "$num_success out of $num_run",
    };

    [200, "OK", \@res];
}

1;
# ABSTRACT: Calculate the cwalitee of your module Abstract

=head1 SYNOPSIS

 use Module::Abstract::Cwalitee qw(
     calc_module_abstract_cwalitee
     list_module_abstract_cwalitee_indicators
 );

 my $res = calc_module_abstract_cwalitee(
     abstract => 'Calculate the cwalitee of your module Abstract',
 );


=head1 DESCRIPTION

B<What is module abstract cwalitee?> A metric to attempt to gauge the quality of
your module's Abstract. Since actual quality is hard to measure, this metric is
called a "cwalitee" instead. The cwalitee concept follows "kwalitee" [1] which
is specifically to measure the quality of CPAN distribution. I pick a different
spelling to avoid confusion with kwalitee. And unlike kwalitee, the unqualified
term "cwalitee" does not refer to a specific, particular subject. There can be
"module abstract cwalitee" (which is handled by this module), "CPAN Changes
cwalitee", and so on.


=head1 SEE ALSO

[1] L<https://cpants.cpanauthors.org/>

L<App::ModuleAbstractCwaliteeUtils> for the CLI's.

=cut
