---
layout: docs
title: Writing Expressions
permalink: /docs/expressions/
---

A query or rule left-hand side is a sequence of conditions, all of which must be satisfied for the rule or query to match. Each condition is one of the following:

* A [fact expression](#fact-expressions), which selects a fact based on some given criteria.
* A [boolean expression](#boolean-expressions), which is simply a hierarchical and/or/not structure of other expressions.
* An [accumulator](/docs/accumulators/), which is mechanism to reason about collections of facts
* A [test](#tests), which is an arbitrary Clojure S-expression that can run predicate-style tests on variables bound earlier in the rule or query.

Details on each of these are below.

## Fact Expressions
Fact expresions use the following structure:

![fact expression](/img/diagram/FACT_CONSTRAINT.png)

Fact expressions are the simplest and most common form of Clara conditions. They start with an optional binding for the fact, in the form of _[?variableName <- MyFactType]_. The fact type is then followed by zero or more S-expressions which can either be predicates run against a fact, or bindings, as described above.

A simple fact expression may look like this:

{% highlight clojure %}
[?person <- Person (= first-name "Alice") (= ?last-name last-name)]
{% endhighlight %}

This example does the following:

* Matches all facts of type Person
* Eliminates any Person facts that don't have a first-name attribute that is equal to "Alice"
* Creates a new binding _?last-name_, which contains the value of the last-name field in matched Person facts.
* Creates a new binding _?person_, which contains the value of the matched Person object.

Let's look at how this variable binding works.

### Variable Bindings
Any symbol that starts with a question mark is a variable. Variables are _bound_ either as an entire fact (like the _[?person <- Person]_ example above), or as part of an expression in the form of _(= ?variable-name some-value-or-expression)_.

Variables are _unified_ across all conditions in a rule. If the same binding is used in multiple conditions, Clara ensures that all conditions can be satisfied with the same binding before activating the rule or query.

### Fact Types and Destructuring
_If you plan on using Java Beans or Clojure Records for your facts, you can probably skip this section. As seen in the above examples, Clara simply matches on the bean or record type and makes the fields available to constraint expressions._

While Clojure Records or Java Beans are good for many needs, some use cases ask that Clara rules be written against arbitrary Clojure structures. Clara supports that with two features shown below:

* Users may provide a function to determine the logical type of an incoming fact.
* Users may use Clojure destructuring within a rule to easily access data in the rule's constraints.

Here we look at each of these.

#### Fact Types
The first element of a fact expression is the _fact type_, the logical type of the object that matches the condition. Clara uses Clojure's _type_ function by default to determine the type of an object. The rule itself will match if it uses that type or any ancestor of it.

The strategy for identifying the logical type can be overridden by passing a _:fact-type-fn_ option when creating the session. For instance, if a session is created in the following way:

{% highlight clojure %}
(mk-session 'example.rule :fact-type-fn :request-type)
{% endhighlight %}

Then the caller may insert and match objects like this:

{% highlight clojure %}
{:request-type :get :url "http://example.com/"} ; Matches rules of type :get
{:request-type :put :url "http://example.com"} ; Matches rules of type :put
{% endhighlight %}

This way arbitrary maps can be used as Clara facts, provided a function can be specified that returns the logical type given a map.

#### Destructuring Facts
Facts matching a condition can be arbitrary Clojure maps and destructured using Clojure's destructuring mechanism. For instance, suppose person contained an address and we were interested in the city. We might do something like this:

{% highlight clojure %}
{% raw %}
[Person [{{city :city state :state} :address}] (= ?city city)]
{% endraw %}
{% endhighlight %}

Note that destructuring itself is optional; in its simplest form this could be used just to bind the fact as an argument, just as we would in a function call. For instance:

{% highlight clojure %}
[Person [person] (= ?city (get-in person [:address :city]))]
{% endhighlight %}
Does the same, binding person as the fact argument and simply accessing the nested fields.

If no destructuring block is provided at all, then the default destructuring simply exposes the name of each _field_ of the type to the constraints. Clara _fields_ are simply record fields if the fact is a Clojure record, or Java Bean properties in the case of a bean.

## Boolean Expressions
![boolean expression](/img/diagram/BOOLEAN_EXPR.png)

Boolean expressions are simply prefix-style boolean operations over fact expressions, or nested boolean expressions. Clara requires the use of keyword ':and', :or', and ':not' for its boolean expressions to keep clear what expressions are part of a Rete network as opposed to a normal Clojure expression.

An example boolean expression may look like this:

{% highlight clojure %}
[:or [Customer (= status :vip)]
     [Promotion (= type :discount-month)]]
{% endhighlight %}

This will generate a rule that fires if the Customer fact has a vip status, **or** there is a promotion of type discount month.

:and, :or, and :not operations can be nested as one would expect.

For further information, see [Boolean Expressions](/docs/booleans).

## Exists Expressions

_:exists_ tests the existence or absence of facts without triggering for every fact instance.  For example:

{% highlight clojure %}
[:exists [Person (= name "Bob")]]
{% endhighlight %}

This will trigger the _first_ time a Person with the name "Bob" is inserted, but not the second or third.  It will only retract after all supporting facts are removed.

Unbound variables are treated the same as in [accumulators](/docs/accumulators/); the :exists rule will trigger once for each distinct set of unbound values.

## Tests
![test expression](/img/diagram/TEST_EXPR.png)

Tests in clara are simple predicates that can be run over variables bound earlier in the rule or query. For example:

{% highlight clojure %}
(defrule is-older-than
   [Person (= ?name1 name) (= ?age1 age)]
   [Person (= ?name2 name) (= ?age2 age)]
   [:test (> ?age1 ?age2)]
   =>
   (println (str ?name1 "is older than" ?name2)))
{% endhighlight %}

## What's next?
* [Accumulators](/docs/accumulators/) are used to aggregate or work with collections of matching facts.
