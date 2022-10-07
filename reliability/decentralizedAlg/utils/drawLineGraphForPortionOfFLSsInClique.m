function drawLineGraphForPortionOfFLSsInClique(figPrefix, xLowerBound, xUpperBound, xInterval, y1)
    f1 = figure;
    x=xLowerBound:1:xUpperBound;
    
    plot(x,y1,'-*k'); %线性，颜色，标记
    axis([0,xUpperBound,0,100])  %确定x轴与y轴框图大小
    set(gca,'XTick',0:xInterval:xUpperBound) %x轴范围1-6，间隔1
    set(gca,'YTick',0:10:100) %y轴范围0-700，间隔100
    legend("");   %右上角标注
    xlabel("rounds");
    ylabel("FLSs in clique of size G (%)");
    
    filename = sprintf("%s-%s.jpg", figPrefix, "line-PortionOfValidClique");
    saveas(f1, filename);
end


