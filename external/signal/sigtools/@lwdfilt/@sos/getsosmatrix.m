function sosMatrix = getsosmatrix(this,embedScaleValues)
%GETSOSMATRIX

%   Copyright 2012 The MathWorks, Inc.

if nargin == 1
  embedScaleValues = true;
end

sosMatrix = get(this, 'sosMatrix');
if embedScaleValues
  scales    = get(this, 'ScaleValues');  
  sosMatrix = embedsosscalevalues(sosMatrix, scales);
end
if size(sosMatrix,1) == 1
  %Analysis only supports SOS matrices with 2 or more sections
  sosMatrix = [sosMatrix ;  [1 0 0 1 0 0]];
end

%--------------------------------------------------------------------------
function sos = embedsosscalevalues(sos,g)

if size(sos,2) ~= 6
  error(message('signal:lwdfilt:sos:getsosmatrix:InvalidSOSMatrix'));
end
numSecs = size(sos,1);
if length(g)~= 1 && (length(g) > numSecs+1 || length(g) < numSecs)
  error(message('signal:lwdfilt:sos:getsosmatrix:InvalidScaleValues'));
end

if length(g) == 1
  sos(1,1:3) = sos(1,1:3).*g;
else
  if (length(g) == numSecs+1)
    lastGain = 1;
    if g(end) ~= 1
      % Spread the last non-unity gain across all sections
      lastGain = g(end)^(1/numSecs);
    end
    g = g(1:end-1)*lastGain;
  end
  g = g(:,[1 1 1]);
  sos(:,1:3) = sos(:,1:3).*g;
end