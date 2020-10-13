**FREE

ctl-opt main(helloworld);
ctl-opt pgminfo(*pcml:*module:*dclcase);

/define HELLOWORLD
/include qcpylesrc/helloworldp.rpgle

dcl-proc HelloWorld ;
dcl-pi HelloWorld;
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
