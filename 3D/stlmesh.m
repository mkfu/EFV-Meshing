function [  ] = stlmesh( filename,p,t,fa,fc,FaceCodes,Elements)
%% Write to file
fileID = fopen(filename,'w');

NDIME = 3;
NELEM = length(t);


fprintf(fileID,'NDIME= %i\n',int32(NDIME));
fprintf('NDIME= %d\n',int32(NDIME));

fprintf(fileID,'NELEM= %i\n',int32(NELEM));
fprintf('NELEM= %i\n',int32(NELEM));
%h = waitbar(0,'Writing El ements');

%Write the elements
N  = size(t);
N = N(1)-1;
for i = 1:NELEM;
%    waitbar(i/NELEM,h);
    fprintf(fileID,'10');
    for j = 1:N
         fprintf(fileID,'\t%i',int32(t(j,i)-1));
    end
    fprintf(fileID,'\t%i\n',int32(i-1));
end
%close(h);
NPOIN = length(p);
N  = size(p);
N = N(1);
%h = waitbar(0,'Writing Points');
fprintf(fileID,'NPOIN= %i\n',int32(NPOIN));
fprintf('NPOIN= %i\n',int32(NPOIN));
%Write the points
for i = 1:NPOIN;
%    waitbar(i/NPOIN,h);
    for j = 1:N
        fprintf(fileID,'\t%16.14e',p(j,i)-1);
    end
    fprintf(fileID,'\t%i\n',int32(i-1));
end
%close(h)

faces = 1:length(fc);
NMARK = 4;
fprintf(fileID,'NMARK= %i\n',int32(NMARK));
fprintf('NMARK= %i\n',int32(NMARK));
tags = {'cyl','in','out','wire'};

for i = 1:NMARK
    fprintf(fileID,'MARKER_TAG= %s\n',tags{i});
    fprintf('MARKER_TAG= %s\n',tags{i});
    markE = fa(:,fc(1,i):fc(2,i));;
    if i ==4
         markE=[fa(:,fc(1,4):fc(2,end));];
    end
    fprintf(fileID,'MARKER_ELEM= %i\n',int32(length(markE)));
    fprintf('MARKER_ELEM= %i\n',int32(length(markE)));
    for j = 1:length(markE)
        code = FaceCodes(markE(2,j),:)';
        tri = Elements(code,markE(1,j));
        fprintf(fileID,'5\t%i\t%i\t%i\n',int32(tri(1)-1),int32(tri(2)-1),int32(tri(3)-1));
    end
end


fclose(fileID);
end