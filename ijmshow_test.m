classdef ijmshow_test < matlab.unittest.TestCase
    %ijmshow_test < matlab.unittest.TestCase
    %
    % clear -regexp ^((?!IJM).)*$;close all;clc;testCase = ijmshow_test;res = testCase.run;disp(res);
    %
    %
    % Written by Kouichi C. Nakamura Ph.D.
    % MRC Brain Network Dynamics Unit
    % University of Oxford
    % kouichi.c.nakamura@gmail.com
    % 03-May-2018 15:31:09
    %
    % See also
    % ijmshow
    % ImageJ
    % net.imagej.matlab.ImageJMATLABCommands
    
    properties
        
    end
    
    methods (Test)
        function test1(testCase)
            % clear -regexp ^((?!IJM).)*$;close all;clc;testCase = ijmshow_test;
            
            % testCase = matlab.uitest.TestCase.forInteractiveUse
                        
            if ispc
                addpath D:\Fiji.app\scripts % you'll need to adapt this line
            else
                addpath '/Applications/Fiji.app/scripts'
            end
            
            ImageJ
            
            eval('import ij.IJ')
            
            
            imp = IJ.openImage("http://imagej.nih.gov/ij/images/Spindly-GFP.zip");
            imp.show();
            
            evalin('base','global Idouble')
            evalin('base','IJM.getDatasetAs(''Idouble'')')
            
            global Idouble
            
            imp.getBitDepth()
            
            size(Idouble)
            class(Idouble)
            
            I_ = uint16(Idouble);
            I16 = permute(I_,[2 1 3:5]);
            
            I8 = uint8(double(I16) * double(intmax('uint8')) / double(intmax('uint16')));
            
            %% verify the interger values for uint16
            
            imp = ijmshow(I16)
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;51]);

            J = zeros(size(I_));
            
            for t = 1:51
                imp.setT(t)
                for z = 1:5
                    imp.setZ(z)
                    for c = 1:2
                        imp.setC(c)
                        ip = imp.getProcessor();
                        J(:,:,c,z,t) = ip.getFloatArray();
                    end
                end
            end
            
            testCase.verifyEqual(double(I16),double(permute(J,[2 1 3 4 5])))
            imp.close()
            
            %% 4D
            % YXCZT
            imp = ijmshow(I16,'YXCZT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;51]);
            imp.close();

            % XYCZT
            imp = ijmshow(I16,'XYCZT')
            testCase.verifyEqual(double(imp.getDimensions), [196;171;2;5;51]);
            imp.close();

            % YXCTZ
            imp = ijmshow(I16,'YXCTZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;51;5]);
            imp.close();

            % YXTCZ
            imp = ijmshow(I16,'YXTCZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;51;2;5]);
            imp.close();
         
            % YXTZC
            imp = ijmshow(I16,'YXTZC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;51;5;2]);
            imp.close(); 
            
            % YXZCT
            imp = ijmshow(I16,'YXZCT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;5;2;51]);
            imp.close();
        
            % YXZTC
            imp = ijmshow(I16,'YXZTC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;5;51;2]);
            imp.close();
                  
            
            %% 4D CZ
            I4cz = squeeze(I16(:,:,:,:,1));

            imp = ijmshow(I4cz)
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;1]);
            imp.close();

            imp = ijmshow(I4cz,'YXCZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;1]);
            imp.close();
            
            imp = ijmshow(I4cz,'YXCZT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;1]);
            imp.close();

            I4zc = permute(I4cz,[1 2 4 3]);

            imp = ijmshow(I4zc,'YXZC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;1]);
            imp.close();
            
            imp = ijmshow(I4zc,'YXZCT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;1]);
            imp.close();           
            
            %% 4D CT
            I4ct = squeeze(I16(:,:,:,3,:));
            
            imp = ijmshow(I4ct,'YXCT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;51]);
            imp.close();    
            
            imp = ijmshow(I4ct,'YXCTZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;51]);
            imp.close(); 
            
            I4tc = permute(I4ct,[1 2 4 3]);
            
            imp = ijmshow(I4tc,'YXTC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;51]);
            imp.close();             
            
            imp = ijmshow(I4tc,'YXTCZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;51]);
            imp.close();   
            
            %% 4D ZT
            I4zt = squeeze(I16(:,:,1,:,:));
            
            imp = ijmshow(I4zt,'YXZT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;51]);
            imp.close();
            
            imp =  ijmshow(I4zt,'YXZTC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;51]);
            imp.close();
            
            I4tz = permute(I4zt,[1 2 4 3]);
            
            imp = ijmshow(I4tz,'YXTZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;51]);
            imp.close();
            
            imp = ijmshow(I4tz,'YXTZC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;51]);
            imp.close();
            
            %% 3D
            I3c = squeeze(I16(:,:,:,3,1));
            
            imp = ijmshow(I3c)
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;1]);
            imp.close();
            
            imp = ijmshow(I3c,'YXC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;1]);
            imp.close();
            
            imp = ijmshow(I3c,'YXCZT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;1]);
            imp.close();
            
            imp = ijmshow(I3c,'YXCTZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;1;1]);
            imp.close();
            
            I3z = squeeze(I16(:,:,1,:,1));
            
            imp = ijmshow(I3z,'YXZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;1]);
            imp.close();            
            
            imp = ijmshow(I3z,'YXZCT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;1]);
            imp.close();
            
            imp = ijmshow(I3z,'YXZTC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;5;1]);
            imp.close();
            
            I3t = squeeze(I16(:,:,1,3,:));
            
            imp = ijmshow(I3t,'YXT')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;1;51]);
            imp.close();  
            
            imp = ijmshow(I3t,'YXTCZ')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;1;51]);
            imp.close();
            
            imp = ijmshow(I3t,'YXTZC')
            testCase.verifyEqual(double(imp.getDimensions), [171;196;1;1;51]);
            imp.close();       
            
            %% verify the interger values for uint8
            
            imp = ijmshow(I8)
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;51]);

            J = zeros(size(I_));
            
            for t = 1:51
                imp.setT(t)
                for z = 1:5
                    imp.setZ(z)
                    for c = 1:2
                        imp.setC(c)
                        ip = imp.getProcessor();
                        J(:,:,c,z,t) = ip.getFloatArray();
                    end
                end
            end
            
            testCase.verifyEqual(double(I8),double(permute(J,[2 1 3 4 5])))
            
            %% verify the interger values for int32 original
            
            I_ = permute(Idouble,[2 1 3 4 5]);
            
            imp = ijmshow(I_)
            testCase.verifyEqual(double(imp.getDimensions), [171;196;2;5;51]);
            
            J = zeros(size(Idouble));
            
            for t = 1:51
                imp.setT(t)
                for z = 1:5
                    imp.setZ(z)
                    for c = 1:2
                        imp.setC(c)
                        ip = imp.getProcessor();
                        J(:,:,c,z,t) = ip.getFloatArray();
                    end
                end
            end
            
            testCase.verifyEqual(I_,double(permute(J,[2 1 3 4 5])))
            
            clear global Idouble

        end
        
    end
    
end
