**FREE

ctl-opt nomain;
ctl-opt pgminfo(*pcml:*module:*dclcase);

/define HELLOWORLD
/include qcpylesrc/helloworldp.rpgle

dcl-proc sayHello export;
dcl-pi sayHello extproc(*dclcase);
  Name like(tName) const;
  Response like(tJSON);
end-pi;

  if Name = *blanks;
    Response = 'Hello there';
  else;
    Response = 'Hello ' + %trim(name);
  endif;
  return;
end-proc;
