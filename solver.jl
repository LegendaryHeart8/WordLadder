#include neccary files
include("WordNodes.jl")
include("heap.jl")

#turn text into an accessible word (e.g. turning it into lowercase)
function sanatizeWord(text::String)::String
    return strip(lowercase(text))
end

#check if text only has lowercase letters
function isAtoZ(text)
    all(c -> 0x61 <= UInt8(c) <= 0x7A, text)
end
function isWord(text)
    global words
    low = sanatizeWord(text)
    #check if word only has letters
    if !isAtoZ(low)
        return false
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
        end
    end
    if l>length(words) || r< 1
        return false
    end
    midword = words[l]
    if midword == low
        foundWord = true
    end

    return foundWord
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

function astar(source, destination, metric::Function = wordDist)
    alphabet = "abcdefghijklmnopqrstuvwxyz"

    sou = sanatizeWord(source)
    dest = sanatizeWord(destination)

    closedDict = Dict{String, Union{Nothing, WordNode}}() # key is a word, value is the parent/travel-from
    openDict = Dict{String, Int}(sou => 1) # key is a word, value is the index in open heap of the word
    openHeap = Array{Union{WordNode, Nothing}, 1}([WordNode(sou, 0, metric(sou, dest), "")])
    function openHeapSwap(heap, a, b)
        openDict[heap[a].word] = b
        openDict[heap[b].word] = a
        heap[a], heap[b] = heap[b], heap[a]
    end
    lastOpen = 1

    hFunc(x) = metric(x, dest)
    getF(x::WordNode) = x.f
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
                if !isWord(Qword)
                    continue
                end
                Qg = 1 + q.g
                Qh = hFunc(Qword)
                Qf = Qg + Qh


                Q = WordNode(Qword, Qg, Qf, q.word)

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
function printPath(source::String, destination::String, closedDict::Dict{String, Union{Nothing, WordNode}})
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
sort!(words)
