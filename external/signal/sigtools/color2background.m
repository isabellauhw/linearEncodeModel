function icon = color2background(icon)
%COLOR2BACKGROUND Function for converting a color to the background color

% Author(s): J. Schickler
% Copyright 1988-2010 The MathWorks, Inc.

bgc = get(0,'DefaultUicontrolBackgroundColor');

icon1 = icon(:,:,1);
icon2 = icon(:,:,2);
icon3 = icon(:,:,3);

icon1(isnan(icon1)) = bgc(1);
icon2(isnan(icon2)) = bgc(2);
icon3(isnan(icon3)) = bgc(3);

icon(:,:,1) = icon1;
icon(:,:,2) = icon2;
icon(:,:,3) = icon3;
