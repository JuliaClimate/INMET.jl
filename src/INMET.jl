module INMET

using HTTP
using JSON
using DataFrames

"""
    stations(kind=:T)

Return INMET stations of given `kind`. There are two
kinds of stations: automatic (`:T`) and manual (`:M`).
"""
function stations(kind=:T)
  root = "https://apitempo.inmet.gov.br/estacoes/"
  url  = root * String(kind)
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
