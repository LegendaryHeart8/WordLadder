mutable struct WordNodeS
    word::String
    g::Number
    f::Number
    from::String
end

mutable struct WordNodeI
    word::Int
    g::Number
    f::Number
    from::Int
end

mutable struct WordTreeNode
    nextNodes::Array
    wordEnding::Int
end
