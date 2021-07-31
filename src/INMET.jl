module INMET

using HTTP
using JSON
using DataFrames
using Dates

export Date

"""
    stations(kind=:automatic)

Return INMET stations of given `kind`. There are two
kinds of stations: `:automatic` and `:manual`.
"""
function stations(kind=:automatic)
  root = "https://apitempo.inmet.gov.br/estacoes/"
  url  = root * (kind == :automatic ? "T" : "M")
  page = HTTP.get(url)
  str  = String(page.body)
  data = JSON.parse(str)
  vars = data |> first |> keys |> collect
  cols = map(vars) do var
    var => [d[var] for d in data]
  end
  DataFrame(cols)
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
  root = "https://apitempo.inmet.gov.br/estacao"
  kind = freq == :day ? "diaria" : ""
  from = string(start)
  to   = string(finish)
  url  = join([root, kind, from, to, station], "/")
  page = HTTP.get(url)
  str  = String(page.body)
  data = JSON.parse(str)
  vars = data |> first |> keys |> collect
  cols = map(vars) do var
    var => [d[var] for d in data]
  end
  DataFrame(cols)
end

end
