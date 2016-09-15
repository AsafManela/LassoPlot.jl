# Comparing with Matt Taddy's gamlr.R
# To rebuild the test cases source(gammalasso.R)
# using Lasso
using DataFrames, Gadfly, FactCheck

datapath = joinpath(Pkg.dir("Lasso"),"test","data")
plotspath = joinpath(dirname(@__FILE__), "plots")
mkpath(plotspath)

srand(243214)
facts("plot GammaLassoPath's") do
    for (family, dist, link) in (("gaussian", Normal(), IdentityLink()), ("binomial", Binomial(), LogitLink()), ("poisson", Poisson(), LogLink()))
        context(family) do
            data = readcsv(joinpath(datapath,"gamlr.$family.data.csv"))
            y = convert(Vector{Float64},data[:,1])
            X = convert(Matrix{Float64},data[:,2:end])
            (n,p) = size(X)
            for γ in [0 2 10]
                fitname = "gamma$γ"
                # get gamlr.R params and estimates
                params = readtable(joinpath(datapath,"gamlr.$family.$fitname.params.csv"))
                fittable = readtable(joinpath(datapath,"gamlr.$family.$fitname.fit.csv"))
                gcoefs = convert(Matrix{Float64},readcsv(joinpath(datapath,"gamlr.$family.$fitname.coefs.csv")))
                family = params[1,:fit_family]
                γ=params[1,:fit_gamma]
                # λ = convert(Vector{Float64},fittable[:fit_lambda]) # should be set to nothing evenatually
                context("γ=$γ") do

                    # fit julia version
                    glp = fit(GammaLassoPath, X, y, dist, link; γ=γ, λminratio=0.001) #, λ=λ)

                    # test plots
                    p = plot(glp;x=:logλ)
                    filename = joinpath(plotspath,"$family.$fitname.path.svg")
                    draw(SVG(filename,5inch,5inch),p)
                    @fact isfile(filename) --> true
                end
            end
        end
    end
end

# comment the next line to see plots after test finishes in Lasso/test/plots/
rm(plotspath;recursive=true)
