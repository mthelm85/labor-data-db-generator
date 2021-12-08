using CSV
using DataFramesMeta
using Dates
using Mongoc

client = Mongoc.Client("mongodb://localhost:27017")
db = client["labor-data"]
collection = db["counties"]

include("./QCEW.jl")
include("./LAUS.jl")

append!(collection, [Mongoc.BSON(dict) for dict in counties_dict])

#= This is what we are going for:
{
    state_fips: 12,
    county_fips: 123,
    fips: 12123,
    place_name: "Santa Rosa, FL",
    district_office: "Tampa",
    regional_office: "Southeast",
    series: {
        laus: [
            {
                year: 2020,
                month: 1,
                unemployment_rate: 5.5
            },
            {
                year: 2020,
                month: 2,
                unemployment_rate: 5.7
            }
        ],
        qcew: [
            {
                year: 2020,
                qtr: "A",
                annual_avg_wkly_wage: 845
            }
        ]
    }
}
=#