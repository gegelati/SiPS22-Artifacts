# Utility functions.
using CSV
using DataFrames
using Statistics
using Plots
using StatsPlots

function loadEntryFromCsv(path = String)
    # read from csv
    df = CSV.read(path, DataFrame, delim = ";")

    # Create entry for codegen                
    tpg_time = mean(df[:, :tpg_time])
    tpg_time_var = varm(df[:, :tpg_time], tpg_time)
    env_time = mean(df[:, :env_time])
    env_time_var = varm(df[:, :env_time], env_time)
    total_time = mean(df[:, :total_time])
    total_time_var = varm(df[:, :total_time], total_time)
    lost_time = mean(df[:, :total_time] - df[:, :tpg_time] - df[:, :env_time])
    score = df[1, :score]
    actions = df[1, :actions]

    # check unicity of score
    if (size(df[df.score.==df[1, :score], :])[2] != size(df)[2])
        throw(DomainError("Score is not identical for all runs. \n game=$game platform=$platform seed=$seed \n $df"))
    end

    # check unicity of action
    if (size(df[df.actions.==df[1, :actions], :])[2] != size(df)[2])
        throw(DomainError("Score is not identical for all runs. \n game=$game platform=$platform seed=$seed \n $df"))
    end

    return [score, actions, total_time, total_time_var, env_time, env_time_var, tpg_time, tpg_time_var, lost_time]
end

function loadDatabaseFromCsv()

    # Declare the databases
    databaseCodegen = DataFrame(game = String[], platform = String[], seed = Int64[],
        score = Int64[], actions = Int64[],
        total_time = Float64[], total_time_var = Float64[],
        env_time = Float64[], env_time_var = Float64[],
        tpg_time = Float64[], tpg_time_var = Float64[],
        lost_time = Float64[])
    # copy structure
    databaseTPG = similar(databaseCodegen, 0)

    # Fill the database
    for platform in platforms
        for game in games
            for seed in seeds
                entry = loadEntryFromCsv("$platform\\time.codegen.$game.$seed.log")
                push!(databaseCodegen, vcat([game, platform, seed], entry))

                entry = loadEntryFromCsv("$platform\\time.tpg.$game.$seed.log")
                push!(databaseTPG, vcat([game, platform, seed], entry))
            end
        end
    end

    return (databaseCodegen, databaseTPG)
end

# Function for loading graph stats from policyStats export
function loadTPGStats(path = String)
    file = open(path, "r")
    # Load complete file in a String (including newline)
    file_content = read(file, String)

    regex = r"\s*([0-9.]+)\n";

    m = match(r"Teams:"*regex, file_content)
    nbTeams = parse(Int64, m.captures[1])

    m = match(r"Edges:"*regex, file_content)
    nbEdges = parse(Int64, m.captures[1])

    m = match(r"Programs:"*regex, file_content)
    nbPrograms = parse(Int64, m.captures[1])

    m = match(r"Line/prog:"*regex, file_content)
    nbLinesPerProg = parse(Float64, m.captures[1])

    return [nbTeams, nbEdges, nbPrograms, nbLinesPerProg]

end

function loadProfilingStats(path = String)
    file = open(path, "r")
    # Load complete file in a String (including newline)
    file_content = read(file, String)

    regex = r"\s*([0-9.]+)\n";

    m = match(r"Nb teams executed:"*regex, file_content)
    nbTeamsExec = parse(Int64, m.captures[1])

    m = match(r"Nb progs executed:"*regex, file_content)
    nbProgsExec = parse(Int64, m.captures[1])

    return [nbTeamsExec, nbProgsExec]

end

function loadTPGStatsDatabase()
    # Declare the databases
    databaseTPGStats = DataFrame(game = String[], seed = Int64[], nbTeams = Int64[], nbEdges=Int64[], nbPrograms=Int64[], linePerProgram = Float64[], nbTeamExec = Int64[], nbProgExec= Int64[])

       # Parse the files
    for game in games
        for seed in seeds
            TPGStats = loadTPGStats("trainingResults\\out_best_stats_cleaned.$game.$seed.t48.md")
            execStats = loadProfilingStats("trainingResults\\stats.codegen.$game.$seed.log")
            push!(databaseTPGStats, vcat([game, seed], TPGStats, execStats))
        end
    end

    return databaseTPGStats
end


# Utility function
function computeSpeedups(dbCodegen = DataFrame, dbTPG = DataFrame)
    # Compute Avg Speed up per game per platform
    dbSpeedup = DataFrame(game = String[], platform = String[],
        avgSpeedup = Float64[], medianSpeedup = Float64[], maxSpeedup = Float64[], minSpeedup = Float64[])

    for platform in platforms
        for game in games
            entriesCodegen = dbCodegen[(dbCodegen.game.==game).&(dbCodegen.platform.==platform), :]
            entriesTPG = dbTPG[(dbTPG.game.==game).&(dbTPG.platform.==platform), :]

            speedups = entriesTPG[:, :tpg_time] ./ entriesCodegen[:, :tpg_time]
            speedup_stat = [game, platform, mean(speedups), median(speedups), maximum(speedups), minimum(speedups)]

            push!(dbSpeedup, speedup_stat)

        end
    end
    return dbSpeedup
end