datapath = joinpath(dirname(pathof(Lasso)),"..","test","data")
plotspath = joinpath(dirname(@__FILE__), "plots")
mkpath(plotspath)

Random.seed!(243214)
@testset "plot GammaLassoPath's" begin
    @testset "$family" for (family, dist, link) in (("gaussian", Normal(), IdentityLink()), ("binomial", Binomial(), LogitLink()), ("poisson", Poisson(), LogLink()))
        data = CSV.read(joinpath(datapath,"gamlr.$family.data.csv"))
        y = convert(Vector{Float64},data[1])
        X = convert(Matrix{Float64},data[2:end])
        (n,p) = size(X)
        @testset "γ=$γ" for γ in [0 2 10]
            fitname = "gamma$γ.pf1"
            if !isfile(joinpath(datapath,"gamlr.$family.$fitname.params.csv"))
                # file names in older Lasso packages
                fitname = "gamma$γ"
            end
            # get gamlr.R params and estimates
            params = CSV.read(joinpath(datapath,"gamlr.$family.$fitname.params.csv"))
            fittable = CSV.read(joinpath(datapath,"gamlr.$family.$fitname.fit.csv"))
            gcoefs = convert(Matrix{Float64},CSV.read(joinpath(datapath,"gamlr.$family.$fitname.coefs.csv")))
            family = params[1,Symbol("fit.family")]
            γ=params[1,Symbol("fit.gamma")]

            # fit julia version
            glp = fit(GammaLassoPath, X, y, dist, link; γ=γ, λminratio=0.001)

            # test plots
            p = plot(glp;x=:logλ)
            filename = joinpath(plotspath,"$family.$fitname.path.svg")
            draw(SVG(filename,5inch,5inch),p)
            @test isfile(filename)
        end
    end
end

# comment the next line to see plots after test finishes in test/plots/
rm(plotspath;recursive=true)

### debugging code ######
# (family, dist, link) = (("gaussian", Normal(), IdentityLink()), ("binomial", Binomial(), LogitLink()), ("poisson", Poisson(), LogLink()))[1]
# γ = 0
#
# data = CSV.read(joinpath(datapath,"gamlr.$family.data.csv"))
# y = convert(Vector{Float64},data[1])
# X = convert(Matrix{Float64},data[2:end])
# (n,p) = size(X)
#
# fitname = "gamma$γ.pf1"
# # get gamlr.R prms and estimates
# prms = CSV.read(joinpath(datapath,"gamlr.$family.$fitname.params.csv"))
# fittable = CSV.read(joinpath(datapath,"gamlr.$family.$fitname.fit.csv"))
# gcoefs = convert(Matrix{Float64},CSV.read(joinpath(datapath,"gamlr.$family.$fitname.coefs.csv")))
# family = prms[1,Symbol("fit.family")]
# γ=prms[1,Symbol("fit.gamma")]
# # λ = convert(Vector{Float64},fittable[:fit_lambda]) # should be set to nothing evenatually
#
# # fit julia version
# glp = fit(GammaLassoPath, X, y, dist, link; γ=γ, λminratio=0.001) #, λ=λ)
#
# # test plots
# p = plot(glp;x=:logλ)
# plot(glp)
# filename = joinpath(plotspath,"$family.$fitname.path.svg")
# draw(SVG(filename,5inch,5inch),p)
# @test isfile(filename)
#
# path = glp
# x=:segment; varnames=nothing; selectedvars=[]; select=:AICc; showselectors=[:AICc,:CVmin,:CV1se]; nCVfolds=10;
# β=coef(path)
# if hasintercept(path)
#     β = β[2:end,:]
# end
#
# (p,nλ)=size(β)
#
# if varnames==nothing
#     varnames=[Symbol("x$i") for i=1:p]
# end
#
# indata=DataFrame()
# if x==:λ
#     indata[x]=path.λ
# elseif x==:logλ
#     indata[x]=log.(path.λ)
# else
#     x=:segment
#     indata[x]=1:nλ
# end
# outdata = deepcopy(indata)
#
# # automatic selectors
# # xintercept = Float64[]
# dashed_vlines=Float64[]
# solid_vlines=Float64[]
#
# if select == :AICc || :AICc in showselectors
#     minAICcix=minAICc(path)
#     if select == :AICc
#         push!(solid_vlines,indata[minAICcix,x])
#     else
#         push!(dashed_vlines,indata[minAICcix,x])
#     end
# end
#
# if select == :CVmin || :CVmin in showselectors
#     gen = Kfold(length(path.m.rr.y),nCVfolds)
#     segCVmin = cross_validate_path(path;gen=gen,select=:CVmin)
#     if select == :CVmin
#         push!(solid_vlines,indata[segCVmin,x])
#     else
#         push!(dashed_vlines,indata[segCVmin,x])
#     end
# end
#
# if select == :CV1se || :CV1se in showselectors
#     gen = Kfold(length(path.m.rr.y),nCVfolds)
#     segCV1se = cross_validate_path(path;gen=gen,select=:CV1se)
#     if select == :CV1se
#         push!(solid_vlines,indata[segCV1se,x])
#     else
#         push!(dashed_vlines,indata[segCV1se,x])
#     end
# end
#
# if length(selectedvars) == 0
#     if select == :all
#         selectedvars = 1:p
#     elseif select == :AICc
#         selectedvars = findall(!iszero, β[:,minAICcix])
#     elseif select == :CVmin
#         selectedvars = findall(!iszero, β[:,segCVmin])
#     elseif select == :CV1se
#         selectedvars = findall(!iszero, β[:,segCV1se])
#     else
#         error("unknown selector $select")
#     end
# end
#
# # colored paths
# for j in selectedvars
#     indata[varnames[j]]=Vector(β[j,:])
# end
#
# # grayed out paths
# for j in setdiff(1:p,selectedvars)
#     outdata[varnames[j]]=Vector(β[j,:])
# end
#
# inmdframe=melt(indata,x)
# outmdframe=melt(outdata,x)
# rename!(inmdframe,:value=>:coefficients)
# rename!(outmdframe,:value=>:coefficients)
# inmdframe = inmdframe[convert(BitArray,map(b->!isnan(b),inmdframe[:coefficients])),:]
# outmdframe = outmdframe[convert(BitArray,map(b->!isnan(b),outmdframe[:coefficients])),:]
#
# layers=Vector{Layer}()
# if length(dashed_vlines) > 0
#     append!(layers,layer(xintercept=dashed_vlines, Geom.vline, Theme(default_color=colorant"black",line_style=[:dot])))
# end
# if length(solid_vlines) > 0
#     append!(layers,layer(xintercept=solid_vlines, Geom.vline, Theme(default_color=colorant"black")))
# end
# if size(inmdframe,1) > 0
#   append!(layers, layer(inmdframe,x=x,y="coefficients",color="variable",Geom.line))
# end
# if size(outmdframe,1) > 0
#   append!(layers,layer(outmdframe,x=x,y="coefficients",group="variable",Geom.line,Theme(default_color=colorant"lightgray")))
# end
#
# Gadfly.plot(layers..., Stat.xticks(coverage_weight=1.0), gadfly_args...)
