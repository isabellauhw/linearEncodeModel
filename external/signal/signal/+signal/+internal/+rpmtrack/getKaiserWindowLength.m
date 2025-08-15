function winLen = getKaiserWindowLength(dataLen)
% Determine the window length based on the data length (See pspectrum doc
% for further information.)
if (dataLen > 16383)
    winLen = ceil(dataLen/128);
elseif (dataLen > 8191)
    winLen = ceil(dataLen/64);
elseif (dataLen > 4095)
    winLen = ceil(dataLen/32);
elseif (dataLen > 2047)
    winLen = ceil(dataLen/16);    
elseif (dataLen > 63)
    winLen = ceil(dataLen/8);    
elseif (dataLen > 1)
    winLen = ceil(dataLen/2);
end

end