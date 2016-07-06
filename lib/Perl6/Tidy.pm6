class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	role Node {
		has $.name;
		has $.child;
	}

	method debug( Str $name, Mu $parsed ) {
		my @types;

		return unless $.debugging;

		if $parsed.list {
			@types.push( 'list' )
		}
		elsif $parsed.hash {
			@types.push( 'hash' )
		}
		@types.push( 'Int'  ) if $parsed.Int;
		@types.push( 'Str'  ) if $parsed.Str;
		@types.push( 'Bool' ) if $parsed.Bool;

		die "$name: Unknown type" unless @types;

		say "$name ({@types})";

		if $parsed.list {
			for $parsed.list {
				say "$name\[\]:\n" ~ $_.dump
			}
			return;
		}
		elsif $parsed.hash() {
			say "$name\{\} keys: " ~ $parsed.hash.keys;
			say "$name\{\}:\n" ~   $parsed.dump;
		}
		say "\+$name: "    ~   $parsed.Int       if $parsed.Int;
		say "\~$name: '"   ~   $parsed.Str ~ "'" if $parsed.Str;
		say "\?$name: "    ~ ~?$parsed.Bool      if $parsed.Bool;

		say "";
	}

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	sub assert-Int( Mu $parsed ) {
		die "hash" if $parsed.hash;
		die "list" if $parsed.list;

		if $parsed.Int {
			return True
		}
		die "Uncaught type"
	}

	# $parsed can only be Str, by extension Bool
	#
	sub assert-Str( Mu $parsed ) {
		die "hash" if $parsed.hash;
		die "list" if $parsed.list;
		die "Int"  if $parsed.Int;

		if $parsed.Str {
			return True
		}
		die "Uncaught type"
	}

	# $parsed can only be Bool
	#
	sub assert-Bool( Mu $parsed ) {
		die "hash" if $parsed.hash;
		die "list" if $parsed.list;
		die "Int"  if $parsed.Int;
		die "Str"  if $parsed.Str;

		if $parsed.Bool {
			return True
		}
		die "Uncaught type"
	}

	sub assert-keys( Mu $parsed, $keys, $defined-keys = [] ) {
		if $parsed.hash {
			die "Too many keys " ~ $parsed.hash.keys.gist
				if $parsed.hash.keys.elems >
					$keys.elems + $defined-keys.elems;
			for @( $keys ) -> $key {
				return False unless $parsed.hash.{$key}
			}
			for @( $defined-keys ) -> $key {
				return False unless $parsed.hash:defined{$key}
			}
			return True
		}
		return False
	}

	class Root does Node { }

	method tidy( Str $text ) {
		my $*LINEPOSCACHE;
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $parsed = $g.parse(
			$text,
			:p( 0 ),
			:actions( $a )
		);

		self.debug( 'tidy', $parsed );

		if assert-keys( $parsed, [< statementlist >] ) {
			return Root.new(
				:content(
					:statementlist(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				)
			);
		}
		die "Uncaught type"
	}

	class StatementList does Node { }

	method statementlist( Mu $parsed ) {
		self.debug( 'statementlist', $parsed );

		if assert-keys( $parsed, [< statement >] ) {
			my @child;
			for $parsed.hash.<statement> {
				@child.push(
					self.statement(
						$_
					)
				)
			}
			return StatementList.new(
				:child( @child )
			)
		}
		if assert-keys( $parsed, [], [< statement >] ) {
			return StatementList.new
		}
		die "Uncaught type"
	}

	class Statement does Node { }

	method statement( Mu $parsed ) {
		self.debug( 'statement', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					self.EXPR(
						$_.hash.<EXPR>
					)
				)
			}
			return Statement.new(
				:child( @child )
			)
		}
		if assert-keys( $parsed, [< EXPR >] ) {
			return Statement.new(
				:content(
					:EXPR(
						self.EXPR(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< sigil desigilname >] ) {
			return Statement.new(
				:content(
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						self.desigilname(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Sym does Node { }

	method sym( Mu $parsed ) {
		self.debug( 'sym', $parsed );

		if assert-Str( $parsed ) {
			return Sym.new(
				:name( $parsed.Str )
			)
		}
	}

	class Sign does Node { }

	method sign( Mu $parsed ) {
		self.debug( 'sign', $parsed );

		if assert-Bool( $parsed ) {
			return Sign.new(
				:name( $parsed.Bool )
			)
		}
	}

	class Postfix does Node { }

	method postfix( Mu $parsed ) {
		self.debug( 'postfix', $parsed );

		if assert-keys( $parsed, [< sym O >] ) {
			return Postfix.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class OPER does Node { }

	method OPER( Mu $parsed ) {
		self.debug( 'OPER', $parsed );

		if assert-keys( $parsed, [< sym O >] ) {
			return OPER.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Name does Node { }

	method name( Mu $parsed ) {
		self.debug( 'name', $parsed );

		if assert-keys( $parsed, [< identifier morename >] ) {
			my @child;
			for $parsed.hash.<morename> {
				@child.push(
					$_
				)
			}
			return Name.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					),
				),
				:child( @child )
			)
		}
		if assert-keys( $parsed, [< identifier >],
					 [< morename >] ) {
			return Name.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Longname does Node { }

	method longname( Mu $parsed ) {
		self.debug( 'longname', $parsed );

		if assert-keys( $parsed, [< name >], [< colonpair >] ) {
			return Longname.new(
				:content(
					:name(
						self.name(
							$parsed.hash.<name>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Twigil does Node { }

	method twigil( Mu $parsed ) {
		self.debug( 'twigil', $parsed );

		if assert-keys( $parsed, [< sym >] ) {
			return Twigil.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Sigil does Node { }

	method sigil( Mu $parsed ) {
		self.debug( 'sigil', $parsed );

		if assert-Str( $parsed ) {
			return Sigil.new(
				:name( $parsed.Str )
			)
		}
	}

	class DeSigilName does Node { }

	method desigilname( Mu $parsed ) {
		self.debug( 'desigilname', $parsed );

		if assert-keys( $parsed, [< longname >] ) {
			return DeSigilName.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return DeSigilName.new(
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	class Variable does Node { }

	method variable( Mu $parsed ) {
		self.debug( 'variable', $parsed );

		if assert-keys( $parsed,
			[< twigil sigil desigilname >] ) {
			return Variable.new(
				:content(
					:twigil(
						self.twigil(
							$parsed.hash.<twigil>
						)
					),
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						self.desigilname(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		elsif assert-keys( $parsed, [< sigil desigilname >] ) {
			return Variable.new(
				:content(
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						self.desigilname(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		elsif assert-keys( $parsed, [< sigil >] ) {
			return Variable.new(
				:content(
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class RoutineDeclarator does Node { }

	method routine_declarator( Mu $parsed ) {
		self.debug( 'routine_declarator', $parsed );

		if assert-keys( $parsed, [< sym routine_def >] ) {
			return RoutineDeclarator.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:routine_def(
						self.routine_def(
							$parsed.hash.<routine_def>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class PackageDeclarator does Node { }

	method package_declarator( Mu $parsed ) {
		self.debug( 'package_declarator', $parsed );

		if assert-keys( $parsed, [< sym package_def >] ) {
			return PackageDeclarator.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:package_def(
						self.package_def(
							$parsed.hash.<package_def>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class RegexDeclarator does Node { }

	method regex_declarator( Mu $parsed ) {
		self.debug( 'regex_declarator', $parsed );

		if assert-keys( $parsed, [< sym regex_def >] ) {
			return RegexDeclarator.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:regex_def(
						self.regex_def(
							$parsed.hash.<regex_def>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class RoutineDef does Node { }

	method routine_def( Mu $parsed ) {
		self.debug( 'routine_def', $parsed );

		if assert-keys( $parsed,
				[< blockoid deflongname >],
				[< trait >] ) {
			return RoutineDef.new(
				:content(
					:blockoid(
						self.blockoid(
							$parsed.hash.<blockoid>
						)
					),
					:deflongname(
						self.deflongname(
							$parsed.hash.<deflongname>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class PackageDef does Node { }

	method package_def( Mu $parsed ) {
		self.debug( 'package_def', $parsed );

		if assert-keys( $parsed,
				[< blockoid longname >], [< trait >] ) {
			return PackageDef.new(
				:content(
					:blockoid(
						self.blockoid(
							$parsed.hash.<blockoid>
						)
					),
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if assert-keys( $parsed,
				[< longname statementlist >],
				[< trait >] ) {
			return PackageDef.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					),
					:statementlist(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class RegexDef does Node { }

	method regex_def( Mu $parsed ) {
		self.debug( 'regex_def', $parsed );

		if assert-keys( $parsed,
				[< deflongname nibble >],
				[< signature trait >] ) {
			return RegexDef.new(
				:content(
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					),
					:deflongname(
						self.deflongname(
							$parsed.hash.<deflongname>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Blockoid does Node { }

	method blockoid( Mu $parsed ) {
		self.debug( 'blockoid', $parsed );

		if assert-keys( $parsed, [< statementlist >] ) {
			return Blockoid.new(
				:content(
					:statementlist(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class DefLongName does Node { }

	method deflongname( Mu $parsed ) {
		self.debug( 'deflongname', $parsed );

		if assert-keys( $parsed,
				[< name >],
				[< colonpair >] ) {
			return DefLongName.new(
				:content(
					:name(
						self.name(
							$parsed.hash.<name>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class EXPR does Node { }

	method EXPR( Mu $parsed ) {
		self.debug( 'EXPR', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				if $_.hash.<value> {
					@child.push(
						self.value(
							$_.hash.<value>
						)
					);
					next;
				}
				die "Uncaught key"
			}
			if $parsed.hash {
				if assert-keys( $parsed,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] ) {
					return EXPR.new(
						:content(
							:postfix(
								self.postfix(
									$parsed.hash.<postfix>
								)
							),
							:OPER(
								self.OPER(
									$parsed.hash.<OPER>
								)
							)
						),
						:child( @child )
					)
				}
				die "Uncaught key"
			}
			else {
				return EXPR.new(
					:child( @child )
				)
			}
		}
		if assert-keys( $parsed, [< longname args >] ) {
			return EXPR.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< value >] ) {
			return EXPR.new(
				:content(
					:value(
						self.value(
							$parsed.hash.<value>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< variable >] ) {
			return EXPR.new(
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< longname >] ) {
			return EXPR.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< circumfix >] ) {
			return EXPR.new(
				:content(
					:circumfix(
						self.circumfix(
							$parsed.hash.<circumfix>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< colonpair >] ) {
			return EXPR.new(
				:content(
					:colonpair(
						self.colonpair(
							$parsed.hash.<colonpair>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< scope_declarator >] ) {
			return EXPR.new(
				:content(
					:scope_declarator(
						self.scope_declarator(
							$parsed.hash.<scope_declarator>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< routine_declarator >] ) {
			return EXPR.new(
				:content(
					:routine_declarator(
						self.routine_declarator(
							$parsed.hash.<routine_declarator>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< package_declarator >] ) {
			return EXPR.new(
				:content(
					:package_declarator(
						self.package_declarator(
							$parsed.hash.<package_declarator>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< regex_declarator >] ) {
			return EXPR.new(
				:content(
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class VariableDeclarator does Node { }

	method variable_declarator( Mu $parsed ) {
		self.debug( 'variable_declarator', $parsed );

		if assert-keys( $parsed,
				[< variable post_constraint >],
				[< semilist postcircumfix signature trait >] ) {
			my @child;
			for $parsed.hash.<post_constraint> {
				@child.push(
					self.EXPR(
						$_.hash.<EXPR>
					)
				)
			}
			return VariableDeclarator.new(
				:child( @child )
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		if assert-keys( $parsed,
				[< variable >],
				[< semilist postcircumfix signature trait post_constraint >] ) {
			return VariableDeclarator.new(
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class MultiDeclarator does Node { }

	method multi_declarator( Mu $parsed ) {
		self.debug( 'multi_declarator', $parsed );

		if assert-keys( $parsed, [< declarator >] ) {
			return MultiDeclarator.new(
				:content(
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Declarator does Node { }

	method declarator( Mu $parsed ) {
		self.debug( 'declarator', $parsed );

		if assert-keys( $parsed,
				[< variable_declarator >],
				[< trait >] ) {
			return Declarator.new(
				:content(
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					)
				)
			)
		}
		if assert-keys( $parsed,
				[< regex_declarator >],
				[< trait >] ) {
			return Declarator.new(
				:content(
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class DECL does Node { }

	method DECL( Mu $parsed ) {
		self.debug( 'DECL', $parsed );

		if assert-keys( $parsed,
				[< variable_declarator >],
				[< trait >] ) {
			return DECL.new(
				:content(
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					)
				)
			)
		}
		if assert-keys( $parsed,
				[< regex_declarator >],
				[< trait >] ) {
			return DECL.new(
				:content(
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			)
		}
		elsif assert-keys( $parsed, [< package_def sym >] ) {
			return DECL.new(
				:content(
					:package_def(
						self.package_def(
							$parsed.hash.<package_def>
						)
					),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		elsif assert-keys( $parsed, [< declarator >] ) {
			return DECL.new(
				:content(
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class TypeName does Node { }

	method typename( Mu $parsed ) {
		self.debug( 'typename', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					self.longname(
						$_.hash.<longname>
					)
				)
			}
			return TypeName.new(
				:child( @child )
			)
		}
		if assert-keys( $parsed, [< longname >] ) {
			return TypeName.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Scoped is Node { }

	method scoped( Mu $parsed ) {
		self.debug( 'scoped', $parsed );

		if assert-keys( $parsed,
				[< declarator DECL >],
				[< typename >] ) {
			return Scoped.new(
				:content(
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					),
					:DECL(
						self.DECL(
							$parsed.hash.<DECL>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< multi_declarator
					    DECL
					    typename >] ) {
			return Scoped.new(
				:content(
					:multi_declarator(
						self.multi_declarator(
							$parsed.hash.<multi_declarator>
						)
					),
					:DECL(
						self.DECL(
							$parsed.hash.<DECL>
						)
					),
					:typename(
						self.typename(
							$parsed.hash.<typename>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< package_declarator DECL >],
					 [< typename >] ) {
			return Scoped.new(
				:content(
					:package_declarator(
						self.package_declarator(
							$parsed.hash.<package_declarator>
						)
					),
					:DECL(
						self.DECL(
							$parsed.hash.<DECL>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class ScopeDeclarator does Node { }

	method scope_declarator( Mu $parsed ) {
		self.debug( 'scope_declarator', $parsed );

		if assert-keys( $parsed, [< sym scoped >] ) {
			return ScopeDeclarator.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:scoped(
						self.scoped(
							$parsed.hash.<scoped>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Value does Node { }

	method value( Mu $parsed ) {
		self.debug( 'value', $parsed );

		if assert-keys( $parsed, [< number >] ) {
			return Value.new(
				:content(
					:number(
						self.number(
							$parsed.hash.<number>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< quote >] ) {
			return Value.new(
				:content(
					:quote(
						self.quote(
							$parsed.hash.<quote>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Number does Node { }

	method number( Mu $parsed ) {
		self.debug( 'number', $parsed );

		if assert-keys( $parsed, [< numish >] ) {
			return Number.new(
				:content(
					:numish(
						self.numish(
							$parsed.hash.<numish>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Quote does Node { }

	method quote( Mu $parsed ) {
		self.debug( 'quote', $parsed );

		if assert-keys( $parsed, [< nibble >] ) {
			return Quote.new(
				:content(
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< quibble >] ) {
			return Quote.new(
				:content(
					:quibble(
						self.quibble(
							$parsed.hash.<quibble>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class B does Node { }

	method B( Mu $parsed ) {
		self.debug( 'B', $parsed );

		if assert-Bool( $parsed ) {
			return B.new(
				:name( $parsed.Bool )
			)
		}
	}

	class Babble does Node { }

	method babble( Mu $parsed ) {
		self.debug( 'babble', $parsed );

		if assert-keys( $parsed,
				[< B >],
				[< quotepair >] ) {
			return Babble.new(
				:content(
					:B(
						self.B(
							$parsed.hash.<B>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Signature does Node { }

	method signature( Mu $parsed ) {
		self.debug( 'signature', $parsed );

		if assert-keys( $parsed,
				[],
				[< param_sep parameter >] ) {
			return Signature.new(
				:name( $parsed.Bool )
			)
		}
		die "Uncaught type"
	}

	class FakeSignature does Node { }

	method fakesignature( Mu $parsed ) {
		self.debug( 'fakesignature', $parsed );

		if assert-keys( $parsed, [< signature >] ) {
			return FakeSignature.new(
				:content(
					:signature(
						self.signature(
							$parsed.hash.<signature>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class ColonPair does Node { }

	method colonpair( Mu $parsed ) {
		self.debug( 'colonpair', $parsed );

		if assert-keys( $parsed, [< identifier >] ) {
			return ColonPair.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< fakesignature >] ) {
			return ColonPair.new(
				:content(
					:fakesignature(
						self.fakesignature(
							$parsed.hash.<fakesignature>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Identifier does Node { }

	method identifier( Mu $parsed ) {
		self.debug( 'identifier', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					$_.Str
				)
			}
			return Identifier.new(
				:child( @child )
			)
		}
		elsif $parsed.Str {
			return Identifier.new(
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	class QuotePair does Node { }

	method quotepair( Mu $parsed ) {
		self.debug( 'quotepair', $parsed );

		if assert-keys( $parsed, [< identifier >] ) {
			return QuotePair.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Quibble does Node { }

	method quibble( Mu $parsed ) {
		self.debug( 'quibble', $parsed );

		if assert-keys( $parsed, [< babble nibble >] ) {
			return Quibble.new(
				:content(
					:babble(
						self.babble(
							$parsed.hash.<babble>
						)
					),
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class _0 does Node { }

	method _0( Mu $parsed ) {
		self.debug( '0', $parsed );

		if assert-keys( $parsed, [< 0 >] ) {
			return _0.new(
				:content(
					:babble(
						self.babble(
							$parsed.hash.<babble>
						)
					),
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class CharSpec does Node { }

	method charspec( Mu $parsed ) {
		self.debug( 'charspec', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					$_.hash.<0>
				)
			}
			return CharSpec.new(
				:child( @child )
			)
		}
		die "Uncaught type"
	}

	class CClassElemIntermediary does Node { }

	class CClassElem does Node { }

	method cclass_elem( Mu $parsed ) {
		self.debug( 'cclass_elem', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					CClassElemIntermediary.new(
						:content(
							:sign(
								self.sign(
									$_.hash.<sign>
								)
							),
							:charspec(
								self.charspec(
									$_.hash.<charspec>
								)
							)
						)
					)
				)
			}
			return CClassElem.new(
				:child( @child )
			)
		}
		die "Uncaught type"
	}

	class Assertion does Node { }

	method assertion( Mu $parsed ) {
		self.debug( 'metachar', $parsed );

		if assert-keys( $parsed, [< cclass_elem >] ) {
			return Assertion.new(
				:content(
					:cclass_elem(
						self.cclass_elem(
							$parsed.hash.<cclass_elem>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class MetaChar does Node { }

	method metachar( Mu $parsed ) {
		self.debug( 'metachar', $parsed );

		if assert-keys( $parsed, [< assertion >] ) {
			return MetaChar.new(
				:content(
					:metachar(
						self.assertion(
							$parsed.hash.<assertion>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Atom does Node { }

	method atom( Mu $parsed ) {
		self.debug( 'noun', $parsed );

		if assert-keys( $parsed, [< metachar >] ) {
			return Atom.new(
				:content(
					:atom(
						self.metachar(
							$parsed.hash.<metachar>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return Atom.new(
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	class Noun does Node { }

	method noun( Mu $parsed ) {
		self.debug( 'noun', $parsed );

		if assert-keys( $parsed, [< atom >] ) {
			return Noun.new(
				:content(
					:atom(
						self.atom(
							$parsed.hash.<atom>
						)
					)
				)
			)
		}
		if $parsed.Str {
			die "str"
		}
		die "Uncaught type"
	}

	class Termish is Node { }

	method termish( Mu $parsed ) {
		self.debug( 'termish', $parsed );

		if assert-keys( $parsed, [< noun >] ) {
			my @child;
			for $parsed.hash.<noun> {
				@child.push(
					self.noun(
						$_
					)
				)
			}
			return Termish.new(
				:child( @child )
			)
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class TermConj does Node { }

	method termconj( Mu $parsed ) {
		self.debug( 'termconj', $parsed );

		if assert-keys( $parsed, [< termish >] ) {
			my @child;
			for $parsed.hash.<termish> {
				@child.push(
					self.termish(
						$_
					)
				)
			}
			return TermConj.new(
				:type( 'termconj' ),
				:child( @child )
			)
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class TermAlt does Node { }

	method termalt( Mu $parsed ) {
		self.debug( 'termalt', $parsed );

		if assert-keys( $parsed, [< termconj >] ) {
			my @child;
			for $parsed.hash.<termconj> {
				@child.push(
					self.termconj(
						$_
					)
				)
			}
			return TermAlt.new(
				:child( @child )
			)
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class TermConjSeq does Node { }

	method termconjseq( Mu $parsed ) {
		self.debug( 'termconjseq', $parsed );

		if assert-keys( $parsed, [< termalt >] ) {
			my @child;
			for $parsed.hash.<termalt> {
				@child.push(
					self.termalt(
						$_
					)
				)
			}
			return TermConjSeq.new(
				:child( @child )
			)
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class TermAltSeq does Node { }

	method termaltseq( Mu $parsed ) {
		self.debug( 'termaltseq', $parsed );

		if assert-keys( $parsed, [< termconjseq >] ) {
			my @child;
			for $parsed.hash.<termconjseq> {
				@child.push(
					self.termconjseq(
						$_
					)
				)
			}
			return TermAltSeq.new(
				:child( @child )
			)
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class TermSeq does Node { }

	method termseq( Mu $parsed ) {
		self.debug( 'termseq', $parsed );

		if assert-keys( $parsed, [< termaltseq >] ) {
			return TermSeq.new(
				:content(
					:termaltseq(
						self.termaltseq(
							$parsed.hash.<termaltseq>
						)
					)
				)
			)
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class Nibble does Node { }

	method nibble( Mu $parsed ) {
		self.debug( 'nibble', $parsed );

		if assert-keys( $parsed, [< termseq >] ) {
			return Nibble.new(
				:content(
					:termseq(
						self.termseq(
							$parsed.hash.<termseq>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return Nibble.new(
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	class DecNumber does Node { }

	method dec_number( Mu $parsed ) {
		self.debug( 'dec_number', $parsed );

		if assert-keys( $parsed, [< int coeff frac >] ) {
			return DecNumber.new(
				:content(
					:int(
						self.int(
							$parsed.hash.<int>
						)
					),
					:coeff(
						self.coeff(
							$parsed.hash.<coeff>
						)
					),
					:frac(
						self.frac(
							$parsed.hash.<frac>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< int coeff escale >] ) {
			return DecNumber.new(
				:content(
					:int(
						self.int(
							$parsed.hash.<int>
						)
					),
					:coeff(
						self.coeff(
							$parsed.hash.<coeff>
						)
					),
					:escale(
						self.escale(
							$parsed.hash.<escale>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Numish does Node { }

	method numish( Mu $parsed ) {
		self.debug( 'numish', $parsed );

		if assert-keys( $parsed, [< integer >] ) {
			return Numish.new(
				:content(
					:integer(
						self.integer(
							$parsed.hash.<integer>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< rad_number >] ) {
			return Numish.new(
				:type( 'numish' ),
				:content(
					:rad_number(
						self.rad_number(
							$parsed.hash.<rad_number>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< dec_number >] ) {
			return Numish.new(
				:type( 'numish' ),
				:content(
					:dec_number(
						self.dec_number(
							$parsed.hash.<dec_number>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Integer does Node { }

	method integer( Mu $parsed ) {
		self.debug( 'integer', $parsed );

		if assert-keys( $parsed, [< decint VALUE >] ) {
			return Integer.new(
				:content(
					:decint(
						self.decint(
							$parsed.hash.<decint>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< binint VALUE >] ) {
			return Integer.new(
				:content(
					:binint(
						self.binint(
							$parsed.hash.<binint>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< octint VALUE >] ) {
			return Integer.new(
				:content(
					:octint(
						self.octint(
							$parsed.hash.<octint>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< hexint VALUE >] ) {
			return Integer.new(
				:content(
					:hexint(
						self.hexint(
							$parsed.hash.<hexint>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class Circumfix does Node { }

	method circumfix( Mu $parsed ) {
		self.debug( 'circumfix', $parsed );

		if assert-keys( $parsed, [< semilist >] ) {
			return Circumfix.new(
				:content(
					:semilist(
						self.semilist(
							$parsed.hash.<semilist>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< binint VALUE >] ) {
			return Circumfix.new(
				:content(
					:binint(
						self.binint(
							$parsed.hash.<binint>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< octint VALUE >] ) {
			return Circumfix.new(
				:content(
					:octint(
						self.octint(
							$parsed.hash.<octint>
						)
					)
				)
			)
		}
		if assert-keys( $parsed, [< hexint VALUE >] ) {
			return Circumfix.new(
				:content(
					:hexint(
						self.hexint(
							$parsed.hash.<hexint>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class SemiList does Node { }

	method semilist( Mu $parsed ) {
		self.debug( 'semilist', $parsed );

		if assert-keys( $parsed, [< statement >] ) {
			my @child;
			for $parsed.hash.<statement> {
				@child.push(
					self.statement(
						$_
					)
				)
			}
			return SemiList.new(
				:type( 'semilist' ),
				:child( @child )
			)
		}
		if assert-keys( $parsed, [], [< statement >] ) {
			return SemiList.new
		}
		die "Uncaught type"
	}

	class RadNumber does Node { }

	method rad_number( Mu $parsed ) {
		self.debug( 'rad_number', $parsed );

		if assert-keys( $parsed,
				[< circumfix radix >],
				[< exp base >] ) {
			return RadNumber.new(
				:content(
					:circumfix(
						self.circumfix(
							$parsed.hash.<circumfix>,
						)
					),
					:radix(
						self.radix(
							$parsed.hash.<radix>,
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class _Int does Node { }

	method int( Mu $parsed ) {
		self.debug( 'int', $parsed );

		if assert-Int( $parsed ) {
			return _Int.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class Radix does Node { }

	method radix( Mu $parsed ) {
		self.debug( 'radix', $parsed );

		if assert-Int( $parsed ) {
			return Radix.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class Frac does Node { }

	method frac( Mu $parsed ) {
		self.debug( 'frac', $parsed );

		if assert-Int( $parsed ) {
			return Frac.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class Coeff does Node { }

	method coeff( Mu $parsed ) {
		self.debug( 'coeff', $parsed );

		if assert-Int( $parsed ) {
			return Coeff.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class EScale does Node { }

	method escale( Mu $parsed ) {
		self.debug( 'escale', $parsed );

		if assert-keys( $parsed, [< sign decint >] ) {
			return EScale.new(
				:content(
					:sign(
						self.sign(
							$parsed.hash.<sign>
						)
					),
					:decint(
						self.decint(
							$parsed.hash.<decint>
						)
					)
				)
			)
		}
		die "Uncaught type"
	}

	class BinInt does Node { }

	method binint( Mu $parsed ) {
		self.debug( 'binint', $parsed );

		if assert-Int( $parsed ) {
			return BinInt.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class OctInt does Node { }

	method octint( Mu $parsed ) {
		self.debug( 'octint', $parsed );

		if assert-Int( $parsed ) {
			return OctInt.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class DecInt does Node { }

	method decint( Mu $parsed ) {
		self.debug( 'decint', $parsed );

		if assert-Int( $parsed ) {
			return DecInt.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	class HexInt does Node { }

	method hexint( Mu $parsed ) {
		self.debug( 'hexint', $parsed );

		if assert-Int( $parsed ) {
			return HexInt.new(
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}
}
