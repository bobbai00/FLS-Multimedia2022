function drawHistogramForNumFLS(figPrefix, firstRound, midRound, LastRound)
    figure2 = figure;

    subplot(1, 3, 1)
    h1 = histogram(firstRound);
    % xlabel('number of FLSs in each single clique')
    ylabel('number of cliques')
    title('First Round')


    subplot(1, 3, 2)
    h2 = histogram(midRound);
    xlabel('number of FLSs in each clique')
    % ylabel('number of cliques')
    title('Middle Round')

    subplot(1, 3, 3)
    h3 = histogram(LastRound);
    % xlabel('number of FLSs in each single clique')
    % ylabel('number of cliques')
    title('Last Round')
    
    filename = sprintf("%s-%s.jpg", figPrefix, "hist-NumFlsChange");
    saveas(figure2, filename);
end