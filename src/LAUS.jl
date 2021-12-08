year(date) = 2000 + parse(Int64, first(date, 2))

months = Dict(
    "Jan" => 1,
    "Feb" => 2,
    "Mar" => 3,
    "Apr" => 4,
    "May" => 5,
    "Jun" => 6,
    "Jul" => 7,
    "Aug" => 8,
    "Sep" => 9,
    "Oct" => 10,
    "Nov" => 11,
    "Dec" => 12
)

month(date) = months[last(date, 3)]

function fips(state, county)
    st = lpad(state, 2, "0")
    cty = lpad(county, 3, "0")
    st * cty
end

df_unemployment = @chain DataFrame(CSV.File(raw"C:\Users\mthel\Julia\src_data\unemployment_rate.csv", normalizenames=true)) begin
    @transform(
        :year = year.(:period),
        :month = month.(:period),
        :fips = fips.(:state_fips, :county_fips)
    )
end

for row in eachrow(df_unemployment)
    i = findfirst(x -> x["fips"] == row.fips, counties_dict)
    if !isnothing(i)
        doc = Dict()
        doc["year"] = row.year
        doc["month"] = row.month
        doc["unemployment_rate"] = row.unemployment_rate
        doc["labor_force"] = row.labor_force
        doc["employed"] = row.employed
        doc["unemployed"] = row.Unemployed
        push!(counties_dict[i]["series"]["laus"], doc)
    end
end