# (R)uby (E)ntity (C)omponent (M)odelling framework

This is a simple implementation in Ruby of an Entity-Component modelling framework.  It was inspired from reading the excellent series on EC modelling by @cbpowell: http://cbpowell.wordpress.com/2012/10/30/entity-component-game-programming-using-jruby-and-libgdx-part-1/

== Constraints of design

This particular engine is based around some constraints not mentioned in any EC articles that we have seen before.  Many have probably taken similar approaches to wreckem but nothing so far has shown these decisions mentioned publicly.  So, beware that this system may not pan out for large and complex games or large data sets.

=== Min-modelling (components are atoms)

Wreckems first major difference is that all components can only contain a single primitive piece of data (or none at all).  The rationale for this decision is it is the most flexible possible system for modelling.  In one article, they pointed out it was very flexible to have a 2D component containing x,y and then add a new component for just z once you realized you want 3D support in your game.  This obviously shows how powerful EC modelling can be but seeing x,y in one component and z in a third looks like a data smell.  Having independent X and Y components associated with a position entity seems less smelly.  Adding a Z is just adding another component to the entity.

Another interesting observation is seeing warnings in articles about not nesting components in components.  From a min-modelling perspective all compound components do just that.  Something feel right about this at a very high conceptual level.  Is this a smart way to model though?  Is it pragmatic?

Min-modelling components might actually not pan out.  We don't know.  It is something we are trying and so far it is working out ok.  The main issue we have so far is efficient retrieval of maps/hashes since non of our components are lists of hashes.  

A neat area of min-modelling is we have a single-table design where a single SQL query can get all data for an entity or a set of entities.  The data model is ugly in the sense we have nullable fields for unused columns but beautiful in how much information we can get efficiently in a single SQL statement.

=== Components only belong to one thing

This is another big constraint which will add much more data to the db but it also has some significant benefits.  Since no two entities can ever contain the same component this means no concurrency issues can exist if you are acting on two entities at the same time.  It also means it is trivial to know which entity a component belongs to.

The big disadvantage is much larger live object graph since every component will have a different entity field.  So in-memory usage literally is linear to the number of components which all entities can see.  In a system which shares components the memory for components could be dramatically cheaper.

Another mystery to be resolved once we make some sizeable games.

