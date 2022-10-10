function h = drawHistogramForCube(data, pointCloudName, T)
t = sprintf("%s.T=%d", pointCloudName, T);


path = "/Users/baijiadong/Desktop/shaharam-lab/FLS-Multimedia2022/hist";
filePath = sprintf("%s/%s.jpg", path, t);

figure1 = figure;

h = histogram(data);
xlabel('cube cardinality')
ylabel('number of cubes')
title("Histogram of Cubes' Cardinality")

saveas(figure1, filePath);
end