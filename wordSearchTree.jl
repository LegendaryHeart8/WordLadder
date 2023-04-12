function emptyWordTree()
    return WordTreeNode(Array{Union{Nothing, WordTreeNode}}(nothing, 26), -1)
end

function generateWordTree(wordsArr)
    output = emptyWordTree()
    for i = 1:length(wordsArr)
        word = wordsArr[i]
        step = output
        for letter in word
            letterInd = Int(letter) - Int('a') + 1
            if isnothing(step.nextNodes[letterInd])
                step.nextNodes[letterInd] = emptyWordTree()
            end
            step = step.nextNodes[letterInd]
        end
        step.wordEnding = i
    end
    return output
end

function nextNodeChar(tree, letter)
    return tree.nextNodes[Int(letter) - Int('a') + 1]
end
