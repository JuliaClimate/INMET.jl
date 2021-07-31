module INMET

using HTTP
using JSON
using DataFrames
using Dates
using Printf

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
  root = "https://apitempo.inmet.gov.br/estacoes/"
  url  = root * (kind == :automatic ? "T" : "M")
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
  root = "https://apitempo.inmet.gov.br/estacao"
  kind = freq == :day ? "diaria" : ""
  from = string(start)
  to   = string(finish)
  url  = join([root, kind, from, to, station], "/")
  url |> download |> frame
end

"""
    automatic(time)

Return data for all automatic stations on a given `time`.
The time can be a `Date` or a `DateTime` object. In the
latter case, minutes and seconds are ignored while the
hour information is retained (data in hourly frequency).
"""
function automatic(time)
  root = "https://apitempo.inmet.gov.br/estacao/dados"
  date = string(Date(time))
  hour = time isa DateTime ? (@sprintf "%02d00" Dates.hour(time)) : ""
  url  = join([root, date, hour], "/")
  url |> download |> frame
end

# -----------------
# HELPER FUNCTIONS
# -----------------

function download(url)
  page = HTTP.get(url)
  str  = String(page.body)
  JSON.parse(str)
end

function frame(data)
  asmissing(v) = isnothing(v) ? missing : v
  vars = data |> first |> keys |> collect
  cols = map(vars) do var
    var => [asmissing(d[var]) for d in data]
  end
  DataFrame(cols)
end

end
