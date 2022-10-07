function draw2Lines(figPrefix, xLowerBound, xUpperBound, xInterval, y1, y2)
    f1 = figure;
    x=xLowerBound:1:xUpperBound;
    
    plot(x,y1,'-*k', x, y2, '-or'); %线性，颜色，标记
    axis([0,xUpperBound,0,100])  %确定x轴与y轴框图大小
    set(gca,'XTick',0:xInterval:xUpperBound) %x轴范围1-6，间隔1
    set(gca,'YTick',0:10:100) %y轴范围0-700，间隔100
    legend("case1-20, m=1", "case2-20, m=1");   %右上角标注
    xlabel("rounds");
    ylabel("FLSs in clique of size G(G=20) (%)");
    
%     filename = sprintf("%s-%s.jpg", figPrefix, "line-PortionOfValidClique");
%     saveas(f1, filename);
end


