function weight = calculateWeight(graphVertexList,vertexList)
%CALCULATEWEIGHT 此处显示有关此函数的摘要
%   此处显示详细说明
indexList = [];


for i=1:size(graphVertexList, 2)
    indexList(i) = i;
end

CombOfIndex = combvec(indexList, indexList);

weight = 0.0;

for i=1:size(CombOfIndex, 2)
    u = graphVertexList(CombOfIndex(1, i));
    v = graphVertexList(CombOfIndex(2, i));
    weight = weight + u.distance(v, vertexList);
end

weight = weight / 2.0;

end

