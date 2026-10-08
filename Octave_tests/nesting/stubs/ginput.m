function [x,y]=ginput(n)
global CLICKS
x=CLICKS(1:n,1); y=CLICKS(1:n,2); CLICKS(1:n,:)=[];
