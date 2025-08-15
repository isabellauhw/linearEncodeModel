function m = getMultiplier(units)
% Get the multiplier for a string units
if isempty(units)
  m = '';
  return;
end

switch units
  case 'y'
    m = '\times 1e-24';
  case 'z'
    m = '\times 1e-21';
  case 'a'
    m = '\times 1e-18';
  case 'f'
    m = '\times 1e-15';    
  case 'p'
    m = '\times 1e-12';
  case 'n'
    m = '\times 1e-9';
  case '\mu'
    m = '\times 1e-6';
  case 'u'
    m = '\times 1e-6';  
  case 'm'
    m = '\times 1e-3';

  case 'k'
    m = '\times 1e3';
  case 'M'
    m = '\times 1e6';
  case 'G'
    m = '\times 1e9';
  case 'T'
    m = '\times 1e12';
  case 'P'
    m = '\times 1e15';
  case 'E'
    m = '\times 1e18';
  case 'Z'
    m = '\times 1e21';
  case 'Y'
    m = '\times 1e24';
end