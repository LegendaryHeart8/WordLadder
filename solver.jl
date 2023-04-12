#include neccary files
include("WordNodes.jl")
include("heap.jl")
include("wordSearchTree.jl")

#turn text into an accessible word (e.g. turning it into lowercase)
function sanatizeWord(text::String)::String
    return strip(lowercase(text))
end

#check if text only has lowercase letters
function isAtoZ(text)
    all(c -> 0x61 <= UInt8(c) <= 0x7A, text)
end
#gets a word from the word's index
function getWord(ind)
    global words
    return words[ind]
end
function findWordTree(text)
    global wordTree, alphabet, indLetterDict
    search = wordTree
    for l in text
        lInd = Int(l) - Int('a') + 1
        search = search.nextNodes[lInd]
        if isnothing(search)
            return -1
        end
    end
    return search.wordEnding
end
"""
    findWordNext(text)

Returns the index of word in the global words array using the findnext base function.
If the word does not exist in the array then -1 is returned.
"""
function findWordNext(text)
    f(x) = x == text
    ind = findnext(f, words, 1)
    if isnothing(ind)
        return -1
    end
    return ind
end
"""
    findWordLinear(text)

Returns the index of word in the global words array using a linear search.
If the word does not exist in the array then -1 is returned.
"""
function findWordLinear(text)
    for i = 1:length(words)
        if text == words[i]
            return i
        end
    end
    return -1
end
"""
    findWordDict(text)

Returns the index of word in the global words array using the hashtable wordDict.
If the word does not exist in the array then -1 is returned.
"""
function findWordDict(text)
    if haskey(wordDict, text)
        return wordDict[text]
    else
        return -1
    end
end
"""
    findWord(text)

Returns the index of word in the global words array using a binary search.
If the word does not exist in the array then -1 is returned.
"""
function findWord(text)
    global words
    low = sanatizeWord(text)
    #check if word only has letters
    if !isAtoZ(low)
        return -1
    end
    #find text in words list
    l = 1
    r = length(words)
    foundWord = false
    while l < r && !foundWord
        mid = cld(l+r, 2)
        midword = words[mid]
        if low < midword
            r= mid-1
        elseif midword < low
            l = mid + 1
        else
            foundWord = true
            l = mid
        end
    end
    if l>length(words) || r< 1
        return -1
    end
    #println("Words left: $(words[l]) : $l, right $(words[r]) : $r")
    midword = words[l]
    if midword == low
        return l
    end

    return -1
end
function isWord(text)
    return findWord(text) != -1
end
function isWordDict(text)
    return findWordDict(text) != -1
end
function wordDist(a::String, b::String)::Int
    dist = 0
    for i = 1:length(a)
        if a[i] != b[i]
            dist += 1
        end
    end
    return dist
end
function dijkstra(source::String, destination::String, isWordTest::Function = isWord)
    zero(a, b) = 0
    astar(source, destination, zero, isWordTest)
end
function astarTree(source::String, destination::String, metric::Function = wordDist)
    alphabet = "abcdefghijklmnopqrstuvwxyz"

    sou = sanatizeWord(source)
    dest = sanatizeWord(destination)

    closedDict = Dict{String, Union{Nothing, WordNodeS}}() # key is a word, value is the parent/travel-from
    openDict = Dict{String, Int}(sou => 1) # key is a word, value is the index in open heap of the word
    openHeap = Array{Union{WordNodeS, Nothing}, 1}([WordNodeS(sou, 0, metric(sou, dest), "")])
    function openHeapSwap(heap, a, b)
        openDict[heap[a].word] = b
        openDict[heap[b].word] = a
        heap[a], heap[b] = heap[b], heap[a]
    end
    lastOpen = 1

    hFunc(x) = metric(x, dest)
    getF(x::WordNodeS) = x.f


    foundDestination = false
    while (!isEmptyHeap(openHeap)) && !foundDestination
        # get next looking word
        q = popHeap!(openHeap, getF, openHeapSwap, lastOpen) #word looking at
        lastOpen -= 1
        searchedTree = wordTree
        #iterate through successive words
        for i = 1:length(q.word) #iterate through each place to replace a character
            Qword = q.word # Q is the successor
            for letter in alphabet
                if letter == q.word[i] # if didn't make new word
                    continue
                end

                Qword = Qword[1:i-1] * letter * Qword[i+1:length(Qword)]
                #check if Qword is a word
                isWordQ = true
                search = searchedTree
                for j = i:length(Qword)
                    lInd = Int(Qword[j]) - Int('a') + 1
                    search = search.nextNodes[lInd]
                    if isnothing(search)
                        isWordQ = false
                        break
                    end
                end
                if !isnothing(search) && search.wordEnding != -1 && getWord(search.wordEnding) != Qword
                    @warn "Qword, $(Qword), doesn't match found word $(getWord(search.wordEnding)) at $(search.wordEnding)"
                end
                isWordQ = isWordQ && !isnothing(search) && search.wordEnding != -1

                if !isWordQ
                    continue
                end
                Qg = 1 + q.g
                Qh = hFunc(Qword)
                Qf = Qg + Qh


                Q = WordNodeS(Qword, Qg, Qf, q.word)

                if Qword == dest
                    foundDestination = true
                    closedDict[Qword] =  Q # place on closed dict
                    break
                end
                sameWord(a,b)=(a.word==b.word)
                open = -1
                if haskey(openDict, Qword)
                    open = openDict[Qword]#searchHeap(openHeap, Q, 1, sameWord, fFunc)
                end
                if open != -1 && openHeap[open] != nothing
                    if openHeap[open].f > Qf
                        #replace in open heap
                        openHeap[open].g = Q.g
                        openHeap[open].from = Q.from
                    end
                    continue # skip successor
                end
                if haskey(closedDict, Qword)
                    if closedDict[Qword].g <= Qg
                        continue # skip successor
                    end
                end
                #add successor onto open list
                if lastOpen+1>length(openHeap) # if the capacity of the heap is no enough
                    append!(openHeap, [nothing for i = 1:length(openHeap)]) # double the potential capacity
                end
                openDict[Qword] = lastOpen + 1
                pushHeap!(openHeap, Q, getF, openHeapSwap, lastOpen)
                lastOpen += 1
            end
            if foundDestination
                break
            end
            searchedTree = nextNodeChar(searchedTree, q.word[i])
        end

        # set word to closed
        closedDict[q.word] = q
        openDict[q.word] = -1
    end
    return closedDict
end
function astar(source::String, destination::String, metric::Function = wordDist, isWordTest::Function = isWord)
    alphabet = "abcdefghijklmnopqrstuvwxyz"

    sou = sanatizeWord(source)
    dest = sanatizeWord(destination)

    closedDict = Dict{String, Union{Nothing, WordNodeS}}() # key is a word, value is the parent/travel-from
    openDict = Dict{String, Int}(sou => 1) # key is a word, value is the index in open heap of the word
    openHeap = Array{Union{WordNodeS, Nothing}, 1}([WordNodeS(sou, 0, metric(sou, dest), "")])
    function openHeapSwap(heap, a, b)
        openDict[heap[a].word] = b
        openDict[heap[b].word] = a
        heap[a], heap[b] = heap[b], heap[a]
    end
    lastOpen = 1

    hFunc(x) = metric(x, dest)
    getF(x::WordNodeS) = x.f
    #fFunc(x::WordNode) = hFunc(x.word) + x.g
    foundDestination = false
    while (!isEmptyHeap(openHeap)) && !foundDestination
        # get next looking word
        q = popHeap!(openHeap, getF, openHeapSwap, lastOpen) #word looking at
        lastOpen -= 1
        #iterate through successive words
        for i = 1:length(q.word)
            Qword = q.word # Q is the successor
            for letter in alphabet
                if letter == q.word[i] # if didn't make new word
                    continue
                end

                Qword = Qword[1:i-1] * letter * Qword[i+1:length(Qword)]
                if !isWordTest(Qword)
                    continue
                end
                Qg = 1 + q.g
                Qh = hFunc(Qword)
                Qf = Qg + Qh


                Q = WordNodeS(Qword, Qg, Qf, q.word)

                if Qword == dest
                    foundDestination = true
                    closedDict[Qword] =  Q # place on closed dict
                    break
                end
                sameWord(a,b)=(a.word==b.word)
                open = -1
                if haskey(openDict, Qword)
                    open = openDict[Qword]#searchHeap(openHeap, Q, 1, sameWord, fFunc)
                end
                if open != -1 && openHeap[open] != nothing
                    if openHeap[open].f > Qf
                        #replace in open heap
                        openHeap[open].g = Q.g
                        openHeap[open].from = Q.from
                    end
                    continue # skip successor
                end
                if haskey(closedDict, Qword)
                    if closedDict[Qword].g <= Qg
                        continue # skip successor
                    end
                end
                #add successor onto open list
                if lastOpen+1>length(openHeap) # if the capacity of the heap is no enough
                    append!(openHeap, [nothing for i = 1:length(openHeap)]) # double the potential capacity
                end
                openDict[Qword] = lastOpen + 1
                pushHeap!(openHeap, Q, getF, openHeapSwap, lastOpen)
                lastOpen += 1
            end
            if foundDestination
                break
            end
        end

        # set word to closed
        closedDict[q.word] = q
        openDict[q.word] = -1
    end
    return closedDict
end
function astar(source::Int, destination::Int, metric::Function = wordDist)
    alphabet = "abcdefghijklmnopqrstuvwxyz"

    souInd = source
    destInd = destination

    sou = getWord(souInd)
    dest = getWord(destInd)

    closedDict = Dict{Int, Union{Nothing, WordNodeI}}() # key is a word, value is the parent/travel-from
    openDict = Dict{Int, Int}(souInd => 1) # key is a word, value is the index in open heap of the word
    openHeap = Array{Union{WordNodeI, Nothing}, 1}([WordNodeI(souInd, 0, metric(sou, dest), -1)])
    function openHeapSwap(heap, a, b)
        openDict[heap[a].word] = b
        openDict[heap[b].word] = a
        heap[a], heap[b] = heap[b], heap[a]
    end
    lastOpen = 1

    hFunc(x) = metric(x, dest)
    getF(x::WordNodeI) = x.f
    foundDestination = false
    while (!isEmptyHeap(openHeap)) && !foundDestination
        # get next looking word
        q = popHeap!(openHeap, getF, openHeapSwap, lastOpen) #word looking at
        lastOpen -= 1
        qWordTxt = getWord(q.word)
        #iterate through successive words
        for i = 1:length(qWordTxt)
            Qword = qWordTxt # Q is the successor
            for letter in alphabet
                if letter == qWordTxt[i] # if didn't make new word
                    continue
                end
                Qword = Qword[1:i-1] * letter * Qword[i+1:length(Qword)]
                QWordInd = findWord(Qword)
                if QWordInd == -1
                    continue
                end
                Qg = 1 + q.g
                Qh = hFunc(Qword)
                Qf = Qg + Qh


                Q = WordNodeI(QWordInd, Qg, Qf, q.word)

                if Qword == dest
                    foundDestination = true
                    closedDict[QWordInd] =  Q # place on closed dict
                    break
                end

                open = -1
                if haskey(openDict, QWordInd)
                    open = openDict[QWordInd]
                end
                if open != -1 && openHeap[open] != nothing
                    if openHeap[open].f > Qf
                        #replace in open heap
                        openHeap[open].g = Q.g
                        openHeap[open].from = Q.from
                    end
                    continue # skip successor
                end
                if haskey(closedDict, QWordInd)
                    if closedDict[QWordInd].g <= Qg
                        continue # skip successor
                    end
                end
                #add successor onto open list
                if lastOpen+1>length(openHeap) # if the capacity of the heap is no enough
                    append!(openHeap, [nothing for i = 1:length(openHeap)]) # double the potential capacity
                end
                openDict[QWordInd] = lastOpen + 1
                pushHeap!(openHeap, Q, getF, openHeapSwap, lastOpen)
                lastOpen += 1
            end
            if foundDestination
                break
            end
        end

        # set word to closed
        closedDict[q.word] = q
        openDict[q.word] = -1
    end
    return closedDict
end
function printPath(source::String, destination::String, closedDict::Dict{Int, Union{Nothing, WordNodeI}})
    sou = sanatizeWord(source)
    dest = sanatizeWord(destination)

    souInd = findWord(sou)
    destInd = findWord(dest)
    if !haskey(closedDict, destInd)
        println("No path found between $source and $(destination)!")
        return
    end
    #print path
    wordOn = destInd
    while wordOn != souInd
        println(getWord(wordOn))
        wordOn = closedDict[wordOn].from
    end
    println(sou)
end
function printPath(source::String, destination::String, closedDict::Dict{String, Union{Nothing, WordNodeS}})
    sou = sanatizeWord(source)
    dest = sanatizeWord(destination)
    if !haskey(closedDict, dest)
        println("No path found between $source and $(destination)!")
        return
    end
    #print path
    wordOn = dest
    while wordOn != sou
        println(wordOn)
        wordOn = closedDict[wordOn].from
    end
    println(sou)
end

# get words
wordFileName = joinpath(dirname(Base.source_path()), "EnglishWords/words.txt")
f = open(wordFileName, "r")
words= readlines(f)
close(f)
words = sanatizeWord.(words)
words = [word for word in words if all(isAtoZ, word)]
sort!(words)
#put words in dictionary
wordDict = Dict([(words[i],i) for i = 1:length(words)])
#put words in tree
wordTree= generateWordTree(words)
