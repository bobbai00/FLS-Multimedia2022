function drawWeightHistFor4CliqueSize(figPrefix, weightOf2, weightOf3, weightOf4, wieghtOf5) 
    figure3 = figure;

    subplot(1, 4, 1)
    h1 = histogram(weightOf2);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('2-Clique')


    subplot(1, 4, 2)
    h2 = histogram(weightOf3);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('3-Clique')

    subplot(1, 4, 3)
    h2 = histogram(weightOf4);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('4-Clique')

    subplot(1, 4, 4)
    h2 = histogram(wieghtOf5);
    xlabel('weight of edges')
    ylabel('number of cliques')
    title('5-Clique')

    filename = sprintf("%s-%s.jpg", figPrefix, "hist-WeightFor4CliqueSize");
    saveas(figure3, filename);
end