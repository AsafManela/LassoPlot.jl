"""
    plot(path::RegularizationPath, args...; <keyword arguments>)

Plots a `RegularizationPath` fitted with the `Lasso` package.

The minimum AICc segment is represented by a solid vertical line and the CVmin
and CV1se cross-validation selected segments by dashed vertical lines.

By default it shows nonzero coefficients at the AICc in color and the rest grayed out.

LassoPlot uses Plots.jl, so you can set any supported backend before plotting,
and add any features of the plot afterwards.

# Example:
```julia
    using Lasso, LassoPath, Plots
    path = fit(LassoPath, X, y, dist, link)
    plot(path)
```
# Arguments
- `args...` additional arguments passed to Plots.plot()

# Keywords
- `x=:segment` one of (:segment, :λ, :logλ)
- `varnames=nothing` specify variable names
- `select=MinAICc()` Path segment selector (e.g. MinBIC(), MinCVmse(path, 5), MinCV1se(path, 5)) for which coefficients
    will be shown in color. The rest are grayed out.
- `showselectors=[MinAICc(), MinCVmse(path, 5), MinCV1se(path, 5)]` shown vertical lines
- `selectedvars=[]` Subset of the variables to present, or empty vector for all
- `kwargs...` additional keyword arguments passed along to fit(GammaLassoPath,...)
"""
function Plots.plot(path::RegularizationPath, args...;
    x=:segment, varnames=nothing, selectedvars=[], select=MinAICc(), showselectors=[MinAICc(), MinCVmse(path, 10), MinCV1se(path, 10)])
    β=coef(path)
    if hasintercept(path)
        β = β[2:end,:]
    end

    (p,nλ)=size(β)

    if varnames==nothing
        varnames=[Symbol("x$i") for i=1:p]
    end

    indata=DataFrame()
    if x==:λ
        indata[x]=path.λ
    elseif x==:logλ
        indata[x]=log.(path.λ)
    else
        x=:segment
        indata[x]=1:nλ
    end
    outdata = deepcopy(indata)

    # automatic selectors
    # xintercept = Float64[]
    dashed_vlines=Float64[]
    solid_vlines=Float64[]

    selectors = union([select], showselectors)
    ixselect = 0

    for s in selectors
        ixshown = segselect(path, s)
        if select == s
            push!(solid_vlines,indata[ixshown,x])
            ixselect = ixshown
        else
            push!(dashed_vlines,indata[ixshown,x])
        end
    end

    if length(selectedvars) == 0
        if isa(select, AllSeg)
            selectedvars = 1:p
        else
            selectedvars = findall(!iszero, β[:,ixselect])
        end
    end

    # colored paths
    for j in selectedvars
        indata[varnames[j]]=Vector(β[j,:])
    end

    # grayed out paths
    for j in setdiff(1:p,selectedvars)
        outdata[varnames[j]]=Vector(β[j,:])
    end

    inmdframe=melt(indata,x)
    outmdframe=melt(outdata,x)
    rename!(inmdframe,:value=>:coefficients)
    rename!(outmdframe,:value=>:coefficients)
    inmdframe = inmdframe[convert(BitArray,map(b->!isnan(b),inmdframe[:coefficients])),:]
    outmdframe = outmdframe[convert(BitArray,map(b->!isnan(b),outmdframe[:coefficients])),:]

    p = plot(xlabel=string(x), ylabel="Coefficient", args...)
    if size(inmdframe,1) > 0
      @df inmdframe plot!(cols(x), :coefficients, group=:variable)
    end
    if size(outmdframe,1) > 0
      @df outmdframe plot!(cols(x), :coefficients, group=:variable, palette=:grays)
    end
    if length(dashed_vlines) > 0
        vline!(dashed_vlines, line = (:dash, 0.5, 2, :black), label="")
    end
    if length(solid_vlines) > 0
        vline!(solid_vlines, line = (:solid, 0.5, 2, :black), label="")
    end

    p
end
