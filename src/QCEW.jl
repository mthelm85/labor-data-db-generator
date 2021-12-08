fips_names = DataFrame(CSV.File(raw"C:\Users\mthel\Julia\src_data\do_counties_fy21.csv"))

df_qcew = @chain DataFrame(CSV.File(raw"C:\Users\mthel\Data\QCEW\2020.annual.singlefile.csv")) begin
    @subset(((:agglvl_code .== 75) .| (:agglvl_code .== 71)) .& (:own_code .== 5))
    @transform(
        :state_fips = first.(:area_fips, 2),
        :county_fips = last.(:area_fips, 3)
    )
end

counties = DataFrame(
    state_fips=String[],
    county_fips=String[],
    fips=String[],
    place_name=Union{Missing,String}[],
    do_name=Union{Missing,String}[],
    region_name=Union{Missing,String}[]
)

function do_name(fips)
    i = findfirst(x -> x == parse(Int64, fips), fips_names.GEOID10)
    isnothing(i) ? "" : fips_names[i, :wh_office_name]
end

function region_name(fips)
    i = findfirst(x -> x == parse(Int64, fips), fips_names.GEOID10)
    isnothing(i) ? "" : fips_names[i, :region_name]
end

function place_name(fips)
    i = findfirst(x -> x == parse(Int64, fips), fips_names.GEOID10)
    isnothing(i) ? "" : fips_names[i, :CountyState]
end

for row in eachrow(unique(@subset(df_qcew, :agglvl_code .== 75), :area_fips))
    push!(counties, [
        row.state_fips,
        row.county_fips,
        row.area_fips,
        place_name(row.area_fips),
        do_name(row.area_fips),
        region_name(row.area_fips)
    ])
end

counties_dict = []

for row in eachrow(counties)
    doc = Dict()
    doc["state_fips"] = row.state_fips
    doc["county_fips"] = row.county_fips
    doc["fips"] = row.fips
    doc["place_name"] = row.place_name
    doc["do_name"] = row.do_name
    doc["region_name"] = row.region_name
    doc["series"] = Dict("laus" => Dict[], "qcew" => Dict[])
    push!(counties_dict, doc)
end

for row in eachrow(unique(@subset(df_qcew, :industry_code .== "10"), :area_fips))
    i = findfirst(x -> x["fips"] == row.area_fips, counties_dict)
    if !isnothing(i)
        doc = Dict()
        doc["year"] = row.year
        doc["qtr"] = row.qtr
        doc["annual_avg_wkly_wage"] = row.annual_avg_wkly_wage
        doc["annual_avg_estabs"] = row.annual_avg_estabs
        doc["annual_avg_emplvl"] = row.annual_avg_emplvl
        push!(counties_dict[i]["series"]["qcew"], doc)
    end
end