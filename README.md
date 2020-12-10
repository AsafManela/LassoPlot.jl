# LassoPlot

| Linux/MacOS/Windows | Code |
| --- | --- |
| [![][actions-img]][actions-url] | [![][codecov-img]][codecov-url] |

LassoPlot.jl is a companion package to [Lasso.jl](https://github.com/JuliaStats/Lasso.jl) which plots regularization paths in a similar fashion to the glmnet and gamlr R packages.

## Quick start

Install the `LassoPlot` package.

First fit a Lasso path

```julia
using Lasso, LassoPath
path = fit(LassoPath, X, y, dist, link)
```

then plot it
```julia
plot(path)
```

Use `x=:segment`, `:λ`, or `:logλ` to change the x-axis, as in:
```julia
plot(path; x=:logλ)
```

LassoPlot uses [Plots.jl](https://github.com/JuliaPlots/Plots.jl), so you
can choose from several plotting backends.

See documentation of the provided plot function for optional arguments (type
`?plot` in the REPL):
```julia
help?> plot
```

[actions-img]: https://github.com/AsafManela/LassoPlot.jl/workflows/CI/badge.svg
[actions-url]: https://github.com/AsafManela/LassoPlot.jl/actions?query=workflow%3ACI+branch%3Amaster

[codecov-img]: http://codecov.io/github/AsafManela/LassoPlot.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/AsafManela/LassoPlot.jl?branch=master
