use v6;

use Test;
use Raku::Parser;

plan 6;

my $pp                 = Raku::Parser.new;
my $ppf                = Raku::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*UPDATE-RANGES     = True;
my $*FALL-THROUGH      = True;

sub check-node(
	Raku::Element $element, Mu $type, Mu $parent, Int $from, Int $to ) {
	my $is-ok = True;
	unless $element ~~ $type {
		diag "expected type '$type', got type '{$element.WHAT.perl}'";
		$is-ok = False;
	}
	unless $element.parent ~~ $parent {
		diag "expected parent '$type', got type '{$element.WHAT.perl}'";
		$is-ok = False;
	}
	unless $element.from == $from {
		diag "expected from $from, got {$element.from}";
		$is-ok = False;
	}
	unless $element.to == $to {
		diag "expected to $to, got {$element.to}";
		$is-ok = False;
	}
	return $is-ok;
}

subtest {
	my $source = Q{(3);2;1};
	my $edited = Q{();2;1};
	my $tree   = $pp.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $integer = $head.next(4);

	# Remove the current element, and do so non-recursively.
	# That is, if there are elements "under" it in the tree, they'll
	# still be attached somehow.
	#
	$integer.remove-node;

	# Check links going forward and upward.
	#
	ok check-node( $head, Raku::Document, Raku::Document, 0, 7 );
	$head = $head.next;

	ok check-node( $head, Raku::Statement, Raku::Document, 0, 4 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Operator::Circumfix, Raku::Statement, 0, 3 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Balanced::Enter, Raku::Operator::Circumfix, 0, 1 );
	$head = $head.next;

#	ok $head ~~ Raku::Number::Decimal;
#	is $head.from, 2;
#	$head = $head.next;

	ok check-node( $head,
		Raku::Balanced::Exit, Raku::Operator::Circumfix, 1, 2 );
	$head = $head.next;

	ok check-node( $head, Raku::Semicolon, Raku::Statement, 2, 3 );
	$head = $head.next;

	ok check-node( $head, Raku::Statement, Raku::Document, 3, 5 );
	$head = $head.next;

	ok check-node( $head, Raku::Number::Decimal, Raku::Statement, 3, 4 );
	$head = $head.next;

	ok check-node( $head, Raku::Semicolon, Raku::Statement, 4, 5 );
	$head = $head.next;

	ok check-node( $head, Raku::Statement, Raku::Document, 5, 6 );
	$head = $head.next;

	ok check-node( $head, Raku::Number::Decimal, Raku::Statement, 6, 7 );
	$head = $head.next;

	ok check-node( $head, Raku::Number::Decimal, Raku::Statement, 6, 7 );
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Number;              $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.previous;
#	ok $head ~~ Raku::String::Body;        $head = $head.previous;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Remove internal node};

subtest {
	my $source = Q{(3);2;1};
	my $edited = Q{(42);2;1};
	my $tree   = $pp.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $integer = $head.next(4);

	$integer.replace-node-with(
		Raku::Number::Decimal.new(
			:from( 1 ),
			:to( 2 ),
			:content( '42' )
		)
	);

	# Check links going forward and upward.
	#
	ok check-node( $head, Raku::Document, Raku::Document, 0, 7 );
	$head = $head.next;

	ok check-node( $head, Raku::Statement, Raku::Document, 0, 4 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Operator::Circumfix, Raku::Statement, 0, 3 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Balanced::Enter, Raku::Operator::Circumfix, 0, 1 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Number::Decimal, Raku::Operator::Circumfix, 1, 2 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Balanced::Exit, Raku::Operator::Circumfix, 2, 3 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Semicolon, Raku::Statement, 3, 4 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Statement, Raku::Document, 4, 6 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Number::Decimal, Raku::Statement, 4, 5 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Semicolon, Raku::Statement, 5, 6 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Statement, Raku::Document, 6, 7 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Number::Decimal, Raku::Statement, 6, 7 );
	$head = $head.next;

	ok check-node( $head,
		Raku::Number::Decimal, Raku::Statement, 6, 7 );
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Number;              $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Replace internal node};

subtest {
	my $source = Q{(3);2;1};
	my $edited = Q{(3);2;};
	my $tree   = $pp.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $one     = $head;
	$one = $one.next while !$one.is-end;

	# Remove the current element, and do so non-recursively.
	# That is, if there are elements "under" it in the tree, they'll
	# still be attached somehow.
	#
	$one.remove-node;

	ok $head ~~ Raku::Document;            $head = $head.next;
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.next;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.next;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.next;
	ok $head ~~ Raku::Semicolon;           $head = $head.next;
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head ~~ Raku::Semicolon;           $head = $head.next;
	ok $head ~~ Raku::Statement;           $head = $head.next;
#	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.is-end;

#	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Document;            $head = $head.previous;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Remove final node};

subtest {
	my $source = Q{();2;1};
	my $edited = Q{(3);2;1};
	my $tree   = $pp.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me     = $head;
	my $start-paren = $head.next(3);

	# insert '3' into the parenthesized list.
	#
	$start-paren.insert-node-after(
		Raku::Number::Decimal.new(
			:from( 0 ),
			:to( 0 ),
			:content( '3' )
		)
	);

	# Check links going forward and upward.
	#
	ok $head ~~ Raku::Document;            $head = $head.next;
	ok $head.parent ~~ Raku::Document;    
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head.parent ~~ Raku::Statement;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.next;
	ok $head.parent ~~ Raku::Operator::Circumfix;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.next;
	ok $head.parent ~~ Raku::Operator::Circumfix;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Raku::Operator::Circumfix;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.next;
	ok $head.parent ~~ Raku::Statement;
	ok $head ~~ Raku::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Raku::Document;    
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head.parent ~~ Raku::Statement;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Raku::Statement;   
	ok $head ~~ Raku::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Raku::Document;     
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head.parent ~~ Raku::Statement;   
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Number;              $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Insert internal node after '('};

subtest {
	my $source = Q{();2;1};
	my $edited = Q{(3);2;1};
	my $tree   = $pp.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $start-paren = $head.next(4);

	# insert '3' into the parenthesized list.
	#
	$start-paren.insert-node-before(
		Raku::Number::Decimal.new(
			:from( 0 ),
			:to( 0 ),
			:content( '3' )
		)
	);

	# Check links going forward and upward.
	#
	ok $head ~~ Raku::Document;            $head = $head.next;
	ok $head.parent ~~ Raku::Document;    
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head.parent ~~ Raku::Statement;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.next;
	ok $head.parent ~~ Raku::Operator::Circumfix;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.next;
	ok $head.parent ~~ Raku::Operator::Circumfix;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Raku::Operator::Circumfix;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.next;
	ok $head.parent ~~ Raku::Statement;
	ok $head ~~ Raku::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Raku::Document;    
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head.parent ~~ Raku::Statement;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Raku::Statement;   
	ok $head ~~ Raku::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Raku::Document;     
	ok $head ~~ Raku::Statement;           $head = $head.next;
	ok $head.parent ~~ Raku::Statement;   
	ok $head ~~ Raku::Number::Decimal;     $head = $head.next;
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Number;              $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Semicolon;           $head = $head.previous;
	ok $head ~~ Raku::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Raku::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Raku::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Raku::Operator::Circumfix; $head = $head.previous;
	ok $head ~~ Raku::Statement;           $head = $head.previous;
	ok $head ~~ Raku::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Insert internal node before ')'};

subtest {
	my $source   = Q{();2;1;};
	my $edited   = Q{();42;1;};
	my @token    = $pp.to-list( $source );
	my $iterated = '';

	my $replacement =
		Raku::Number::Decimal.new( :from(0), :to(0), :content('42') );

	@token.splice( 7, 1, $replacement );

	for grep { .textual }, @token {
		$iterated ~= $_.content;
	}
	is $iterated, $edited, Q{splice into array works};

	done-testing;
}, Q{edit list};

# vim: ft=raku
