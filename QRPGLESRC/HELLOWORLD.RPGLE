**FREE

ctl-opt nomain;
ctl-opt pgminfo(*pcml:*module:*dclcase);

/define HELLOWORLD
/include qcpylesrc/helloworldp.rpgle

dcl-proc sayHello export;
dcl-pi sayHello extproc(*dclcase);
  Name like(tName) const;
  Response like(tJSON);
  ResponseCode like(tHttpStatus);
  ResponseHeaders like(tHttpHeaderEntry) dim(10);
end-pi;

  if Name = *blanks;
    Response = 'Hello there';
  else;
    Response = 'Hello ' + %trim(name);
  endif;
  return;
end-proc;
