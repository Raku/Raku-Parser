use v6;

use Test;
use Raku::Parser;
use Raku::Parser::Factory;

plan 2;

my $pp                 = Raku::Parser.new;
my $ppf                = Raku::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  my $parsed = $pp.to-tree( Q{} );
  $ppf.thread( $parsed );

  ok $parsed ~~ Raku::Document, Q{root is a document};

  subtest {
    ok $parsed.is-root,           Q{root is root};
    ok $parsed.is-start,          Q{root is start};
#`{ ok !$parsed.is-start-leaf,    Q{root is not start-leaf}; }
    ok $parsed.is-end,            Q{root is end};
#`{ ok !$parsed.is-end-leaf,      Q{root is end-leaf}; }

#`{ Should twig be "accurate" based on whether the node is actually on its own
    or should it be based upon the type? } 
    ok $parsed.is-twig,       Q{root is a twig};
    ok !$parsed.is-leaf,      Q{root is not a leaf};
  }, Q{root predicates};

  subtest {
    ok $parsed.next, Q{root has a next node};
    ok $parsed.next ~~ Raku::Document, Q{next node loops back};
    ok $parsed.next === $parsed, Q{next node is the root node};

    ok $parsed.previous, Q{root has a previous node};
    ok $parsed.previous ~~ Raku::Document, Q{previous node loops back};
    ok $parsed.previous === $parsed, Q{previous node is the root node};

    ok $parsed.parent, Q{root has a parent node};
    ok $parsed.parent ~~ Raku::Document, Q{parent node loops back};
    ok $parsed.parent === $parsed, Q{parent node is the root node};
  }, Q{root accessors};
}, Q{empty file};

subtest {
  my $parsed = $pp.to-tree( Q{my $a = 1;} );
  $ppf.thread( $parsed );

  ok $parsed.first-child ~~ Raku::Statement,
	Q{first child is a Statement};
  ok $parsed.last-child ~~ Raku::Statement,
	Q{last child is (the same) Statement};

  $parsed = $parsed.first-child;

  subtest {
    my $bareword = $parsed.first-child;

    ok $bareword ~~ Raku::Bareword, Q{has correct type};
    is $bareword.content, 'my', Q{has correct content};
  }, Q{'my'};

  subtest {
    my $semicolon = $parsed.last-child;

    ok $semicolon ~~ Raku::Semicolon, Q{has correct type};
    is $semicolon.content, ';', Q{has correct content};
  }, Q{';'};
}, Q{my $a = 1;};

# vim: ft=raku
