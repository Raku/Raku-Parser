#!/usr/bin/env raku

if !@*ARGS {
    say "Usage: $*PROGRAM-NAME go";
    exit;
}

foo;

sub foo() {
    say "Hi from sub foo!";
}
