---
layout: docs
title: Listeners and Tracing
permalink: /docs/listeners/
---

### Introduction

Clara uses a variation of the [Rete algorithm](https://en.wikipedia.org/wiki/Rete_algorithm) internally for processing.  At a very high level, Clara can be thought of as constructing trees of conditions on facts, where the facts are provided to the roots of the appropriate trees and then flow down through the trees.  The leaf nodes in these trees correspond to either query results or rule right-hand-side (RHS) activations.  

Observing how facts flow this network can at times be useful, and Clara provides an API to do so.  That said, it is emphasized that the details of the generated rule networks and data flow through them are very much internal implementation details of Clara that are subject to change at any time. This API is intentionally "leaky" and provides low-level visibility into Clara's operations.  Most users who need an explanation of why certain rules fired, why a fact was inserted, etc. are encouraged to instead use the [inspection API](/docs/inspection), which is intended as a public API to provide such information without the need to be concerned with Clara's implementation details.

### Custom listeners

All listeners are expected to provide implementations of the [IPersistentEventListener and ITransientEventListener protocols](https://github.com/cerner/clara-rules/blob/0.17.0/src/main/clojure/clara/rules/listener.cljc).  The life cycle between these two listeners will be as follows:

- An implementation of IPersistentEventListener is attached to a session.
- When operations such as fire-rules are called on the session, Clara may internally call [to-transient](https://github.com/cerner/clara-rules/blob/0.17.0/src/main/clojure/clara/rules/listener.cljc#L6) on listeners to obtain a new mutable listener that can respond to operations in the rules network.  Note that Clara's internals use mutation during rule processing, although the user-facing API is of immutable sessions, so listeners have to reflect this.
- Once rule operations are completed, Clara will call [to-persistent!](https://github.com/cerner/clara-rules/blob/0.17.0/src/main/clojure/clara/rules/listener.cljc#L25) on the listener(s) on the session and attach the result to the returned session.  As a result the user should never be exposed to transient listeners.

All listeners should respect the immutability of sessions; i.e. an implementation of IPersistentEventListener should be immutable.

### Tracing listener

Clara provides a [tracing listener](https://github.com/cerner/clara-rules/blob/0.17.0/src/main/clojure/clara/tools/tracing.cljc) that simply records all interactions with the rules network and makes them available as a data structure after all rule operations conclude.  This data structure can then be examined manually, explored in a REPL, etc. For example, if we had a session with rule operations like the following:

{% highlight clojure %}
(defrule too-cold-rule
   [Temperature (= ?location location) (< temperature -50)]
   =>
   (insert! (->StayInsideToday ?location)))

(-> (with-tracing (mk-session [too-cold-rule]))
    (insert (->Temperature -60 "Alaska"))
    fire-rules
    (retract (->Temperature -60 "Alaska"))
    fire-rules
    (insert (->Temperature -70 "Alaska"))
    fire-rules
    get-trace)
{% endhighlight %}

The returned trace would show rule network operations corresponding to the initial insertion of a StayInsideToday, then its retraction, then its insertion again, while session inspection would simply show that a StayInsideToday existed at the end.  In this simple case the operations performed all have obvious corresponding calls to insert and retract, but in the case of complex operations by [truth maintenance](/docs/truthmaint) this may not be the case.  Being able to inspect the actual steps of operations performed by Clara can be useful for investigating complex performance problems, possible bugs in Clara, etc.
