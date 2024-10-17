using INMET
using Test

@testset "INMET.jl" begin
  @testset "stations" begin
    # automatic stations
    df = INMET.stations()
    @test all(isequal("Automatica"), df.TP_ESTACAO)

    # manual stations
    df = INMET.stations(:manual)
    @test all(isequal("Convencional"), df.TP_ESTACAO)
  end

  @testset "series" begin
    if haskey(ENV, "INMET_TOKEN")
      df = INMET.series(:A301, Date(2021,1,1), Date(2021,7,31))
      @test all(isequal("A301"), df.CD_ESTACAO)
    else
      @test_throws ErrorException INMET.series(:A301, Date(2021,1,1), Date(2021,7,31))
    end
  end

  @testset "on" begin
    if haskey(ENV, "INMET_TOKEN")
      dfday  = INMET.on(Date(2021,7,1))
      dfhour = INMET.on(DateTime(2021,7,1,1))
      @test size(dfday, 1) > size(dfhour, 1)
      @test all(isequal("2021-07-01"), dfday.DT_MEDICAO)
      @test all(isequal("2021-07-01"), dfhour.DT_MEDICAO)
      @test all(isequal("0100"), dfhour.HR_MEDICAO)
    else
      @test_throws ErrorException INMET.on(Date(2021,7,1))
      @test_throws ErrorException INMET.on(Date(2021,7,1))
    end
  end
end
