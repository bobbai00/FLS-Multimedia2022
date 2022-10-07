function drawWeightHistFor2CliqueSize(figPrefix, weightOf2, weightOf3) 
    figure3 = figure;

    subplot(1, 2, 1)
    h1 = histogram(weightOf2);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('2-Clique')


    subplot(1, 2, 2)
    h2 = histogram(weightOf3);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('3-Clique')

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-WeightFor2CliqueSize");
    saveas(figure3, filename);
end