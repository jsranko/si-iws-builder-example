**FREE

ctl-opt nomain;
ctl-opt pgminfo(*pcml:*module);

/include qcpylesrc/helloworldp.rpgle

dcl-proc sayHello export;
dcl-pi sayHello like(tJSON) extproc(*dclcase);
  Name like(tName);
end-pi;

  if Name = *blanks;
    return 'Hello there';
  else;
    return 'Hello ' + %trim(name);
  endif;
end-proc;