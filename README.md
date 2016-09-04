# LassoPlot

[![Build Status](https://travis-ci.org/AsafManela/LassoPlot.jl.svg?branch=master)](https://travis-ci.org/AsafManela/LassoPlot.jl)

LassoPlot.jl is a companion package to [Lasso.jl](https://github.com/simonster/Lasso.jl) which plots regularization paths in a similar fashion to the glmnet and gamlr R packages.

## Quick start

first fit a Lasso path

```julia
using Lasso, LassoPath
path = fit(LassoPath, X, y, dist, link)
```

then plot it
```julia
plot(path)
```

Use x=:segment, :λ, or :logλ to change the x-axis, as in:
```julia
plot(path; x=:logλ)
```

The following keyword arguments can be used:

By default it shows non zero coefficients at the AICc in color and the rest grayed out.

Use selectedvars to select a subset of the variables to present.

The minimum AICc segment is represented by a solid vertical line and the CVmin and CV1se cross-validation selected segments in dashed vertical lines.

To specify other selection criteria use the select=:AICc, :CVmin, or :CV1se.

Vertical lines are determined by showselectors=[:AICc,:CVmin,:CV1se].

varnames can be used to specify variable names.
