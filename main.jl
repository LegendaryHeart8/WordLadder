println("Loading...")
include("solver.jl")

closedDict = Dict()

asking = true
while asking
    #ask if the user wants to solve
    print("\nWould you like to solve a word ladder? (y/n)\n")
    solve = lowercase(readline())
    if solve == "n"
        println("Okay, good bye.")
        asking = false
        break
    elseif solve != "y"
        println("$solve is not y or n.")
        continue
    end

    #ask for words
    print("Give a source word:\n")
    source = sanatizeWord(readline())
    if !isWord(source)
        println("$source is not a word")
        continue
    end

    print("Where to go from $source?\n")
    destination = sanatizeWord(readline())
    if !isWord(destination)
        println("$destination is not a word")
        continue
    end

    #validate words
    if length(source) != length(destination)
        println("Source and destination words are not the same length.")
        continue
    end

    #find path
    println("Okay finding a solution")
    closedDict = astar(source, destination)
    println("Here's the ladder: ")
    printPath(source,destination, closedDict)
end

print("Program end.")
