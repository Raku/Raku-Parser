use v6;

use Test;
use Raku::Parser;

plan 3;

my $pp                 = Raku::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  my $parsed = $pp.to-tree( Q{} );

  ok $parsed ~~ Raku::Document, Q{document};
  ok $parsed.is-twig, Q{document is a branch};
  is $parsed.child.elems, 0, Q{document has no children};
}, Q{empty file};

subtest {
  my $parsed = $pp.to-tree( Q{ } );

  subtest {
    ok $parsed ~~ Raku::Document, Q{document};
    ok $parsed.is-twig, Q{document is a branch};
    is $parsed.child.elems, 1, Q{document has one WS child};
    $parsed = $parsed.child.[0];
  }, Q{document root};

  subtest {
    ok $parsed ~~ Raku::WS, Q{whitespace};
    ok $parsed.is-leaf, Q{whitespace is a leaf};
  }, Q{whitespace};
}, Q{''};

subtest {
  my $parsed = $pp.to-tree( Q{my $a = 1;} );

  subtest {
    ok $parsed ~~ Raku::Document, Q{type is correct};
    ok $parsed.is-twig, Q{is a branch};
    is $parsed.child.elems, 1, Q{has children};
  }, Q{document root};

  $parsed = $parsed.child.[0];

  subtest {
    ok $parsed ~~ Raku::Statement, Q{type is correct};
    ok $parsed.is-twig, Q{statement is a leaf};
    is $parsed.child.elems, 8, Q{has children};
#    is $parsed.content, Q{my $a;}, Q{statement has correct content};
  }, Q{Statement 'my $a;'};

  my $count = 0;

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::Bareword, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{my}, Q{has correct content};
  }, Q{Bareword 'my'};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::WS, Q{type is correct};
    ok $_parsed.is-leaf, Q{whitespace is a leaf};
    is $_parsed.content, Q{ }, Q{has correct content};
  }, Q{WS ' '};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::Variable::Scalar, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{$a}, Q{has correct content};
  }, Q{Variable::Scalar '$a'};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::WS, Q{type is correct};
    ok $_parsed.is-leaf, Q{whitespace is a leaf};
    is $_parsed.content, Q{ }, Q{has correct content};
  }, Q{WS ' '};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::Operator, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{=}, Q{has correct content};
  }, Q{Operator '='};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::WS, Q{type is correct};
    ok $_parsed.is-leaf, Q{whitespace is a leaf};
    is $_parsed.content, Q{ }, Q{has correct content};
  }, Q{WS ' '};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::Number::Decimal, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{1}, Q{has correct content};
  }, Q{Operator '1'};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Raku::Semicolon, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{;}, Q{has correct content};
  }, Q{Semicolon ';'};
}, Q{my $a = 1;};

# vim: ft=raku
