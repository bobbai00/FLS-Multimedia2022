function drawLineGraph(xLowerBound, xUpperBound, xInterval, yLowerBound, yUpperBound, yInterval, y1, y2, y1lable, y2lable, xlabelMsg, ylableMsg, G)
    x=xlowerBound:xInterval:xUpperBound;
    
    plot(x,y1,'-*k',x,y2,'-ok'); %线性，颜色，标记
    axis([0,xUpperBound,0,yUpperBound])  %确定x轴与y轴框图大小
    set(gca,'XTick',[0:xInterval:xUpperBound]) %x轴范围1-6，间隔1
    set(gca,'YTick',[0:yInterval:yUpperBound]) %y轴范围0-700，间隔100
    legend(y1lable, y2lable);   %右上角标注
    xlabel(xlabelMsg);
    ylabel(ylableMsg);
end


