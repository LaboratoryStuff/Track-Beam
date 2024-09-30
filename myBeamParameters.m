classdef myBeamParameters < handle
    % Matlab class to get Beam parameters from an image.
    %
    % Instructions:
    % h = myBeamParameters(ImageData);
    % h.setPixelSize(5.2,'microns')
    
    
    % Author: F.Oliveira
    % Last Update: 20230502
    
    
    properties (Constant, Hidden)       
        % Error Message
        MSGERROR   = 'Error: ';
        MSGWARNING = 'Warning: ';
        CLASSNAME  = 'myBeamParameters.m > ';
    end
    
    properties
        
        % Sensor Specs
        pixelSize;                          % Camera sensor pixel size in micros.
        pixelUnits = 'microns';
        adcResolution;                      % Analogic-to-digital convert resolution in number of bits.
        
        % Image
        
        roiRectangule;                      % Region of interest retangular  [xmin, ymin, width, height] (matlab position convention).
        
        
        % Others
        units = 'pixels';                   % units: 'pixels', 'metres', 'milimetres', 'microns'.
    end
        
    properties (Hidden)
        MAXGREYLEVEL;                       % Maximum intensity value (2^bits - 1).

        pixelSizeValue=0;
        imageSizeHorizontalPixels;        	% Camera sensor horizontal/long size in number of pixels.
        imageSizeVerticalPixels;        	% Camera sensor vertical/short size in number of pixels.
        % Image
        roiXmin;
        roiXmax;
        roiYmin;
        roiYmax;
        
        % Data
        CentroidWidth;
        CentroidHeight;
        
        % Other variables
        initialized = false;                % initialization flag.
        errorDetected = false;              % Flag for detected errors during execution.
    end
    
    properties
        % Image Information
        imageData;
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % M E T H O D S
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        
        % =================================================================
        % FUNCTION myBeamParameters()
        % input: val = image array
        function h = myBeamParameters(val) % Constructor
            
            functionName = 'myBeamParameters()';            % Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.
            
            if nargin == 1
                
                % Check if the image is color or grayscale
                if size(val,3) == 3                     % Color image.
                    h.imageData = double(rgb2gray(val));   	% Convert to grayscale, double format.
                else                                    % Grayscale image.
                    h.imageData = double(val);              % Convert to double format.
                end
                
                if ~h.initialized
                    % Get Image Size
                    imageSize = size(h.imageData);
                    h.imageSizeVerticalPixels = imageSize(1);
                    h.imageSizeHorizontalPixels = imageSize(2);

                    % Define Region of Interest = Full Image
                    h.roiXmin = 1;
                    h.roiXmax = h.imageSizeHorizontalPixels;
                    h.roiYmin = 1;
                    h.roiYmax = h.imageSizeVerticalPixels;
                end
                
            else
                h.errorDetected = true;
                disp([h.MSGWARNING h.CLASSNAME functionName ': image input missing.']);
            end

        end
        
        % =================================================================
        function delete(h) % Destructor
            
            h.initialized = false;
            
        end
        
        % =================================================================
        % FUNCTION: GET IMAGE VERTICAL SIZE
        % Input:
        %   - units (char)(optional) : (default) 'pixels', 'microns', 'milimetres', 'metres'.
        % output:
        %   - image size vertical orientation.
        function val = getImageVerticalSize(h,units)
            
            functionName = 'getImageVerticalSize()';       	% Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.
            
            if nargin == 0
                insideUnits = 'pixels';
                
            elseif nargin == 1
                if ischar(units)
                    switch lower(units)
                        case 'pixels'
                            insideUnits = 'pixels';
                        case {'micronmetres' 'micrometers' 'microns' 'um'}
                            insideUnits = 'microns';
                        case {'milimetres' 'milimeters' 'mili' 'mm'}
                            insideUnits = 'mili';
                        case {'metres' 'meters' 'm'}
                            insideUnits = 'metres';
                        otherwise
                            disp([h.MSGERROR h.CLASSNAME functionName ': units input invalid.']);
                            h.errorDetected = true;
                            return;
                    end
                else
                    invalidInput = true;
                end
            else
                invalidInput = true;
            end
            
            if invalidInput
                h.errorDetected = true;disp([h.MSGERROR h.CLASSNAME functionName ': invalid input.']);
                h.errorDetected = true;
                return;
            end
            
            % Unit Factor
            switch insideUnits
                case 'pixels'
                    unitFactor = 1;
                case 'microns'
                    unitFactor = h.pixelSize;
                case 'mili'
                    unitFactor = h.pixelSize / 1000;
                case 'meters'
                    unitFactor = h.pixelSize / 1000000;
            end
            
            val = h.imageSizeVerticalPixels * unitFactor;
        end
        
        % =================================================================
        % FUNCTION: GET IMAGE HORIZONTAL SIZE
        % Input:
        %   - units (char)(optional) : (default) 'pixels', 'microns', 'milimetres', 'metres'.
        % output:
        %   - image size horizontal orientation.
        function val = getImageHorizontalSize(h,units)
            
            functionName = 'getImageHorizontalSize()';     	% Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.
            
            if nargin == 0
                insideUnits = 'pixels';
                
            elseif nargin == 1
                if ischar(units)
                    switch lower(units)
                        case 'pixels'
                            insideUnits = 'pixels';
                        case {'micronmetres' 'micrometers' 'microns' 'um'}
                            insideUnits = 'microns';
                        case {'milimetres' 'milimeters' 'mili' 'mm'}
                            insideUnits = 'mili';
                        case {'metres' 'meters' 'm'}
                            insideUnits = 'metres';
                        otherwise
                            disp([h.MSGERROR h.CLASSNAME functionName ': units input invalid.']);
                            h.errorDetected = true;
                            return;
                    end
                else
                    invalidInput = true;
                end
            else
                invalidInput = true;
            end
            
            if invalidInput
                h.errorDetected = true;disp([h.MSGERROR h.CLASSNAME functionName ': invalid input.']);
                h.errorDetected = true;
                return;
            end
            
            % Unit Factor
            switch insideUnits
                case 'pixels'
                    unitFactor = 1;
                case 'microns'
                    unitFactor = h.pixelSize;
                case 'mili'
                    unitFactor = h.pixelSize / 1000;
                case 'meters'
                    unitFactor = h.pixelSize / 1000000;
            end
            
            val = h.imageSizeHorizontalPixels * unitFactor;
        end
        
        % =================================================================
        % FUNCTION: SET PIXEL SIZE
        % inputs: 
        %   - pixel size (double).
        %   - units (char): (default) 'microns', 'milimetres', 'metres'.
        function setPixelSize(h,varargin)
            
            functionName = 'setPixelSize()';                % Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.

            if nargin == 2
                val = varargin{1};
                if isnumerical(val)
                    h.pixelSizeValue = double(val);         % Sets the size of a single pixel.
                    insideUnits = 'microns';                % 
                else
                    h.errorDetected = true;
                    disp([h.MSGWARNING h.CLASSNAME functionName ': pixel size has to be a numeric value.']);
                end
                
            elseif nargin == 3
                for i = 1:nargin-1
                    val = varargin{i};
                    if isnumeric(val)
                        insidePixelSize = double(val);                  % Sets the size of a single pixel.
                    elseif ischar(val)
                        switch lower(val)
                            case {'micronmetres' 'micrometers' 'microns' 'um'}
                                insideUnits = 'microns';
                            case {'milimetres' 'milimeters' 'mili' 'mm'}
                                insideUnits = 'mili';
                            case {'metres' 'meters' 'm'}
                                insideUnits = 'metres';
                            otherwise
                                disp([h.MSGERROR h.CLASSNAME functionName ': invalid units input.']);
                                h.errorDetected = true;
                                return;
                        end
                    else
                        disp([h.MSGERROR h.CLASSNAME functionName ': invalid input.']);
                        h.errorDetected = true;
                        return;
                    end
                end
            else
                disp([h.MSGERROR h.CLASSNAME functionName ': input missing.']);
                h.errorDetected = true;
                return;
            end
            
            % Unit Factor
            switch insideUnits
                case 'microns'
                    unitFactor = 1;
                case 'mili'
                    unitFactor = 1000;
                case 'meters'
                    unitFactor = 1000000;
            end
            
            % Pixel Size
            h.pixelSize = insidePixelSize * unitFactor;
            
        end
        
        % =================================================================
        % FUNCTION: GET PIXEL SIZE
        % Input:
        %   - units (char)(optional) : (default) 'microns', 'milimetres', 'metres'.
        % output:
        %   - pixel size.
        function val = getPixelSize(h,units)
            
            functionName = 'getPixelSize()';                % Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.
            invalidInput = false;
            
            if nargin == 1
                insideUnits = 'microns';
                
            elseif nargin == 2
                if ischar(units)
                    switch lower(units)
                        case {'micronmetres' 'micrometers' 'microns' 'um'}
                            insideUnits = 'microns';
                        case {'milimetres' 'milimeters' 'mili' 'mm'}
                            insideUnits = 'mili';
                        case {'metres' 'meters' 'm'}
                            insideUnits = 'metres';
                        otherwise
                            disp([h.MSGERROR h.CLASSNAME functionName ': invalid units input.']);
                            h.errorDetected = true;
                            return;
                    end
                else
                    invalidInput = true;
                end
            else
                invalidInput = true;
            end
            
            if invalidInput
                h.errorDetected = true;disp([h.MSGERROR h.CLASSNAME functionName ': invalid input.']);
                h.errorDetected = true;
                return;
            end
            
            % Unit Factor
            switch insideUnits
                case 'microns'
                    unitFactor = 1;
                case 'mili'
                    unitFactor = 1 / 1000;
                case 'meters'
                    unitFactor = 1 / 1000000;
            end
            
            % Pixel Size
            val = h.pixelSize * unitFactor;
            
        end
        
        % =================================================================
        % FUNCTION: SET REGION OF INTEREST RETANGULAR
        % inputs (all optional; a single or multiple values can be used to redefine existent ROI; default ROI: full image): 
        %   - roi array [xmin, ymin, width, height] (matlab convention) (only vector without key word).
        %   - 'ROI' (numeric) : array [xmin, ymin, width, height] (matlab convention).
        %   - 'xmin' (numeric) : x (horizontal) intial position.
        %   - 'xmax' (numeric) : x (horizontal) final position.
        %   - 'ymin' (numeric) : y (vertical) initial position.
        %   - 'ymax' (numeric) : y (vertical) final position.
        %   - 'width' (numeric) : ROI width (horizontal, x direction), if exceeds image size, xmax = max value.
        %   - 'height' (numeric) : ROI height (vertical, y direction), if exceeds image size, ymax = max value.
        %   - 'xcentre' (numeric) : x position (horizontal direction) for the centre of the ROI.
        %   - 'ycentre' (numeric) : y position (vertital direction) for the centre of the ROI.
        %   - 'units' (char) : (default) 'pixels, 'microns', 'milimetres', 'metres'.
        function setRoiRectangule(h,varargin)
            
            functionName = 'setRoiRetangule()';             % Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.
            
            % Default Values
            xmin = double.empty();
            xmax = double.empty();
            width = double.empty();
            ymin = double.empty();
            ymax = double.empty();
            height = double.empty();
            xcentre = double.empty();
            ycentre = double.empty();
            insideUnits = 'pixels';
            
            % Input
            if nargin == 0                                  % If nargin = 0, roi = full image.
                xmin = 1;
                xmax = h.imageSizeHorizontalPixels;
                ymin = 1;
                ymax = h.imageSizeVerticalPixels;
                
            elseif nargin == 1                            	% If only an input is provided, it has to be a 4 elements vector.
                val = varargin{1};
                if isnumeric(val) && numel(val) == 4 && isvector(val)
                    if size(val,2) == 4
                        roi = double(val);
                    else
                        roi = double(val');
                    end
                    xmin = roi(1);
                    ymin = roi(2);
                    width = roi(3);
                    height = roi(4);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': roi vector invalid.']);
                    h.errorDetected = true;
                end
                
            else                                           % If at least a input with keyword is used.
                for i = 1:nargin
                    val = varargin{i};
                    switch lower(val)
                        case 'roi'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 4 && isvector(val)
                                if size(val,2) == 4
                                    roi = double(val);
                                else
                                    roi = double(val');
                                end
                                xmin = roi(1);
                                ymin = roi(2);
                                width = roi(3);
                                height = roi(4);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': roi vector invalid.']);
                                h.errorDetected = true;
                            end
                        case 'xmin'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                xmin = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': xmin invalid.']);
                                h.errorDetected = true;
                            end
                        case 'xmax'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                xmax = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': xmax invalid.']);
                                h.errorDetected = true;
                            end
                        case 'width'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                width = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': width invalid.']);
                                h.errorDetected = true;
                            end
                        case 'ymin'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                ymin = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': ymin invalid.']);
                                h.errorDetected = true;
                            end
                        case 'ymax'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                ymax = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': ymax invalid.']);
                                h.errorDetected = true;
                            end
                        case 'height'
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                height = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': height invalid.']);
                                h.errorDetected = true;
                            end
                        case {'xcentre' 'xcenter'}
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                xcentre = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': xcentre invalid.']);
                                h.errorDetected = true;
                            end
                        case {'ycentre' 'ycenter'}
                            val = varargin{i+1};
                            if isnumeric(val) && numel(val) == 1
                                ycentre = double(val);
                            else
                                disp([h.MSGERROR h.CLASSNAME functionName ': ycentre invalid.']);
                                h.errorDetected = true;
                            end
                        case 'units'
                            val = varargin{i+1};
                            if ischar(val)
                                switch lower(val)
                                    case 'pixels'
                                        insideUnits = 'pixels';
                                    case {'micronmetres' 'micrometers' 'microns' 'um'}
                                        insideUnits = 'microns';
                                    case {'milimetres' 'milimeters' 'mili' 'mm'}
                                        insideUnits = 'mili';
                                    case {'metres' 'meters' 'm'}
                                        insideUnits = 'metres';
                                    otherwise
                                        disp([h.MSGERROR h.CLASSNAME functionName ': units invalid.']);
                                        h.errorDetected = true;
                                end
                            end
                    end
                end

            end
            
            % If Metric units are used, check if pixel size value exist
            if ~contains(insideUnits,'pixels') && isempty(h.pixelSize)
                h.errorDetected = true;
                disp([h.MSGERROR h.CLASSNAME functionName ': pixel size missing.']);
            end
            
            % If Error Detected
            if h.errorDetected
                return;
            end
            
            % Size Convertion Factor
            switch insideUnits
                case 'pixels'
                    convertionFactor = 1;
                case 'microns'
                    convertionFactor = 1/ h.pixelSize;
                case 'mili'
                    convertionFactor = 1000 / h.pixelSize;
                case 'metres'
                    convertionFactor = 1000000 / h.pixelSize;
            end
            
            % Convert Values
            if ~isempty(xmin)
                xmin = xmin  * convertionFactor;
            end
            if ~isempty(xmax)
                xmax = xmax  * convertionFactor;
            end
            if ~isempty(ymin)
                ymin = ymin  * convertionFactor;
            end
            if ~isempty(ymax)
                ymax = ymax  * convertionFactor;
            end
            if ~isempty(width)
                width = width * convertionFactor;
            end
            if ~isempty(height)
                height = height * convertionFactor;
            end
            if ~isempty(xcentre)
                xcentre = xcentre * convertionFactor;
            end
            if ~isempty(ycentre)
                ycentre = ycentre * convertionFactor;
            end
            
            % ROI Limits
                % Xmin
                if ~isempty(xmin) && round(xmin) >= 1
                    h.roiXmin = uint16(xmin);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': xmin invalid.']);
                    h.errorDetected = true;
                end
            
                % Xmax
                if ~isempty(xmax) && round(xmax) <= h.imageSizeHorizontalPixels
                    h.roiXmax = uint16(xmax);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': xmax invalid.']);
                    h.errorDetected = true;
                end
                
                % Ymin
                if ~isempty(ymin) && round(ymin) >= 1
                    h.roiYmin = uint16(ymin);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': ymin invalid.']);
                    h.errorDetected = true;
                end
            
                % Ymax
                if ~isempty(ymax) && round(ymax) <= h.imageSizeVerticalPixels
                    h.roiYmax = uint16(ymax);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': ymax invalid.']);
                    h.errorDetected = true;
                end
                
                % Width
                if ~isempty(width) && width >= 1 && width <= h.imageSizeHorizontalPixels
                    h.roiXmax = uint16(xmin + width -1);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': width invalid.']);
                    h.errorDetected = true;
                end
                
                % Height
                if ~isempty(height) && height >= 1 && height <= h.imageSizeVerticalPixels
                    h.roiYmax = uint16(ymin + height -1);
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': height invalid.']);
                    h.errorDetected = true;
                end
                
                % XCentre
                if ~isempty(xcentre) && xcentre >= 1 && xcentre <= h.imageSizeHorizontalPixels
                    if ~isempty(width) && width >= 1 && width <= h.imageSizeHorizontalPixels
                        xmin = xcentre - width/2;
                        if xmin >= 1
                            h.roiXmin = xmin;
                        else
                            h.roiXmin = 1;
                            disp([h.MSGWARNING h.CLASSNAME functionName ': Xmin < 0, corrected to 1.']);
                        end
                        
                        xmax = xcentre + width/2;
                        if xmax <= h.imageSizeHorizontalPixels
                            h.roiXmax = xmax;
                        else
                            h.roiXmax = h.imageSizeHorizontalPixels;
                            disp([h.MSGWARNING h.CLASSNAME functionName ': Xmax > sensor width, corrected to max value.']);
                        end
                    else
                        disp([h.MSGERROR h.CLASSNAME functionName ': Width missing.']);
                        h.errorDetected = true;
                        return;
                    end
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': Xcentre invalid.']);
                    h.errorDetected = true;
                    return;
                end
                
                % YCentre
                if ~isempty(ycentre) && ycentre >= 1 && ycentre <= h.imageSizeVerticalPixels
                    if ~isempty(height) && height >= 1 && height <= h.imageSizeVerticalPixels
                        ymin = ycentre - height/2;
                        if ymin >= 1
                            h.roiYmin = xymin;
                        else
                            h.roiYmin = 1;
                            disp([h.MSGWARNING h.CLASSNAME functionName ': Ymin < 0, corrected to 1.']);
                        end
                        
                        ymax = ycentre + height/2;
                        if ymax <= h.imageSizeVerticalPixels
                            h.roiYmax = ymax;
                        else
                            h.roiYmax = h.imageSizeVerticalPixels;
                            disp([h.MSGWARNING h.CLASSNAME functionName ': Ymax > sensor height, corrected to max value.']);
                        end
                    else
                        disp([h.MSGERROR h.CLASSNAME functionName ': Height missing.']);
                        h.errorDetected = true;
                        return;
                    end
                else
                    disp([h.MSGERROR h.CLASSNAME functionName ': Ycentre invalid.']);
                    h.errorDetected = true;
                    return;
                end

        end
        
        % =================================================================
        % FUNCTION: GET REGION OF INTEREST RETANGULAR
        % Input:
        %   - units (char)(optional) : (default) 'pixels', 'microns', 'milimetres', 'metres'.
        % output:
        %   - region of interest : array [xmin, ymin, width, height] (matlab convention).
        function val = getRoiRectangule(h,units)
            
            functionName = 'getRoiRectangule()';            % Function name string to use in messages.
            h.errorDetected = false;                        % Reset errorDetected flag.
            
            if nargin == 0
                insideUnits = 'pixels';
                
            elseif nargin == 1
                if ischar(units)
                    switch lower(units)
                        case 'pixels'
                            insideUnits = 'pixels';
                        case {'micronmetres' 'micrometers' 'microns' 'um'}
                            insideUnits = 'microns';
                        case {'milimetres' 'milimeters' 'mili' 'mm'}
                            insideUnits = 'mili';
                        case {'metres' 'meters' 'm'}
                            insideUnits = 'metres';
                        otherwise
                            disp([h.MSGERROR h.CLASSNAME functionName ': units input invalid.']);
                            h.errorDetected = true;
                            return;
                    end
                else
                    invalidInput = true;
                end
            else
                invalidInput = true;
            end
            
            if invalidInput
                h.errorDetected = true;disp([h.MSGERROR h.CLASSNAME functionName ': invalid input.']);
                h.errorDetected = true;
                return;
            end
            
            % Unit Factor
            switch insideUnits
                case 'pixels'
                    unitFactor = 1;
                case 'microns'
                    unitFactor = h.pixelSize;
                case 'mili'
                    unitFactor = h.pixelSize / 1000;
                case 'meters'
                    unitFactor = h.pixelSize / 1000000;
            end
            
            % Region of Interest
            xMin = h.roiXmin * unitFactor;
            yMin = h.roiYmin * unitFactor;
            width = (h.roiXmax - h.roiXmin + 1) * unitFactor;
            height = (h.roiYmax - h.roiYmin + 1) * unitFactor;
            
            val = [xMin yMin width height];
            
        end
        
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M E T H O D S (Sealed) - INTERFACE IMPLEMENTATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods (Sealed)
        
        % =================================================================
        % FUNCTION: GET CENTROID
        function [CentroidWidth,CentroidHeight] = getCentroid(h,varargin)
            
            functionName = 'getCentreMass()';           % Function name string to use in messages.
            h.errorDetected = false;                    % Reset errorDetected flag.
            
            % Default Values
            thresholdValue = 0.1;                       % Treshold value, default 10%.
            sampleTopBottomValue = 0.001;               % SampleBottom to get base noise, SampleTop to get maximum value, average the min/max 0.1% values.
            insideUnits    = h.units;
            
            % Input Variables
            if nargin > 1
                
                for i = 1:nargin
                    switch lower(varargin{i})
                        case 'method'
                            
                        case {'units' 'unit'}
                            if ~isempty(h.pixelSize)
                                val = varargin{i+1};
                                switch lower(val)
                                    case 'pixels'
                                        insideUnits = 'pixels';
                                    case {'micronmetres' 'micrometers' 'microns' 'um'}
                                        insideUnits = 'microns';
                                    case {'milimetres' 'milimeters' 'mili' 'mm'}
                                        insideUnits = 'mili';
                                    case {'metres' 'meters' 'm'}
                                        insideUnits = 'metres';
                                    otherwise
                                        h.errorDetected = true;
                                        disp([h.MSGERROR h.CLASSNAME functionName ': units input invalid.']);
                                        break;
                                end
                            else
                                val = varargin{i+1};
                                if ~contains(lower(val),'pixels')
                                    h.errorDetected = true;
                                    disp([h.MSGERROR h.CLASSNAME functionName ': pixel size unknown.']);
                                    break;
                                else
                                    insideUnits = 'pixels';
                                end
                            end
                            
                        case {'threshold'}
                            
                            i = i+1;                    % Move counter to input value.
                            val = varargin{i};
                            if isnumeric(val)
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            elseif ischar(val)
                                val = str2double(val);
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            else
                                h.errorDetected = true;
                            end
                            
                            if h.errorDetected
                                disp([h.MSGERROR h.CLASSNAME functionName ': threshold invalid. Value = [0,0.5].']);
                                return                 % End execution of function.
                            end
                            thresholdValue = val;
                        case {'sampletopbottom'}
                            
                            i = i+1;                    % Move counter to input value.
                            val = varargin{i};
                            if isnumeric(val)
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            elseif ischar(val)
                                val = str2double(val);
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            else
                                h.errorDetected = true;
                            end
                            
                            if h.errorDetected
                                disp([h.MSGERROR h.CLASSNAME functionName ': threshold invalid. Value = [0,0.5].']);
                                return                 % End execution of function.
                            end
                            sampleTopBottomValue = val;
                    end
                end
                
            end
            
            % Copy Image
            Data = h.imageData;
            
            % Get Average values for Minimum (~noise) and Maximum (Max intensity)
            nrElements = round(sampleTopBottomValue*numel(Data));       % Get the number of elements.
            topValues = sort(Data(:), 'descend');                       % Convert the matrix into a vector and sort it in descending order.
            averageMax = mean(topValues(1:nrElements));                 % Select the top elements and calculate their average.
            bottomValues = sort(Data(:));                               % Convert the matrix into a vector and sort it in descending order.
            averageMin = mean(bottomValues(1:nrElements));              % Select the top elements and calculate their average.

            % Zeroing Values Below Threshold
            threshold = averageMin + (thresholdValue * (averageMax - averageMin));
            Data(Data < threshold) = 0;
            
            % Calculate Centre of Mass
            x = 1 : h.imageSizeHorizontalPixels;
            y = 1 : h.imageSizeVerticalPixels;
            [X, Y] = meshgrid(x, y);
            meanData = mean(Data(:));
            CentreMassWidth = (mean(mean(Data.* X))) / meanData;
            CentreMassHeight = (mean(mean(Data.* Y))) / meanData;
            
            % Output Values
            switch insideUnits
                case 'pixels'
                    factor = 1;
                case 'microns'
                    factor = h.pixelSize;
                case 'mili'
                    factor = h.pixelSize / 1000;
                case 'meters'
                    factor = h.pixelSize / 1000000;
            end
            CentroidWidth = CentreMassWidth * factor;
            CentroidHeight = CentreMassHeight * factor;
            
        end
               
        % =================================================================
        % FUNCTION: GET BEAM PARAMETERS
        % inputs:
        %   - 'units' - 'pixels', 'microns', 'mili', metres'
        %   - 'threshold%' - decimal percentage for threshold for computing numbers (values below threshold + minimum are ignored).
        %   - 'threshold' - threshold value for computing numbers (values below threshold are ignored).
        %   - 'SampleMaxMin' - decimal percentage of the total pixels in the image Data to compute average minimum value and average maximum value.
        %   - 'BeamBottomTop' - decimal percentage vector of the intensity considered peak bottom and peak top. Default values [0.1,0.9].
        function outputValues = getBeamParameters(h,varargin)
            
            functionName = 'getBeamParameters()';    	% Function name string to use in messages.
            h.errorDetected = false;                    % Reset errorDetected flag.
            
            % Default Values
            thresholdValue = 0.1;                       % Treshold value, default 10%.
            thresholdHardValue = double.empty();
            sampleTopBottomValue = 0.001;               % SampleBottom to get base noise, SampleTop to get maximum value, average the min/max 0.1% values.
            beamBottom = 0.1;
            beamTop = 0.9;
            insideUnits = h.units;
            
            % Input Variables
            if nargin > 1
                
                for i = 1:nargin-1
                    switch lower(varargin{i})
                        case {'units' 'unit'}
                            if ~isempty(h.pixelSize)
                                val = varargin{i+1};
                                switch lower(val)
                                    case 'pixels'
                                        insideUnits = 'pixels';
                                    case {'micronmetres' 'micrometers' 'microns' 'um'}
                                        insideUnits = 'microns';
                                    case {'milimetres' 'milimeters' 'mili' 'mm'}
                                        insideUnits = 'mili';
                                    case {'metres' 'meters' 'm'}
                                        insideUnits = 'metres';
                                    otherwise
                                        h.errorDetected = true;
                                        disp([h.MSGERROR h.CLASSNAME functionName ': units input invalid.']);
                                        break;
                                end
                            else
                                val = varargin{i+1};
                                if ~contains(lower(val),'pixels')
                                    h.errorDetected = true;
                                    disp([h.MSGERROR h.CLASSNAME functionName ': pixel size unknown.']);
                                    break;
                                else
                                    insideUnits = 'pixels';
                                end
                            end
                            
                        case {'threshold%'}
                            
                            i = i+1;                    % Move counter to input value.
                            val = varargin{i};
                            if isnumeric(val)
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            elseif ischar(val)
                                val = str2double(val);
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            else
                                h.errorDetected = true;
                            end
                            
                            if h.errorDetected
                                disp([h.MSGERROR h.CLASSNAME functionName ': threshold invalid. Value = [0,0.5].']);
                                return                 % End execution of function.
                            end
                            thresholdValue = val;
                            
                        case {'threshold'}
                            
                            i = i+1;                    % Move counter to input value.
                            val = varargin{i};
                            if isnumeric(val)
                                if val < 0
                                    h.errorDetected = true;
                                end
                            elseif ischar(val)
                                val = str2double(val);
                                if val < 0
                                    h.errorDetected = true;
                                end
                            else
                                h.errorDetected = true;
                            end
                            
                            if h.errorDetected
                                disp([h.MSGERROR h.CLASSNAME functionName ': threshold invalid. Value >= 0.']);
                                return                 % End execution of function.
                            end
                            thresholdHardValue = val;
                        case {'samplemaxmin'}
                            
                            i = i+1;                    % Move counter to input value.
                            val = varargin{i};
                            if isnumeric(val)
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            elseif ischar(val)
                                val = str2double(val);
                                if val < 0 && val > .5
                                    h.errorDetected = true;
                                end
                            else
                                h.errorDetected = true;
                            end
                            
                            if h.errorDetected
                                disp([h.MSGERROR h.CLASSNAME functionName ': threshold invalid. Value = [0,0.5].']);
                                return                 % End execution of function.
                            end
                            sampleTopBottomValue = val;
                            
                        case {'beambottomtop'}
                            i = i+1;                    % Move counter to input value.
                            val = varargin{i};
                            
                            if isnumeric(val) && numel(val) == 2 && isvector(val)
                                if val(1) >= 0 && val(1) <= 0.5
                                    beamBottom = val(1);
                                else
                                    disp([h.MSGERROR h.CLASSNAME functionName ': beam bottom has to be [0,0.5].']);
                                    h.errorDetected = true;
                                    return;
                                end
                                if val(2) >= 0.5 && val(2) <= 1
                                    beamTop = val(2);
                                else
                                    disp([h.MSGERROR h.CLASSNAME functionName ': beam top has to be [0.5,1].']);
                                    h.errorDetected = true;
                                    return;
                                end
                            else
                                h.errorDetected = true;
                                disp([h.MSGERROR h.CLASSNAME functionName ': beam bottom top vector invalid.']);
                                return;
                            end
                    end
                end
                
            end
            
            % Unit Factor
            switch insideUnits
                case 'pixels'
                    unitFactor = 1;
                case 'microns'
                    unitFactor = h.pixelSize;
                case 'mili'
                    unitFactor = h.pixelSize / 1000;
                case 'meters'
                    unitFactor = h.pixelSize / 1000000;
            end
            
            % Copy Image
            Data = h.imageData;
            
            % Get Average values for Minimum (~noise) and Maximum (Max intensity)
            nrElements = round(sampleTopBottomValue*numel(Data));       % Get the number of elements.
            maxValues = sort(Data(:), 'descend');                       % Convert the matrix into a vector and sort it in descending order.
            maxIntensity = mean(maxValues(1:nrElements));               % Select the top elements and calculate their average.
            minValues = sort(Data(:));                               % Convert the matrix into a vector and sort it in descending order.
            minIntensity = mean(minValues(1:nrElements));       	% Select the top elements and calculate their average.
            
            % Centroid            - It has to be here before manipulating Data
            if isempty(h.CentroidWidth)
                [h.CentroidWidth,h.CentroidHeight] = h.getCentroid();%'Units', insideUnits,...
%                     'Threshold',thresholdValue,'sampletopbottom',sampleTopBottomValue);
            end
            outputValues.CentroidWidth = h.CentroidWidth * unitFactor;
            outputValues.CentroidHeight = h.CentroidHeight * unitFactor;
                
            % Zeroing Values Below Threshold
            if isempty(thresholdHardValue)
                threshold = minIntensity + (thresholdValue * (maxIntensity - minIntensity));
            else
                threshold = thresholdHardValue;
            end
            Data(Data < threshold) = 0;
            
            % Compute Beam Parameters
                % Beam Intensity Bottom Top Levels
                intensityBeamBottom = minIntensity + (beamBottom * (maxIntensity - minIntensity));
                intensityBeamTop = minIntensity + (beamTop * (maxIntensity - minIntensity));
                intensityFWHM = minIntensity + (0.5 * (maxIntensity - minIntensity));
                
                % Count Pixels and Sum Intensities
                countNrPixelsBottom = 0;
                countNrPixelsCentre = 0;
                countNrPixelsTop = 0;
                countNrPixelsFWHMTop = 0;
                countNrPixelsFWHMBottom = 0;
                
                sumIntensityBottom = 0;
                sumIntensityCentre = 0;
                sumIntensityTop = 0;
                sumIntensityFWHMTop = 0;
                sumIntensityFWHMBottom = 0;
                
                for i = h.roiXmin:h.roiXmax
                    for j = h.roiYmin:h.roiYmax
                        val = Data(j,i);
                        if val > threshold && val <= intensityBeamBottom                % Pixel count and Intensity sum of lower intensity region of the beam.
                            countNrPixelsBottom = countNrPixelsBottom + 1;
                            sumIntensityBottom = sumIntensityBottom + val;
                        elseif val >= intensityBeamTop                                  % Pixel count and Intensity sum of higher intensity region of the beam.
                            countNrPixelsTop= countNrPixelsTop + 1;
                            sumIntensityTop = sumIntensityTop + val;
                        elseif val > intensityBeamBottom && val < intensityBeamTop      % Pixel count and Intensity sum between the lower and higher intensity region of the beam.
                            countNrPixelsCentre= countNrPixelsCentre + 1;
                            sumIntensityCentre = sumIntensityCentre + val;
                        end
                        if val >= intensityFWHM
                            countNrPixelsFWHMTop = countNrPixelsFWHMTop + 1;
                            sumIntensityFWHMTop = sumIntensityFWHMTop + val;
                        end
                    end
                end

                countNrPixels = countNrPixelsBottom + countNrPixelsCentre + countNrPixelsTop;
                countNrPixelsFWHMBottom = countNrPixels - countNrPixelsFWHMTop;
                sumIntensity = sumIntensityBottom + sumIntensityCentre + sumIntensityTop;
                sumIntensityFWHMBottom = sumIntensity - sumIntensityFWHMTop;

                % Intensity
                outputValues.IntensityTotal = sumIntensity / countNrPixels;
                outputValues.IntensityBottom = sumIntensityBottom / countNrPixelsBottom;
                outputValues.IntensityCentre = sumIntensityCentre / countNrPixelsCentre;
                outputValues.IntensityTop = sumIntensityTop / countNrPixelsTop;

                % Area
                outputValues.Area = countNrPixels * unitFactor^2;

                % Average Diameter
                beamDiameterAverage = 2 * sqrt(countNrPixels)/pi;
                outputValues.Diameter = beamDiameterAverage * unitFactor;

                % Width Bottom
                i = uint16(h.CentroidHeight);
                position1 = 0;
                position2 = 0;
                for j = h.roiXmin:h.roiXmax         % Detect beam peak rise from left to right.
                    val = Data(i,j);
                    if val > 0
                        position1 = j;
                        break;
                    end
                end
                for j = h.roiXmax:-1:h.roiXmin      % Detect beam peak rise from right to left.
                    val = Data(i,j);
                    if val > 0
                        position2 = j;
                        break;
                    end
                end
                widthPixels = position2 - position1;
                outputValues.BottomWidthCentroid = widthPixels * unitFactor;

                % Width FWHM
                i = uint16(h.CentroidHeight);
                position1 = 0;
                position2 = 0;
                halfMaximum = sumIntensityTop / countNrPixelsTop / 2;
                for j = h.roiXmin:h.roiXmax
                    val = Data(i,j);
                    if val > halfMaximum
                        position1 = j;
                        break;
                    end
                end
                for j = h.roiXmax:-1:h.roiXmin
                    val = Data(i,j);
                    if val > halfMaximum
                        position2 = j;
                        break;
                    end
                end
                widthPixels = position2 - position1;
                outputValues.FWHMWidthCentroid = widthPixels * unitFactor;

                % Height Bottom
                j = uint16(h.CentroidWidth);
                position1 = 0;
                position2 = 0;
                for i = h.roiYmin:h.roiYmax
                    val = Data(i,j);
                    if val > 0
                        position1 = i;
                        break;
                    end
                end
                for i = h.roiYmax:-1:h.roiYmin
                    val = Data(i,j);
                    if val > 0
                        position2 = i;
                        break;
                    end
                end
                heightPixels = position2 - position1;
                outputValues.BottomHeightCentroid = heightPixels * unitFactor;

                % Height FWHM
                j = uint16(h.CentroidWidth);
                position1 = 0;
                position2 = 0;
                for i = h.roiYmin:h.roiYmax
                    val = Data(i,j);
                    if val > halfMaximum
                        position1 = i;
                        break;
                    end
                end
                for i = h.roiYmax:-1:h.roiYmin
                    val = Data(i,j);
                    if val > halfMaximum
                        position2 = i;
                        break;
                    end
                end
                heightPixels = position2 - position1;
                outputValues.FWHMHeightCentroid = heightPixels * unitFactor;

                % Top Hat profile
                AverageTopIntensity = sumIntensityTop / countNrPixelsTop;
                TopHatCirculeIntensity = countNrPixels * AverageTopIntensity;
                outputValues.TopHatLike = sumIntensity / TopHatCirculeIntensity;
                
                % Excentricity
%                 outputValues.HeightWidthRatioBottom = outputValues.centreHeightBottomPixels / outputValues.centreWidthBottomPixels;
%                 outputValues.HeightWidthRatioFWHM = outputValues.centreHeightFWHMPixels / outputValues.centreWidthFWHMPixels;

        end
        
    end
    
end