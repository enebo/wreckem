# (R)uby (E)ntity (C)omponent (M)odelling framework

This is a simple implementation in Ruby of an Entity-Component modelling framework.  It was inspired from reading the excellent series on EC modelling by @cbpowell: http://cbpowell.wordpress.com/2012/10/30/entity-component-game-programming-using-jruby-and-libgdx-part-1/


== Notes

1. Entity or a component may be any matching entity of a component.  When
you care about maintaining a proper relationship in this direction you must
get in the habit of making n instances of the same component.
