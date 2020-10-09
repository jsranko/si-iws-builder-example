**FREE
/if not defined(HELLOWORLDP)
 /define HELLOWORLDP
/else
 /eof
/endif

//==========================================================================================
// Templates
//==========================================================================================


dcl-s tName char(50) template;
dcl-s tJSON char(1024) template;
dcl-s tHttpStatus int(10) template;
dcl-s tHttpHeaderEntry char(100) template;

/if defined(HELLOWORLD)
  /eof
/endif

//==========================================================================================
// Prototypes
//==========================================================================================

dcl-pr sayHello extproc(*dclcase);
  Name like(tName) const;
  Response like(tJSON);
  ResponseCode like(tHttpStatus);
  ResponseHeaders like(tHttpHeaderEntry) dim(10);
end-pr;
