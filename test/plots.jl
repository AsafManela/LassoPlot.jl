using DataFrames, CSV, Gadfly

datapath = joinpath(Pkg.dir("Lasso"),"test","data")
plotspath = joinpath(dirname(@__FILE__), "plots")
mkpath(plotspath)

srand(243214)
@testset "plot GammaLassoPath's" begin
    @testset "$family" for (family, dist, link) in (("gaussian", Normal(), IdentityLink()), ("binomial", Binomial(), LogitLink()), ("poisson", Poisson(), LogLink()))
        data = CSV.read(joinpath(datapath,"gamlr.$family.data.csv"))
        y = convert(Vector{Float64},data[:,1])
        X = convert(Matrix{Float64},data[:,2:end])
        (n,p) = size(X)
        @testset "γ=$γ" for γ in [0 2 10]
            fitname = "gamma$γ.pf1"
            # get gamlr.R params and estimates
            params = CSV.read(joinpath(datapath,"gamlr.$family.$fitname.params.csv"))
            fittable = CSV.read(joinpath(datapath,"gamlr.$family.$fitname.fit.csv"))
            gcoefs = convert(Matrix{Float64},CSV.read(joinpath(datapath,"gamlr.$family.$fitname.coefs.csv")))
            family = params[1,Symbol("fit.family")]
            γ=params[1,Symbol("fit.gamma")]

            # fit julia version
            glp = fit(GammaLassoPath, X, y, dist, link; γ=γ, λminratio=0.001) #, λ=λ)

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
