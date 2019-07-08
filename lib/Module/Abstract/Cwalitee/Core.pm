package Module::Abstract::Cwalitee::Core;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

#use Module::Abstract::CwaliteeCommon;

our %SPEC;

$SPEC{indicator_not_empty} = {
    v => 1.1,
    args => {
    },
    #'x.indicator.error'    => '', #
    #'x.indicator.remedy'   => '', #
    #'x.indicator.severity' => '', # 1-5
    #'x.indicator.status'   => '', # experimental, stable*
    'x.indicator.priority' => 1,
};
sub indicator_not_empty {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined($ab) && $ab =~ /\S/ ?
        [200, "OK", ''] : [200, "OK", 'Abstract is empty'];
}

$SPEC{indicator_not_too_short} = {
    v => 1.1,
    args => {
        min_len => {
            schema => 'uint*',
            default => 10,
        },
    },
};
sub indicator_not_too_short {
    my %args = @_;
    my $min_len = $args{min_len} // 10;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    length $ab >= $min_len ?
        [200, "OK", ''] : [200, "OK", "Abstract is too short (<$min_len characters)"];
}

$SPEC{indicator_not_too_long} = {
    v => 1.1,
    args => {
        max_len => {
            schema => 'uint*',
            default => 72,
        },
    },
};
sub indicator_not_too_long {
    my %args = @_;
    my $max_len = $args{max_len} // 72;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    length $ab <= $max_len ?
        [200, "OK", ''] : [200, "OK", "Abstract is too long (>$max_len characters)"];
}

$SPEC{indicator_not_multiline} = {
    v => 1.1,
    args => {
    },
};
sub indicator_not_multiline {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    $ab !~ /\R/ ?
        [200, "OK", ''] : [200, "OK", 'Abstract is multiline'];
}

$SPEC{indicator_not_template} = {
    v => 1.1,
    args => {
    },
};
sub indicator_not_template {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    if ($ab =~ /^(Perl extension for blah blah blah)/i) {
        [200, "OK", "Template from h2xs '$1'"];
    } elsif ($ab =~ /^(The great new )\w+(::\w+)*/i) {
        [200, "OK", "Template from module-starter '$1'"];
    } elsif ($ab =~ /^\b(blah blah)\b/i) {
        [200, "OK", "Looks like a template"];
    } else {
        [200, "OK", ""];
    }
}

$SPEC{indicator_not_start_with_lowercase_letter} = {
    v => 1.1,
    args => {
    },
};
sub indicator_not_start_with_lowercase_letter {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    $ab !~ /^\s*[a-z]/ ?
        [200, "OK", ""] : [200, "OK", "Abstract starts with a lowercase letter"];
}

$SPEC{indicator_not_end_with_dot} = {
    v => 1.1,
    args => {
    },
};
sub indicator_not_end_with_dot {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    $ab !~ /\.\s*\z/ ?
        [200, "OK", ''] : [200, "OK", "Abstract ends with dot"];
}

$SPEC{indicator_not_redundant} = {
    v => 1.1,
    args => {
    },
};
sub indicator_not_redundant {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    if ($ab =~ /^( (?: (?:a|the) \s+)?
                    (?: perl\s?[56]? \s+)?
                    (?:extension|module|library|interface|xs \s binding)
                    (?: \s+ (?:to|for))?
                )/xi) {
        return [200, "OK", "Saying '$1' is redundant, omit it"];
    } else {
        [200, "OK", ''];
    }
}

$SPEC{indicator_language_english} = {
    v => 1.1,
    args => {
    },
};
sub indicator_language_english {
    require Lingua::Identify::Any;

    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    my $dlres = Lingua::Identify::Any::detect_text_language(text=>$ab);
    return [412, "Cannot detect language: $dlres->[0] - $dlres->[1]"]
        unless $dlres->[0] == 200;

    if ($dlres->[2]{'lang_code'} ne 'en') {
        [200, "OK", "Language not detected as English ".
             sprintf("(%s, confidence %.2f)",
                     $dlres->[2]{lang_code},
                     $dlres->[2]{confidence} // 0,
                 )];
    } else {
        [200, "OK", ''];
    }
}

$SPEC{indicator_no_shouting} = {
    v => 1.1,
    args => {
    },
};
sub indicator_no_shouting {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    if ($ab =~ /!{3,}/) {
        [200, "OK", "Too many exclamation points"];
    } else {
        my $spaces = 0; $spaces++ while $ab =~ s/\s+//;
        $ab =~ s/\W+//g;
        $ab =~ s/\d+//g;
        if ($ab =~ /^[[:upper:]]+$/ && $spaces >= 2) {
            return [200, "OK", "All-caps"];
        } else {
            return [200, "OK", ''];
        }
    }
}

$SPEC{indicator_not_module_name} = {
    v => 1.1,
    args => {
    },
};
sub indicator_not_module_name {
    my %args = @_;
    my $r = $args{r};

    my $ab = $r->{abstract};
    defined $ab or return [412];

    if ($ab =~ /^\w+(::\w+)+$/) {
        [200, "OK", "Should not just be a module name"];
    } else {
        [200, "OK", ''];
    }
}

1;
# ABSTRACT: A collection of core indicators for module abstract cwalitee
