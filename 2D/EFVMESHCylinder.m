%% Generate a mesh
clear all
clc
w = 1;
T = 150E-9/6E-6;
xmax = w*40;
ymax = w*40;
%pderect([-xmax xmax -ymax ymax],'R1')
%pderect([-xmax xmax -ymax ymax],'R2')
% Create a rectangle and two adjoining circles
R1 = [3 4 -xmax xmax xmax -xmax ymax ymax -ymax -ymax]';
C1 = [1 0.25 0 0.5 0 0 0 0 0 0]';
R2 = [3 4 -T/2 T/2 T/2 -T/2 w/2 w/2 -w/2 -w/2]';

cylinder = 0
if cylinder
    gd = [R1,C1];
    ns = char('R1','C1');ns = ns';
    sf = 'R1-C1';
    filename = 'meshEFV_cyl.su2';
else
    gd = [R1,R2];
    ns = char('R1','R2');ns = ns';
    sf = 'R1-R2';
    filename = 'meshEFV_wire.su2'
end
g = decsg(gd,sf,ns);
model = createpde;
geometryFromEdges(model,g);
fprintf('Create mesh \n')

m = generateMesh(model,'Hgrad',1.75,'Jiggle','on','JiggleIter',1);
[p,e,t] = meshToPet(m);
ntot =1;
for j = 1:ntot
    fprintf('Mesh refine iteration %d/%d\r',j,ntot)
    [p,e,t] = refinemesh(g,p,e,t);
    p = jigglemesh(p,e,t,'Opt','minimum');
end
fprintf('Display mesh \n')
pdemesh(p,e,t,'EdgeLabels','on')

%pdegplot(model,'EdgeLabels','on')
%axis([-2*T 2*T 0.4*w 0.6*w])
%close
%% Write to file
%filename = 'meshEFV.su2';
fileID = fopen(filename,'w');

NDIME = 2
NELEM = length(t)


fprintf(fileID,'NDIME= 2\n');
fprintf(fileID,'NELEM= %d\n',NELEM);

%h = waitbar(0,'Writing Elements');

%Write the elements
for i = 1:NELEM;
%    waitbar(i/NELEM,h);
    fprintf(fileID,'5\t%d\t%d\t%d\t%d\n',t(1,i)-1,t(2,i)-1,t(3,i)-1,i-1);
end
%close(h);
NPOIN = length(p)
%h = waitbar(0,'Writing Points');
fprintf(fileID,'NPOIN= %d\n',NPOIN);
%Write the points
for i = 1:NPOIN;
%    waitbar(i/NPOIN,h);
    fprintf(fileID,'\t%16.14e\t%16.14e\t%d\n',p(1,i)-1,p(2,i)-1,i-1);
end
%close(h)

edges = 2;%unique(e(5,:));
NMARK = 2%max(unique(e(5,:)))
fprintf(fileID,'NMARK= %d\n',NMARK);
tags = {'cylinder','farfield'};

for i = 1:NMARK
    if i ==2
        if cylinder
            mark = find(e(5,:)<5);
        else
            mark = find(e(5,:)==1|e(5,:)==2|e(5,:)==6|e(5,:)==7);
        end
    else
        if cylinder
            mark = find(e(5,:)>4);
            
        else
            mark = find(e(5,:)==3|e(5,:)==4|e(5,:)==5|e(5,:)==8);
        end
        
    end
    fprintf(fileID,'MARKER_TAG= %s\n',tags{i});
    fprintf('MARKER_TAG= %s\n',tags{i});
    fprintf(fileID,'MARKER_ELEM= %d\n',length(mark));
    fprintf('MARKER_ELEM= %d\n',length(mark));
    edata = [e(1,mark);e(2,mark)];
    for j= 1:length(mark)-1
        k = find(edata(1,:) == edata(2,j));
        temp =edata(:,j+1);
        edata(:,j+1) = edata(:,k);
        edata(:,k)  = temp;
    end
    length(edata);
    for j = 1:length(edata)
        fprintf(fileID,'3\t%d\t%d\n',edata(1,j)-1,edata(2,j)-1);
    end
end

cd_V = @(Re) (1.18+6.8./(Re).^(0.89)+1.96./(Re).^(0.5)-0.0004*(Re)./(1+3.64E-7*(Re).^2)).*(Re)/2; %DRAG COEFFICIENT FOR A CYLINDER
cd_I = @(Re)cd_V(Re)*2/Re;
Re = 1:10
cd_I(Re)
fclose(fileID)
