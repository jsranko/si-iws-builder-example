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

/if defined(HELLOWORLD)
  /eof
/endif

//==========================================================================================
// Prototypes
//==========================================================================================

dcl-pr sayHello extproc(*dclcase);
  Name like(tName) const;
  Response like(tJSON);
end-pr;
