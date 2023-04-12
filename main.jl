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
        closedDict = dijkstra(source, destination, isWordDict)
    else
        closedDict = astar(source, destination, wordDist, isWordDict)
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
    println("A* algorithm (String identifiers, binary search): ")
    @time closedDictAS = astar(source, destination)
    println("A* algorithm (Integer identifiers): ")
    @time closedDictAI = astar(findWord(source), findWord(destination))
    println("A* algorithm (String identifiers, hashtable)")
    @time closedDictASH = astar(source, destination, wordDist, isWordDict)
    println("A* algorithm (String identifiers, tree search)")
    @time closedDictAST = astarTree(source, destination)
    println("Dijkstra (hashtable): ")
    @time closedDictAI = dijkstra(source, destination, isWordDict)
end
function meanWordFinds()
    #ask the number of words to search for
    println("How many words should be searched for? (in thousands)")
    totalWords=1
    try
        totalWords = Int32(parse(Float64, readline())*1000)
    catch
        println("Please enter a number next time.")
    end
    #ask if to include linear searches as apart of the comparison
    println("Should the linear search functions also be compared? (WARNING: they are very slow) [Y/N]")
    inAns = uppercase(readline())
    if inAns != "Y" && inAns != "N"
        println("Y/N was not given so N will be assumed to have been chosen.")
    end
    includeLinear = inAns == "Y"
    #generate an array of random words
    randWords = [words[rand(1:length(words))] for i = 1:totalWords]
    #find time it takes to seach for words
    nextTime = 1
    linTime = 1
    if includeLinear
        nextTime = @elapsed findWordNext.(randWords)
        linTime = @elapsed findWordLinear.(randWords)
    end
    binTime = @elapsed findWord.(randWords)
    treeTime = @elapsed findWordTree.(randWords)
    hashTime = @elapsed findWordDict.(randWords)
    #calculate the number of words per second
    if includeLinear
        nextWPS = totalWords/nextTime
        linWPS = totalWords/linTime
    end
    binWPS = totalWords/binTime
    treeWPS = totalWords/treeTime
    hashWPS = totalWords/hashTime
    #print results
    if includeLinear
        println("Find next search can find $(round(nextWPS)) words per second")
        println("Linear search can find $(round(linWPS)) words per second")
    end
    println("Binary search can find $(round(binWPS)) words per second")
    println("Tree search can find $(round(treeWPS)) words per second")
    println("Hashtable can find $(round(hashWPS)) words per second")
end
closedDict = Dict()

asking = true
while asking
    #ask if the user wants to solve
    print("\nWhat would like to do? \n 1) solve a word ladder \n 2) compare algorithms\n 3) compare word searches \n 4) exit\n")
    solve = strip(readline())
    if solve == "1"
        solveLadder()
    elseif solve == "2"
        compare()
    elseif solve == "3"
        meanWordFinds()
    elseif solve == "4"
        println("Okay, good bye.")
        asking = false
        break
    else
        println("$solve is not an option. Enter a number.")
        continue
    end


end

print("Program end.")
