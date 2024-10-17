module INMET

using HTTP
using JSON
using DataFrames
using Unitful
using Dates
using Printf

import Unitful: °, m, °C, percent

export Date, DateTime

# -----------
# PUBLIC API
# -----------

"""
    stations(kind=:automatic)

Return INMET stations of given `kind`. There are two
kinds of stations: `:automatic` and `:manual`.
"""
function stations(kind=:automatic)
  @assert kind ∈ [:automatic,:manual] "invalid kind"
  TM = kind == :automatic ? "T" : "M"
  url = "https://apitempo.inmet.gov.br/estacoes/$TM"
  url |> download |> frame
end

"""
    series(station, start, finish, freq=:day)

Return time series for a given `station` from `start`
to `finish` date with frequency `freq`.

Available codes for stations can be found in the result of
[`stations`](@ref) in the column `CD_ESTACAO`, e.g. `:A301`.

Start and end dates are specified as Julia `Date` objects.
For example, the date `2021-07-31` is represented with
`Date(2021,7,31)`. The frequency can be `:day` or `:hour`.
"""
function series(station, start, finish, freq=:day)
  @assert freq ∈ [:day,:hour] "invalid frequency"
  kind = freq == :day ? "diaria" : ""
  from = string(start)
  to   = string(finish)
  token = inmettoken()
  url = "https://apitempo.inmet.gov.br/token/estacao/$kind/$from/$to/$station/$token"
  url |> download |> frame
end

"""
    on(time)

Return data for all automatic stations on a given `time`.
The time can be a `Date` or a `DateTime` object. In the
latter case, minutes and seconds are ignored while the
hour information is retained (data in hourly frequency).
"""
function on(time)
  date = string(Date(time))
  hour = time isa DateTime ? (@sprintf "%02d00" Dates.hour(time)) : "0000"
  token = inmettoken()
  url = "https://apitempo.inmet.gov.br/token/estacao/dados/$date/$hour/$token"
  url |> download |> frame
end

# -----------------
# HELPER FUNCTIONS
# -----------------

function inmettoken()
  if !haskey(ENV, "INMET_TOKEN")
    throw(ErrorException("""
    The INMET API requires a token, which can be requested by sending an e-mail
    to [cadastro.act@inmet.gov.br](mailto:cadastro.act@inmet.gov.br).

    Save the token in an environment variable `INMET_TOKEN` to use this package.
    """))
  end
  ENV["INMET_TOKEN"]
end

function download(url)
  page = HTTP.get(url)
  str  = String(page.body)
  JSON.parse(str)
end

function frame(data)
  # replace nothing by missing
  asmissing(v) = isnothing(v) ? missing : v
  vars = data |> first |> keys |> collect
  df = map(vars) do var
    var => [asmissing(d[var]) for d in data]
  end |> DataFrame

  # available columns
  AVAIL = propertynames(df)

  # numeric columns
  NUM = [:VL_LONGITUDE,:VL_LATITUDE,:VL_ALTITUDE,
         :TEM_INS,:TEM_MIN,:TEM_MAX,
         :TEMP_MIN,:TEMP_MED,:TEMP_MAX,
         :UMD_INS,:UMD_MIN,:UMD_MAX,
         :UMID_MIN,:UMID_MED,:UMID_MAX,
         :PRE_INS,:PRE_MIN,:PRE_MAX,
         :VEN_VEL,:VEN_RAJ,:VEN_DIR,
         :PTO_INS,:PTO_MIN,:PTO_MAX,
         :RAD_GLO,:CHUVA]

  # physical units
  UNIT = [°,°,m,
          °C,°C,°C,
          °C,°C,°C,
          percent,percent,percent,
          percent,percent,percent,
          u"mbar",u"mbar",u"mbar",
          u"m/s",u"m/s",°,
          °C,°C,°C,
          u"W/m^2",u"mm"]

  # dictionary mapping names to units
  UNIT4VAR = Dict(NUM .=> UNIT)

  # available numeric columns
  NUMAVAIL = [V for V in NUM if V in AVAIL]

  # parse numeric columns as floats with units
  str2float(v) = ismissing(v) ? missing : parse(Float64, v)
  floatunit(v, u) = ismissing(v) ? missing : v*u
  for var in NUMAVAIL
    unitful(v) = floatunit(v, UNIT4VAR[var])
    transform!(df, var => ByRow(str2float) => var)
    transform!(df, var => ByRow(unitful) => var)
  end

  select(df, Not(NUMAVAIL), NUMAVAIL)
end

end
