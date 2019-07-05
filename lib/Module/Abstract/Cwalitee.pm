package Module::Abstract::Cwalitee;

# DATE
# VERSION

use 5.010001;
use strict 'subs', 'vars';
use warnings;
use Log::ger;

use Cwalitee::Common;

use Exporter qw(import);
our @EXPORT_OK = qw(
                       calc_module_abstract_cwalitee
                       list_module_abstract_cwalitee_indicators
               );

our %SPEC;

$SPEC{list_module_abstract_cwalitee_indicators} = {
    v => 1.1,
    args => {
        %Cwalitee::Common::args_list,
    },
};
sub list_module_abstract_cwalitee_indicators {
    my %args = @_;

    Cwalitee::Common::list_cwalitee_indicators(
        prefix => 'Module::Abstract::',
        %args,
    );
}

$SPEC{calc_module_abstract_cwalitee} = {
    v => 1.1,
    args => {
        %Cwalitee::Common::args_calc,
        abstract => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
    },
};
sub calc_module_abstract_cwalitee {
    my %fargs = @_;

    Cwalitee::Common::calc_cwalitee(
        prefix => 'Module::Abstract::',
        %fargs,
        code_init_r => sub {
            return {
                # module => ...
                abstract => $fargs{abstract},
            },
        },
    );
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
