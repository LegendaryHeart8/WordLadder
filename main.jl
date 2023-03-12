println("Loading...")
include("solver.jl")

function solveLadder()
    #ask for words
    print("Give a source word:\n")
    source = sanatizeWord(readline())
    if !isWord(source)
        println("$source is not a word")
        return
    end

    print("Where to go from $source?\n")
    destination = sanatizeWord(readline())
    if !isWord(destination)
        println("$destination is not a word")
        return
    end

    #validate words
    if length(source) != length(destination)
        println("Source and destination words are not the same length.")
        return
    end

    println("Do you want to the shortest solution? Or do you want a quick solution? \n 1) shortest \n 2) quick")
    opt = readline()
    if opt != "1" && opt != "2"
        println("$opt is not an option.")
        return
    end
    #find path
    println("Okay finding a solution")
    if opt == "1"
        closedDict = dijkstra(source, destination)
    else
        closedDict = astar(source, destination)
    end
    println("Here's the ladder: ")
    printPath(source,destination, closedDict)
end

function compare()
    #ask for words
    print("Give a source word:\n")
    source = sanatizeWord(readline())
    if !isWord(source)
        println("$source is not a word")
        return
    end

    print("Where to go from $source?\n")
    destination = sanatizeWord(readline())
    if !isWord(destination)
        println("$destination is not a word")
        return
    end

    #validate words
    if length(source) != length(destination)
        println("Source and destination words are not the same length.")
        return
    end

    #find path
    println("A* algorithm (String identifiers): ")
    @time closedDictAS = astar(source, destination)
    println("A* algorithm (Integer identifiers): ")
    @time closedDictAI = astar(findWord(source), findWord(destination))
    println("Dijkstra: ")
    @time closedDictAI = dijkstra(source, destination)
end

closedDict = Dict()

asking = true
while asking
    #ask if the user wants to solve
    print("\nWhat would like to do? \n 1) solve a word ladder \n 2) compare algorithms\n 3) exit\n")
    solve = strip(readline())
    if solve == "1"
        solveLadder()
    elseif solve == "2"
        compare()
    elseif solve == "3"
        println("Okay, good bye.")
        asking = false
        break
    else
        println("$solve is not an option. Enter a number.")
        continue
    end


end

print("Program end.")
