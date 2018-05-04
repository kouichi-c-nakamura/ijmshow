function imp = ijmshow(I,varargin)
% ijmshow is a wrapper of IJM.show() or
% net.imagej.matlab.ImageJMATLABCommands.show() and allow you to open an
% array I with an instance of ImageJ within MATLAB with a proper
% data type and hyperstack dimensions.
%
%
% SYNTAX
% imp = ijmshow(I)
% imp = ijmshow(I,dimorder)
% imp = ijmshow(____,'Param',value)
% 
%
% REQUIREMENTS
% ImageJ-MATLAB as part of Fiji installation
% https://imagej.net/MATLAB_Scripting
%
% ijmshow assumes a net.imagej.matlab.ImageJMATLABCommands Java object
% named 'IJM' is made available in the base Workspace by ImageJ (part of
% ImageJ-MATLAB).
%
%
% INPUT ARGUMENTS
% I           uint16 | uint8 | double | single
%             An array of integers to be opened with ImageJ. This array can
%             have from 2 to 5 dimensions.
%
%
% dimorder    char row vector made of 'XYCZT' | 'YXCZT' (default)
%
%             (Optional) A char row vector composed of 'X', 'Y', 'C' for
%             channels, 'Z' for slices, and 'T' for frames. dimorder is
%             case insensitive. You cannot repeat any of the five letters
%             in dimorder. The first two letters must be either 'X' or 'Y'.
%             The length of dimorder must be 5 or match the number of
%             dimensions of the array specified by I. The third to the
%             fifth letters must be chosen from 'C', 'Z', and 'T'.
%
%             The default is set 'YXCZT' rather than 'XYZCT', because the X
%             and Y axes of an MATLAB array is flipped over in ImageJ by
%             IJM.show().
%
%
% OPTIONAL PARAMETER/VALUE PAIRS
% NewName     char row vector | '' (default)
%             The window title of the new image in ImageJ
%
% FrameInterval
%             scalar
%             Time frame sampling interval in seconds
%
% OUTPUT ARGUMENTS
% imp         ij.ImagePlus Java object
%
% EXAMPLES
% see https://github.com/kouichi-c-nakamura/ijmshow
%
%
% Written by Kouichi C. Nakamura Ph.D.
% MRC Brain Network Dynamics Unit
% University of Oxford
% kouichi.c.nakamura@gmail.com
% 03-May-2018 04:57:24
%
% See also
% https://github.com/kouichi-c-nakamura/ijmshow (repository for this function)
% ImageJ as part of ImageJ-MATLAB (https://github.com/imagej/imagej-matlab/)
% net.imagej.matlab.ImageJMATLABCommands
% evalin, assignin
% https://imagej.net/MATLAB_Scripting


assert(evalin('base','exist(''IJM'',''var'')') == 1,....
    ['The variable IJM does not exist in the base Workspace. ',...
    'If you have Fiji installed, then activate ImageJ-MATLAB and then ',...
    'use "addpath" to include the scripts folder in the Fiji and then run "ImageJ"'])

assert(evalin('base','strcmp(class(IJM) ,''net.imagej.matlab.ImageJMATLABCommands'')'),....
    'The variable IJM is not a net.imagej.matlab.ImageJMATLABCommands Java object')

p = inputParser;
p.addRequired('I',@(x) isnumeric(x));
p.addOptional('dimorder','YXCZT',@(x) ischar(x) && isrow(x) ...
    && all(arrayfun(@(y) ismember(y,'XYCZT'),upper(x))) && length(x) >=2 ...
    && all(arrayfun(@(y) ismember(y,'XY'),upper(x(1:2))))...
    );
p.addParameter('NewName','',@(x) ischar(x) && isrow(x));
p.addParameter('FrameInterval',[],@(x) isreal(x) && x > 0);

p.parse(I,varargin{:});

dimorder = upper(p.Results.dimorder);
newname = p.Results.NewName;
frameinterval = p.Results.FrameInterval;


if length(dimorder) ~=5
    
   assert(ndims(I) == length(dimorder))
    
end

assert(ndims(I) >= 2,'"I" must have at least 2 dimensions')
assert(ndims(I) <= 5,'"I" cannot have more than 5 dimensions')

%% Job
eval('import ij.IJ')

if string(dimorder(1:2)) == "YX"

    I = permute(I,[2 1 3:ndims(I)]);
    
end

assignin('base','I____temp',I)
evalin('base','IJM.show(''I____temp'')')
evalin('base','clear I____temp')

nX = size(I,2);
nY = size(I,1);
nC = size(I,3);
nZ = size(I,4);
nT = size(I,5);
bitdepth = class(I);

IMP = IJ.getImage();

IMP.isHyperStack;
st = IMP.getStack;
IMP.hide();


switch bitdepth
    case 'uint16'
        imp = IJ.createHyperStack(newname, nY,nX,nC,nZ,nT, 16);
        
    case 'uint8'
        imp = IJ.createHyperStack(newname, nY,nX,nC,nZ,nT, 8);
        
    otherwise
        imp = IJ.createHyperStack(newname, nY,nX,nC,nZ,nT, 32);
        
end

% disp(imp);


k = 0;
for t = 1:nT
    imp.setT(t);
    for z = 1:nZ
        imp.setZ(z);
        for c = 1:nC
            imp.setC(c);
            
            k = k + 1;
            ip = st.getProcessor(k);
            
            switch bitdepth
                case 'uint16'
                    imp.setProcessor(ip.convertToShort(0));
                case 'uint8'
                    imp.setProcessor(ip.convertToByte(0));
                otherwise
                    imp.setProcessor(ip);
            end
        end
    end
end

imp.setT(1);
imp.setZ(1);
imp.setC(1);
imp.show(); %NOTE necessary

switch dimorder(3:ndims(I))

    case {'CZT','CZ','C'}
        % as it is
    case {'CTZ','CT'}
        IJ.run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]")
    case {'ZCT','ZC','Z'}
        IJ.run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Channels (c)] frames=[Frames (t)]")
    case {'ZTC','TC','T'}
        IJ.run("Re-order Hyperstack ...", "channels=[Slices (z)] slices=[Frames (t)] frames=[Channels (c)]")
    case {'TCZ','ZT'}
        IJ.run("Re-order Hyperstack ...", "channels=[Frames (t)] slices=[Channels (c)] frames=[Slices (z)]")
    case {'TZC','TZ'}
        IJ.run("Re-order Hyperstack ...", "channels=[Frames (t)] slices=[Slices (z)] frames=[Channels (c)]")
end
imp = IJ.getImage();%NOTE necessary after 'Re-order Hyperstack'

if ~isempty(frameinterval)
    
    fi = imp.getFileInfo();
    fi.frameInterval = frameinterval;
    imp.setFileInfo(fi);
    %TODO Show Info... does not show the frameinterval
end

imp.show();
imp.setDisplayMode(ij.IJ.COLOR) %NOTE this is required to enable the next line
imp.setDisplayMode(ij.IJ.COMPOSITE)
imp.resetDisplayRanges();

IMP.close();



end