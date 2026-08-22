# Combinational and Sequential

Digital circuits are classified as either **combinational** or **squential**. A combinational circuit computes the output depending only on the present input values. For example, a logic gate, adder, or multiplier are circuits that depends only on the present input. _Therefore a combination circuit has no memory_.

On the other hand, a sequential circuit's output depends on __input sequence__. It means a sequential circuit depends on both the present and previous input values. _This means a sequential circuit has memory_.

A Combinational circuit can be describe by its two specifications, **functional** and **timing** specification. The functional specification defines the output given the present inputs (usually expressed as _truth table_ or _boolean equation_), while the timing specification defines the upper and lower boundary of delay from input to output.

Let's dive into an example. Suppose we define a combinational circuit below.

> **TODO** Add an image

We express the combination circuit above as C = F(A,B), wherein C is a function of inputs A and B. There are multiple constraints when choosing implementations for this combinational circuits. This constraints often include _area_, _speed_ or _timing_, _power_ and _design time_.

> **NOTE:** What makes a circuit combinational?
> 1. Every circuit element is combinational
> 2. Every node of the circuit is either designated as input to the circuit or connects to exactly out output terminal of a circuit element.
> 3. Contains **no cyclic path**, every path visits each circuit nodes **only once**.

# Boolean Equations: Quick!

## Complement

We say ~A is the complement of A. If A is TRUE, ~A is FALSE and vice versa. We call **A** as **True Form** and **~A** as **Inverse**.

## AND (Product or Implicant)

## OR (Sum)

The order of operation is important when interpreting boolean equation. example is:

Y = A + BC

Does this means Y is (A OR B) AND C or does this mean Y is A OR (B AND C). In Boolean Equations, the order of precedence from highest to lowest is **NOT, AND then OR**.
