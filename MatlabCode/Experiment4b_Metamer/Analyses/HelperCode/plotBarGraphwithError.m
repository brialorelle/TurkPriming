
function plotBarGraphwithError(datamat,numSubs,varLabels,xlab,figureHandle)
figure(figureHandle);


blue = [153,204,255]./255;
turquoise=[0 190 105]./255;
red = [179,13,1]./255;
pink=[189,21,80]./255;
%
darkgreen=[0,102,0]./255
green = [120,169,92]./255;
darkpurple=[51,0,102]./255
magenta = [136,116,175]./255;
colors=[darkgreen; green; darkpurple; magenta;blue;turquoise;red;pink]

if size(datamat,2)==2
  colors=[blue; red]
end

h=gca;

set(h, 'FontName', 'Cambria','FontSize',12);


for i=1:size(datamat,2)
  h=bar(i,mean(datamat(:,i)))
  hold on
  set(h, 'FaceColor', colors(i,:))
end

hleg=legend(varLabels, 'Location', 'NorthEastOutside')
set(gca,'box','off')
set(gcf,'color','white')

se_condition=wsem(datamat)
errorbar(mean(datamat),se_condition,'blacko')
xlabel(xlab)

end