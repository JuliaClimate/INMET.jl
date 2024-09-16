# INMET.jl

[![][build-img]][build-url] [![][codecov-img]][codecov-url]

Julia API to access data from the [Instituto Nacional de Metereologia (INMET)](https://portal.inmet.gov.br).

For more information about the data, please check their [manual](https://portal.inmet.gov.br/manual/manual-de-uso-da-api-esta%C3%A7%C3%B5es) and [viewer](https://mapas.inmet.gov.br).

![stations](docs/stations.png)

## Installation

Please install the package with Julia's package manager:

```julia
import Pkg

Pkg.add("INMET")
```

The INMET API requires a token, which can be requested by sending an e-mail
to [cadastro.act@inmet.gov.br](mailto:cadastro.act@inmet.gov.br).

Save the token in an environment variable `INMET_TOKEN` to conclude
the installation.

## Usage

Below are a few examples of usage. For more details, please read the docstrings.

```julia
julia> using INMET

julia> INMET.stations()
566×15 DataFrame
 Row │ TP_ESTACAO  CD_ESTACAO  SG_ESTADO  CD_SITUACAO  CD_DISTRITO  CD_OSCAR        DT_FIM_OPERACAO  CD_WSI                   SG_ENTIDADE  DT_INICIO_OPERACAO         ⋯
     │ String      String      String     String       String       String?         Missing          String?                  String       String                     ⋯
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ Automatica  A422        BA         Pane          04          0-2000-0-86765          missing  0-76-0-2906907000000408  INMET        2008-07-20T21:00:00.000-03 ⋯
   2 │ Automatica  A360        CE         Pane          03          0-2000-0-81755          missing  0-76-0-2300200000000446  INMET        2009-04-21T21:00:00.000-03
   3 │ Automatica  A657        ES         Operante      06          0-2000-0-86827          missing  0-76-0-3200102000000478  INMET        2011-09-23T21:00:00.000-03
   4 │ Automatica  A908        MT         Operante      09          0-2000-0-86686          missing  0-76-0-5100201000000157  INMET        2006-12-15T21:00:00.000-03
   5 │ Automatica  A756        MS         Operante      07          0-2000-0-86812          missing  0-76-0-5000203000000463  INMET        2010-08-13T21:00:00.000-03 ⋯
  ⋮  │     ⋮           ⋮           ⋮           ⋮            ⋮             ⋮                ⋮                    ⋮                  ⋮                     ⋮            ⋱
 563 │ Automatica  A414        BA         Operante      04          0-2000-0-86697          missing  0-76-0-2933307000000204  INMET        2007-05-31T21:00:00.000-03
 564 │ Automatica  A858        SC         Operante      08          0-2000-0-86940          missing  0-76-0-4219507000000318  INMET        2008-03-14T21:00:00.000-03
 565 │ Automatica  A247        PA         Operante      02          0-2000-0-81896          missing  0-76-0-1508407000000527  INMET        2016-09-10T21:00:00.000-03
 566 │ Automatica  A255        MA         Operante      02          0-2000-0-81747          missing  0-76-0-2114007000000596  INMET        2019-09-17T21:00:00.000-03 ⋯
                                                                                                                                         6 columns and 557 rows omitted

julia> INMET.series(:A301, Date(2021,1,1), Date(2021,7,31))
212×13 DataFrame
 Row │ CD_ESTACAO  UF      VEL_VENTO_MED  DC_NOME  DT_MEDICAO  VL_LONGITUDE  VL_LATITUDE  TEMP_MIN   TEMP_MED   TEMP_MAX   UMID_MIN   UMID_MED   CHUVA      
     │ String      String  String         String   String      Quantity…     Quantity…    Quantity…  Quantity…  Quantity…  Quantity…  Quantity…  Quantity…? 
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ A301        PE      1.7            RECIFE   2021-01-01     -34.9592°    -8.05917°    24.3 °C    27.2 °C    31.0 °C     54.0 %     72.5 %      2.8 mm
   2 │ A301        PE      1.6            RECIFE   2021-01-02     -34.9592°    -8.05917°    22.3 °C    27.0 °C    31.6 °C     54.0 %     72.9 %      0.0 mm
   3 │ A301        PE      2              RECIFE   2021-01-03     -34.9592°    -8.05917°    24.0 °C    27.6 °C    31.3 °C     54.0 %     70.4 %      0.0 mm
   4 │ A301        PE      1.9            RECIFE   2021-01-04     -34.9592°    -8.05917°    24.1 °C    27.1 °C    31.0 °C     59.0 %     75.3 %      2.0 mm
   5 │ A301        PE      1.8            RECIFE   2021-01-05     -34.9592°    -8.05917°    22.2 °C    27.1 °C    31.3 °C     49.0 %     68.9 %      0.0 mm
  ⋮  │     ⋮         ⋮           ⋮           ⋮         ⋮            ⋮             ⋮           ⋮          ⋮          ⋮          ⋮          ⋮          ⋮
 209 │ A301        PE      1              RECIFE   2021-07-28     -34.9592°    -8.05917°    21.5 °C    24.4 °C    28.8 °C     66.0 %     80.0 %     11.0 mm
 210 │ A301        PE      0.9            RECIFE   2021-07-29     -34.9592°    -8.05917°    20.4 °C    24.8 °C    29.9 °C     57.0 %     83.4 %      0.0 mm
 211 │ A301        PE      1.1            RECIFE   2021-07-30     -34.9592°    -8.05917°    19.9 °C    23.8 °C    28.7 °C     61.0 %     86.0 %      0.0 mm
 212 │ A301        PE      1.9            RECIFE   2021-07-31     -34.9592°    -8.05917°    21.2 °C    24.7 °C    28.5 °C     63.0 %     83.4 %      6.6 mm
                                                                                                                                            203 rows omitted

julia> INMET.on(Date(2021,7,1))
603×24 DataFrame
 Row │ CD_ESTACAO  UF      HR_MEDICAO  DC_NOME                         DT_MEDICAO  VL_LONGITUDE  VL_LATITUDE  TEM_INS     TEM_MIN     TEM_MAX     UMD_INS     UMD_MIN ⋯
     │ String      String  String      String                          String      Quantity…     Quantity…    Quantity…?  Quantity…?  Quantity…?  Quantity…?  Quantit ⋯
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ A001        DF      0000        BRASILIA                        2021-07-01     -47.9258°    -15.7894°     15.4 °C     15.0 °C     15.7 °C      61.0 %      61. ⋯
   2 │ A002        GO      0000        GOIÂNIA                         2021-07-01     -49.2203°    -16.6428°     14.1 °C     14.1 °C     15.2 °C      50.0 %      48.
   3 │ A003        GO      0000        MORRINHOS                       2021-07-01     -49.1017°    -17.7451°     10.9 °C     10.9 °C     12.0 °C      44.0 %      40.
   4 │ A004        GO      0000        NIQUELANDIA                     2021-07-01     -48.4858°    -14.4694°     missing     missing     missing     missing     miss
   5 │ A005        GO      0000        PORANGATU                       2021-07-01     -49.1175°    -13.3094°     missing     missing     missing     missing     miss ⋯
  ⋮  │     ⋮         ⋮         ⋮                     ⋮                     ⋮            ⋮             ⋮           ⋮           ⋮           ⋮           ⋮           ⋮   ⋱
 600 │ B804        PR      0000        LARANJEIRAS DO SUL              2021-07-01     -52.4008°    -25.3714°     missing     missing     missing     missing     miss
 601 │ B806        PR      0000        COLOMBO                         2021-07-01     -49.1577°    -25.3225°      4.1 °C      4.1 °C      6.0 °C      92.0 %      82.
 602 │ B807        RS      0000        PORTO ALEGRE- BELEM NOVO        2021-07-01     -51.1781°    -30.1861°     missing     missing     missing     missing     miss
 603 │ F501        MG      0000        BELO HORIZONTE - CERCADINHO     2021-07-01     -43.9586°      -19.98°     14.9 °C     14.9 °C     17.7 °C      66.0 %      49. ⋯
                                                                                                                                        13 columns and 594 rows omitted
```

[build-img]: https://img.shields.io/github/actions/workflow/status/JuliaClimate/INMET.jl/CI.yml?branch=master&style=flat-square
[build-url]: https://github.com/JuliaClimate/INMET.jl/actions

[codecov-img]: https://img.shields.io/codecov/c/github/JuliaClimate/INMET.jl?style=flat-square
[codecov-url]: https://codecov.io/gh/JuliaClimate/INMET.jl
