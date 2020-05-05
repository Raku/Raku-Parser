use v6;

use Test;
use Raku::Parser;

use lib 't/lib';
use Utils;

plan 1;

# I've tried to arrange this so one token comes per line.
# Makes it easier to comment out one term at a time.
#
# Or, another way of thinking about it is that commenting out each line
# (excepting those that span multiples) should break a test.
#
# '3.27e5' blows past parser
my $tree = Raku::Parser.new.to-tree( Q:to[_END_] );
=begin pod

=end pod

1;
0b1;
0o2;
0d3;
0x4;
# Comment - make sure it's not contiguous with a Pod block
:r3<12>;
-0.1;
my $a;
my %a;
my @a;
my &a;
my $*a;
my %*a;
my @*a;
my &*a;
my $=pod;
my %=pod;
my @=pod;
my &=pod;
class Foo {
my $.a;
my %.b;
my @.c;
my &.d;
has $!e;
has %!f;
has @!g;
has &!h;
}
'foo';
"foo";
q{foo};
qq{foo};
qw{foo};
qww{foo};
qqw{foo};
qqx{foo};
qqww{foo};
<foo>;
qx{foo};
qqx{foo};
Q{foo};
Qw{foo};
Qx{foo};
｢foo｣;
q:to[END];
END
Q:to[END];
END

sub foo { };

{ 
say [+] @a;
say ++$a + $a++;
say @a[1];
$a ~~ m{ . };
$a = Inf;
$a = NaN;
};
open 'foo', :r;
_END_

subtest {
  ok Raku::Element ~~ Mu, Q{has correct parent};
  ok has-a( $tree, Raku::Element ), Q{found};
  
  subtest {
    ok Raku::Visible ~~ Raku::Element, Q{has correct parent};
    ok has-a( $tree, Raku::Visible ), Q{found};
    
    subtest {
      ok Raku::Operator ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Operator ), Q{found};
      
      subtest {
        ok Raku::Operator::Hyper ~~ Raku::Operator, Q{has correct parent};
        ok has-a( $tree, Raku::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Hyper};
      
      subtest {
        ok Raku::Operator::Prefix ~~ Raku::Operator, Q{has correct parent};
        ok has-a( $tree, Raku::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Prefix};
      
      subtest {
        ok Raku::Operator::Infix ~~ Raku::Operator, Q{has correct parent};
        ok has-a( $tree, Raku::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Infix};
      
      subtest {
        ok Raku::Operator::Postfix ~~ Raku::Operator, Q{has correct parent};
        ok has-a( $tree, Raku::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Postfix};
      
      subtest {
        ok Raku::Operator::Circumfix ~~ Raku::Operator,
           Q{has correct parent};
        ok has-a( $tree, Raku::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Circumfix};
      
      subtest {
        ok Raku::Operator::PostCircumfix ~~ Raku::Operator,
           Q{has correct parent};
        ok has-a( $tree, Raku::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::PostCircumfix};
      
      done-testing;
    }, Q{Operator};
    
    subtest {
      ok Raku::String ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::String ), Q{found};
      
      subtest {
        ok Raku::String::Body ~~ Raku::String, Q{has correct parent};
        ok has-a( $tree, Raku::String::Body ), Q{found};
        
        done-testing;
      }, Q{String::Body};
      
      subtest {
        ok Raku::String::WordQuoting ~~ Raku::String, Q{has correct parent};
        ok has-a( $tree, Raku::String::WordQuoting ), Q{found};
        
        subtest {
          ok Raku::String::WordQuoting::QuoteProtection ~~
             Raku::String::WordQuoting, Q{has correct parent};
          ok has-a( $tree, Raku::String::WordQuoting::QuoteProtection ),
             Q{found};
          
          done-testing;
        }, Q{String::WordQuoting::QuoteProtection};
        
        done-testing;
      }, Q{String::WordQuoting};
      
      subtest {
        ok Raku::String::Interpolation ~~ Raku::String,
           Q{has correct parent};
        ok has-a( $tree, Raku::String::Interpolation ), Q{found};
        
        subtest {
          ok Raku::String::Interpolation::Shell ~~
             Raku::String::Interpolation,
             Q{has correct parent};
          ok has-a( $tree, Raku::String::Interpolation::Shell ), Q{found};
          
          done-testing;
        }, Q{String::Interpolation::Shell};
        
        subtest {
          ok Raku::String::Interpolation::WordQuoting ~~
             Raku::String::Interpolation, Q{has correct parent};
          ok has-a( $tree, Raku::String::Interpolation::WordQuoting ),
             Q{found};
          
          subtest {
            ok Raku::String::Interpolation::WordQuoting::QuoteProtection ~~
               Raku::String::Interpolation::WordQuoting,
               Q{has correct parent};
            ok has-a(
                 $tree,
                 Raku::String::Interpolation::WordQuoting::QuoteProtection
               ), Q{found};
            
            done-testing;
          }, Q{String::Interpolation::WordQuoting::QuoteProtection};
          
          done-testing;
        }, Q{String::Interpolation::WordQuoting};
        
        done-testing;
      }, Q{String::Interpolation};
      
      subtest {
        ok Raku::String::Shell ~~ Raku::String, Q{has correct parent};
        ok has-a( $tree, Raku::String::Shell ), Q{found};
        
        done-testing;
      }, Q{String::Shell};
      
      subtest {
        ok Raku::String::Escaping ~~ Raku::String, Q{has correct parent};
        ok has-a( $tree, Raku::String::Escaping ), Q{found};
        
        done-testing;
      }, Q{String::Escaping};
      
      subtest {
        ok Raku::String::Literal ~~ Raku::String, Q{has correct parent};
        ok has-a( $tree, Raku::String::Literal ), Q{found};
        
        subtest {
          ok Raku::String::Literal::WordQuoting ~~ Raku::String,
             Q{has correct parent};
          ok has-a( $tree, Raku::String::Literal::WordQuoting ), Q{found};
          
          done-testing;
        }, Q{String::Literal::WordQuoting};
        
        subtest {
          ok Raku::String::Literal::Shell ~~ Raku::String,
             Q{has correct parent};
          ok has-a( $tree, Raku::String::Literal::Shell ), Q{found};
          
          done-testing;
        }, Q{String::Literal::Shell};
        
        done-testing;
      }, Q{String::Literal};
      
      done-testing;
    }, Q{String};
    
    subtest {
      ok Raku::Documentation ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Documentation ), Q{found};
      
      subtest {
        ok Raku::Pod ~~ Raku::Documentation, Q{has correct parent};
        ok has-a( $tree, Raku::Pod ), Q{found};
        
        done-testing;
      }, Q{Pod};
      
      subtest {
        ok Raku::Comment ~~ Raku::Documentation, Q{has correct parent};
        ok has-a( $tree, Raku::Comment ), Q{found};
        
        done-testing;
      }, Q{Comment};
      
      done-testing;
    }, Q{Documentation};
    
    subtest {
      ok Raku::Balanced ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Balanced ), Q{found};
      
      subtest {
        ok Raku::Balanced::Enter ~~ Raku::Balanced, Q{has correct parent};
        ok has-a( $tree, Raku::Balanced::Enter ), Q{found};
        
        subtest {
          ok Raku::Block::Enter ~~ Raku::Balanced::Enter,
             Q{has correct parent};
          ok has-a( $tree, Raku::Block::Enter ), Q{found};
          
          done-testing;
        }, Q{Block::Enter};
        
        subtest {
          ok Raku::String::Enter ~~ Raku::Balanced::Enter,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::String::Enter ), Q{found};
}
          
          done-testing;
        }, Q{String::Enter};
        
        done-testing;
      }, Q{Balanced::Enter};
      
      subtest {
        ok Raku::Balanced::Exit ~~ Raku::Balanced, Q{has correct parent};
        ok has-a( $tree, Raku::Balanced::Exit ), Q{found};
        
        subtest {
          ok Raku::Block::Exit ~~ Raku::Balanced::Exit, Q{has correct parent};
          ok has-a( $tree, Raku::Block::Exit ), Q{found};
          
          done-testing;
        }, Q{Block::Exit};
        
        subtest {
          ok Raku::String::Exit ~~ Raku::Balanced::Exit,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::String::Exit ), Q{found};
}
          
          done-testing;
        }, Q{String::Exit};
        
        done-testing;
      }, Q{Balanced::Exit};
      
      done-testing;
    }, Q{Balanced};
    
    # A proper test makes sure that documents *don't* have these.
    # They shouldn't be generated when validating in tests, and
    # *really* shouldn't be generated by regular code.
    #
    subtest {
      ok Raku::Catch-All ~~ Raku::Visible, Q{has correct parent};
      ok !has-a( $tree, Raku::Catch-All ), Q{found};
      
      done-testing;
    }, Q{Catch-All};
    
    subtest {
      ok Raku::Whatever ~~ Raku::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Raku::Whatever ), Q{found};
}
      
      done-testing;
    }, Q{Whatever};
    
    subtest {
      ok Raku::Loop-Separator ~~ Raku::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Raku::Loop-Separator ), Q{found};
}
      
      done-testing;
    }, Q{Loop-Separator};
    
    subtest {
      ok Raku::Dimension-Separator ~~ Raku::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Raku::Dimension-Separator ), Q{found};
}
      
      done-testing;
    }, Q{Dimension-Separator};
    
    subtest {
      ok Raku::Semicolon ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Semicolon ), Q{found};
      
      done-testing;
    }, Q{Semicolon};
    
    subtest {
      ok Raku::Backslash ~~ Raku::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Raku::Backslash ), Q{found};
}
      
      done-testing;
    }, Q{Backslash};
    
    # XXX is this a bug?... Not really, RTFS to see why.
    subtest {
      ok Raku::Sir-Not-Appearing-In-This-Statement ~~ Raku::Visible,
         Q{has correct parent};
      ok has-a( $tree, Raku::Sir-Not-Appearing-In-This-Statement ), Q{found};
      
      done-testing;
    }, Q{Sir-Not-Appearing-In-This-Statement};
    
    subtest {
      ok Raku::Number ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Number ), Q{found};
      
      subtest {
        ok Raku::Number::Binary ~~ Raku::Number, Q{has correct parent};
        ok has-a( $tree, Raku::Number::Binary ), Q{found};
        
        done-testing;
      }, Q{Number::Binary};
      
      subtest {
        ok Raku::Number::Octal ~~ Raku::Number, Q{has correct parent};
        ok has-a( $tree, Raku::Number::Octal ), Q{found};
        
        done-testing;
      }, Q{Number::Octal};
      
      subtest {
        ok Raku::Number::Decimal ~~ Raku::Number, Q{has correct parent};
        ok has-a( $tree, Raku::Number::Decimal ), Q{found};
        
        subtest {
          ok Raku::Number::Decimal::Explicit ~~ Raku::Number::Decimal,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Number::Decimal::Explicit), Q{found};
}
          
          done-testing;
        }, Q{Number::Decimal::Explicit};
        
        done-testing;
      }, Q{Number::Decimal};
      
      subtest {
        ok Raku::Number::Hexadecimal ~~ Raku::Number, Q{has correct parent};
        ok has-a( $tree, Raku::Number::Hexadecimal ), Q{found};
        
        done-testing;
      }, Q{Number::Hexadecimal};
      
      subtest {
        ok Raku::Number::Radix ~~ Raku::Number, Q{has correct parent};
#`{
        ok has-a( $tree, Raku::Number::Radix ), Q{found};
}
        
        done-testing;
      }, Q{Number::Radix};
      
      subtest {
        ok Raku::Number::FloatingPoint ~~ Raku::Number, Q{has correct parent};
        ok has-a( $tree, Raku::Number::FloatingPoint ), Q{found};
        
        done-testing;
      }, Q{Number::FloatingPoint};
      
      done-testing;
    }, Q{Number};
    
    subtest {
      ok Raku::NotANumber ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::NotANumber ), Q{found};
      
      done-testing;
    }, Q{NotANumber};
    
    subtest {
      ok Raku::Infinity ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Infinity ), Q{found};
      
      done-testing;
    }, Q{Infinity};
    
    subtest {
      ok Raku::Regex ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Regex ), Q{found};
      
      done-testing;
    }, Q{Regex};
    
    subtest {
      ok Raku::Bareword ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Bareword ), Q{found};
      
      subtest {
        ok Raku::SubroutineDeclaration ~~ Raku::Bareword,
           Q{has correct parent};
        ok has-a( $tree, Raku::SubroutineDeclaration ), Q{found};
        
        done-testing;
      }, Q{SubroutineDeclaration};
      
      subtest {
        ok Raku::ColonBareword ~~ Raku::Bareword, Q{has correct parent};
        ok has-a( $tree, Raku::ColonBareword ), Q{found};
        
        done-testing;
      }, Q{ColonBareword};
      
      done-testing;
    }, Q{Bareword};
    
    subtest {
      ok Raku::Adverb ~~ Raku::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Raku::Adverb ), Q{found};
}
    
      done-testing;
    }, Q{Adverb};
    
    subtest {
      ok Raku::PackageName ~~ Raku::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Raku::PackageName ), Q{found};
}
      
      done-testing;
    }, Q{PackageName};
    
    subtest {
      ok Raku::Variable ~~ Raku::Visible, Q{has correct parent};
      ok has-a( $tree, Raku::Variable ), Q{found};
      
      subtest {
        ok Raku::Variable::Scalar ~~ Raku::Variable, Q{has correct parent};
        ok has-a( $tree, Raku::Variable::Scalar ), Q{found};
        
        subtest {
          ok Raku::Variable::Scalar::Contextualizer ~~ Raku::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Scalar::Contextualizer ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::Contextualizer};
        
        subtest {
          ok Raku::Variable::Scalar::Dynamic ~~ Raku::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Scalar::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Dynamic};
        
        subtest {
          ok Raku::Variable::Scalar::Attribute ~~ Raku::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Scalar::Attribute ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Attribute};
        
        subtest {
          ok Raku::Variable::Scalar::Accessor ~~ Raku::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Scalar::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Accessor};
        
        subtest {
          ok Raku::Variable::Scalar::CompileTime ~~ Raku::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Scalar::CompileTime ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::CompileTime};
        
        subtest {
          ok Raku::Variable::Scalar::MatchIndex ~~ Raku::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Scalar::MatchIndex ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::MatchIndex};
        
        subtest {
          ok Raku::Variable::Scalar::Positional ~~ Raku::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Scalar::Positional ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::Positional};
        
        subtest {
          ok Raku::Variable::Scalar::Named ~~ Raku::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Scalar::Named ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Scalar::Named};
        
        subtest {
          ok Raku::Variable::Scalar::Pod ~~ Raku::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Scalar::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Pod};
        
        subtest {
          ok Raku::Variable::Scalar::SubLanguage ~~ Raku::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Scalar::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::SubLanguage};
        
        done-testing;
      }, Q{Variable::Scalar};
      
      subtest {
        ok Raku::Variable::Array ~~ Raku::Variable, Q{has correct parent};
        ok has-a( $tree, Raku::Variable::Array ), Q{found};
        
#        subtest {
#          ok Raku::Variable::Array::Contextualizer ~~ Raku::Variable::Array,
#             Q{has correct parent};
#          ok has-a( $tree, Raku::Variable::Array::Contextualizer ), Q{found};
#          
#          done-testing;
#        }, Q{Variable::Array::Contextualizer};
        
        subtest {
          ok Raku::Variable::Array::Dynamic ~~ Raku::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Array::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Dynamic};
        
        subtest {
          ok Raku::Variable::Array::Attribute ~~ Raku::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Array::Attribute ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Attribute};
        
        subtest {
          ok Raku::Variable::Array::Accessor ~~ Raku::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Array::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Accessor};
        
        subtest {
          ok Raku::Variable::Array::CompileTime ~~ Raku::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Array::CompileTime ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::CompileTime};
        
        subtest {
          ok Raku::Variable::Array::MatchIndex ~~ Raku::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Array::MatchIndex ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::MatchIndex};
        
        subtest {
          ok Raku::Variable::Array::Positional ~~ Raku::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Array::Positional ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::Positional};
        
        subtest {
          ok Raku::Variable::Array::Named ~~ Raku::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Array::Named ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Array::Named};
        
        subtest {
          ok Raku::Variable::Array::Pod ~~ Raku::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Array::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Pod};
        
        subtest {
          ok Raku::Variable::Array::SubLanguage ~~ Raku::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Array::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::SubLanguage};
        
        
        done-testing;
      }, Q{Variable::Array};
      
      subtest {
        ok Raku::Variable::Hash ~~ Raku::Variable, Q{has correct parent};
        ok has-a( $tree, Raku::Variable::Hash ), Q{found};
        
#	subtest {
#         ok Raku::Variable::Hash::Contextualizer ~~ Raku::Variable::Hash,
#            Q{has correct parent};
#         ok has-a( $tree, Raku::Variable::Hash::Contextualizer ), Q{found};
#         
#         done-testing;
#	}, Q{Variable::Hash::Contextualizer};
        
        subtest {
          ok Raku::Variable::Hash::Dynamic ~~ Raku::Variable::Hash,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Hash::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Hash::Dynamic};
        
        subtest {
          ok Raku::Variable::Hash::Attribute ~~ Raku::Variable::Hash,
             Q{has correct parent};
 	  ok has-a( $tree, Raku::Variable::Hash::Attribute ), Q{found};
        
          done-testing;
        }, Q{Variable::Hash::Attribute};
        
        subtest {
          ok Raku::Variable::Hash::Accessor ~~ Raku::Variable::Hash,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Hash::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Hash::Accessor};
        
        subtest {
          ok Raku::Variable::Hash::CompileTime ~~ Raku::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Hash::CompileTime ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Hash::CompileTime};
        
        subtest {
          ok Raku::Variable::Hash::MatchIndex ~~ Raku::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Hash::MatchIndex ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Hash::MatchIndex};
        
        subtest {
          ok Raku::Variable::Hash::Positional ~~ Raku::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Hash::Positional ),	Q{found};
}
          
          done-testing;
        }, Q{Variable::Hash::Positional};
        
        subtest {
          ok Raku::Variable::Hash::Named ~~ Raku::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Hash::Named ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Hash::Named};
        
        subtest {
          ok Raku::Variable::Hash::Pod ~~ Raku::Variable::Hash,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Hash::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Hash::Pod};
        
        subtest {
          ok Raku::Variable::Hash::SubLanguage ~~ Raku::Variable::Hash,
             Q{has correct parent};
#`{
 	  ok has-a( $tree, Raku::Variable::Hash::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Hash::SubLanguage};
        
        done-testing;
      }, Q{Variable::Hash};
      
      subtest {
        ok Raku::Variable::Callable ~~ Raku::Variable, Q{has correct parent};
        ok has-a( $tree, Raku::Variable::Callable ), Q{found};
        
#	subtest {
#	  ok Raku::Variable::Callable::Contextualizer ~~ Raku::Variable::Callable,
#	  Q{has correct parent};
#	  ok has-a( $tree, Raku::Variable::Callable::Contextualizer ),
#	     Q{found};
#
#	  done-testing;
#	}, Q{Variable::Callable::Contextualizer};
        
        subtest {
          ok Raku::Variable::Callable::Dynamic ~~ Raku::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Callable::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Dynamic};
        
        subtest {
          ok Raku::Variable::Callable::Attribute ~~ Raku::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Callable::Attribute ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Attribute};
        
        subtest {
          ok Raku::Variable::Callable::Accessor ~~ Raku::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Callable::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Accessor};
        
        subtest {
          ok Raku::Variable::Callable::CompileTime ~~
             Raku::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Callable::CompileTime ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::CompileTime};
        
        subtest {
          ok Raku::Variable::Callable::MatchIndex ~~ Raku::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Callable::MatchIndex ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::MatchIndex};
        
        subtest {
          ok Raku::Variable::Callable::Positional ~~ Raku::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Callable::Positional ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::Positional};
        
        subtest {
          ok Raku::Variable::Callable::Named ~~ Raku::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Callable::Named ), Q{found};
}

          done-testing;
        }, Q{Variable::Callable::Named};
        
        subtest {
          ok Raku::Variable::Callable::Pod ~~ Raku::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Raku::Variable::Callable::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Pod};
        
        subtest {
          ok Raku::Variable::Callable::SubLanguage ~~
             Raku::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Raku::Variable::Callable::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::SubLanguage};
        
        done-testing;
      }, Q{Variable::Callable};
      
      done-testing;
    }, Q{Variable};
    
    done-testing;
  }, Q{Visible};
  
  subtest {
    ok Raku::Invisible ~~ Raku::Element, Q{has correct parent};
    ok has-a( $tree, Raku::Invisible ), Q{found};
  
    subtest {
      ok Raku::WS ~~ Raku::Invisible, Q{has correct parent};
      ok has-a( $tree, Raku::Document ), Q{found};
  
      done-testing;
    }, Q{WS};
  
    subtest {
      ok Raku::Newline ~~ Raku::Invisible, Q{has correct parent};
      ok has-a( $tree, Raku::Document ), Q{found};
  
      done-testing;
    }, Q{Newline};
  
    done-testing;
  }, Q{Invisible};
  
  subtest {
    ok Raku::Document ~~ Raku::Element, Q{has correct parent};
    ok has-a( $tree, Raku::Document ), Q{found};
  
    done-testing;
  }, Q{Document};
  
  subtest {
    ok Raku::Statement ~~ Raku::Element, Q{has correct parent};
    ok has-a( $tree, Raku::Statement ), Q{found};
  
    done-testing;
  }, Q{Statement};
  
  subtest {
    ok Raku::Block ~~ Raku::Element, Q{has correct parent};
    ok has-a( $tree, Raku::Block ), Q{found};
  
    done-testing;
  }, Q{Block};
  
  done-testing;
}, Q{Element};

done-testing;

# vim: ft=raku
