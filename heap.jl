
function parentHeap(ind::Int)
    return ind ÷ 2
end

function leftHeap(ind::Int)
    return 2*ind
end

function rightHeap(ind::Int)
    return 2*ind+1
end
function peakHeap(heap)
    return heap[1]
end
function isEmptyHeap(heap)
    return !hasValueHeap(heap, 1)
end
function swapHeap!(heap, ind1::Int, ind2::Int)
    heap[ind1], heap[ind2] = heap[ind2], heap[ind1]
end
function popHeap!(heap, valueMap::Function = identity, swap::Function = swapHeap!, lastInd::Int = -1, minheap::Bool = true)
    returnValue = heap[1]
    #set top of heap to the last value
    li = lastInd
    if li == -1
        li = getLastInd(heap)
    end
    heap[1] = heap[li]
    heap[li] = nothing
    if heap[1] == nothing
        return returnValue
    end
    repairDownHeap!(heap, 1, valueMap, swap, minheap)
    return returnValue
end
function pushHeap!(heap, pushValue, valueMap::Function = identity, swap::Function = swapHeap!, lastInd::Int = -1, minheap::Bool = true)
    li = lastInd
    if li == -1
        li = getLastInd(heap)
    end
    heap[li+1] = pushValue
    repairUpHeap!(heap, li+1, valueMap, swap, minheap)
end
function repairUpHeap!(heap, incoorInd::Int,valueMap::Function = identity, swap::Function = swapHeap!,minheap::Bool = true)
    #repair heap
    incorrect = incoorInd
    incorrectValue = valueMap(heap[incorrect])
    unrepaired = true
    while unrepaired
        parentInd = parentHeap(incorrect)
        if !hasValueHeap(heap, parentInd)
            unrepaired = false
            break
        end
        parentValue = valueMap(heap[parentInd])
        if (parentValue > incorrectValue) == minheap
            #swap incorrect with parent
            swap(heap, incorrect, parentInd)
            incorrect= parentInd
        else
            unrepaired = false
            break
        end
    end
end
function repairDownHeap!(heap, incoorInd::Int,valueMap::Function = identity, swap::Function = swapHeap!,minheap::Bool = true)
    #repair heap
    incorrect = incoorInd
    incorrectValue = valueMap(heap[incorrect])
    unrepaired = true
    while unrepaired
        leftInd = leftHeap(incorrect)
        if !hasValueHeap(heap, leftInd)
            #if no children
            unrepaired = false
            break
        end
        #get lesser child
        leftValue = valueMap(heap[leftInd])
        smallerInd = leftInd
        smallerValue = leftValue

        rightInd = rightHeap(incorrect)
        if hasValueHeap(heap, rightInd)
            rightValue = valueMap(heap[rightInd])
            if (rightValue < leftValue) == minheap
                smallerInd = rightInd
                smallerValue = rightValue
            end
        end
        #check if the child value is greater than the incorrect
        if (smallerValue > incorrectValue) == minheap
            unrepaired = false
            break
        end
        #swap incorrect with lesser
        swap(heap, incorrect, smallerInd)
        incorrect= smallerInd
    end
end
function searchHeap(heap, searching, beginning::Int = 1, equalityCheck::Function=isequal, valueMap::Function = identity, minheap::Bool = true)::Int
    #depth first search
    if !hasValueHeap(heap, beginning)
        return -1
    end
    #check if found what is search for here
    if equalityCheck(heap[beginning], searching)
        return beginning
    end
    searchValue = valueMap(searching)
    #search left
    leftInd = leftHeap(beginning)
    if hasValueHeap(heap, leftInd)
        leftValue = valueMap(heap[leftInd])
        if (leftValue < searchValue) == minheap || leftValue == searchValue
            ind = searchHeap(heap, searching, leftInd, equalityCheck, valueMap, minheap)
            if ind != -1 # if found search value
                return ind
            end
        end
    end
    #search rights
    rightInd = rightHeap(beginning)
    if hasValueHeap(heap, rightInd)
        rightValue = valueMap(heap[rightInd])
        if (rightValue < searchValue) == minheap || rightValue == searchValue
            ind = searchHeap(heap, searching, rightInd, equalityCheck, valueMap, minheap)
            return ind
        end
    end
    #found nothing
    return -1
end
function hasValueHeap(heap, ind::Int)
    if ind < 1
        return false
    end
    if ind > length(heap)
        return false
    end
    if heap[ind] == nothing
        return false
    end
    return true
end
function getLastInd(heap)
    for i = 1:length(heap)
        j = length(heap) - i + 1
        if heap[j] != nothing
            return j
        end
    end
    return 0
end
