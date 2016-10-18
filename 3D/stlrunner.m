%%
model = createpde(1);
[stl,stlpath] = uigetfile('*.stl');
gm = importGeometry(model,strcat(stlpath,stl));
%h = pdegplot(model,'FaceLabels','on');
%h(1).FaceAlpha = 0.5;
m = generateMesh(model,'HMin',0.0001,'Hmax',.05,'GeometricOrder','linear');
%m = generateMesh(model,'GeometricOrder','linear');

h = pdemesh(m,'EdgeLabels','on');
h(1).FaceAlpha = 0.1;
m.MinElementSize;
[p,e,t] = meshToPet(m);
%% Write to file
filename = 'meshEFV.su2';
fileID = fopen(filename,'w');
fa =[];fb = [];
for i = 1:length(e.FaceAssociativity)
    fa = [fa,e.FaceAssociativity{i}];
    fb = [fb,length(e.FaceAssociativity{i})];
end
fb = cumsum(fb);fc = [1,fb(1:end-1);fb];
%tic
%stlmesh_mex(filename,p,t,fa,fc,e.FaceCodes,e.Elements)
%toc
tic
stlmesh(filename,p,t,fa,fc,e.FaceCodes,e.Elements)
toc