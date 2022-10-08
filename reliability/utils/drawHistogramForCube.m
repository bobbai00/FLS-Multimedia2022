function h = drawHistogramForCube(data)

h = histogram(data);
xlabel('cube cardinality')
ylabel('number of cubes')
title("Histogram of Cubes' Cardinality")

% Obtain the handle of the figure that contains the histogram
handleOfHistogramFigure = ancestor(h, 'figure');
% Make the figure window visible in case it was invisible before
handleOfHistogramFigure.Visible  = 'on'
% Bring the figure window to the front
figure(handleOfHistogramFigure);
end