function addsosprops(this)
  % Add the properties 'SOSScaleNorm' and 'SOSScaleOpts'
  % Set the get/set access level depending on the DST license.
  defaultSOSScaleNorm = '';
  defaultSOSScaleOpts = fdopts.sosscaling;

  % Add SOSScaleNorm and define access 
  addprop(this,'SOSScaleNorm');
  this.SOSScaleNorm = defaultSOSScaleNorm ;
  mp = findprop(this,'SOSScaleNorm');
  if ~isfdtbxinstalled
    mp.GetAccess = 'protected';
    mp.SetAccess = 'protected';
    mp.NonCopyable = 0;
  else
    mp.GetAccess = 'public';
    mp.SetAccess = 'public';
    mp.NonCopyable = 0;
  end

  % Add SOSScaleOpts and define access 
  addprop(this,'SOSScaleOpts');
  this.SOSScaleOpts = defaultSOSScaleOpts ;
  mp = findprop(this,'SOSScaleOpts');
  if ~isfdtbxinstalled
    mp.GetAccess = 'protected';
    mp.SetAccess = 'protected';
    mp.NonCopyable = 0;
  else
    mp.GetAccess = 'public';
    mp.SetAccess = 'public';
    mp.NonCopyable = 0;
  end

end