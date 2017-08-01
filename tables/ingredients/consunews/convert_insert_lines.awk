# syntax: 
# INSERT `Article` ([Id], [Url], [Title], [Sitetable], [Score], [StructuredText], [Language], [Click], [Value], [Discoverdate]) VALUES (1, N'https://svenska.yle.fi/artikel/2017/04/22/haller-du-vatten-i-bryggaren-med-kaffepannan-sluta-genast', N'Häller du vatten i bryggaren med kaffepannan? Sluta genast!', 13, 0, N'<div> 
# </div>', N'sv', 0, 1610, CAST(N'2017-04-22' AS Date))

/^INSERT/ {vi=0; for(i=3;i<=NF;i++){if($(i)=="VALUES"){vi=i;}};
       if(vi==0){printf("ERROR parsing INSERT stmt on line #%d: no VALUES clause: %s\n", NR, $0) > "/dev/stderr"; next; }
       rest=$(vi);
       for(i=vi+1;i<=NF;i++){ rest=rest " " $(i); }; 
       varlist="";
# printf("DBG rest=%s\n",rest);
for(i=3;i<vi;i++){
vin = $(i);
#DBG# printf("DBG varlist=%s vin=%s ", varlist,vin)
# yes, the [ really needs to be double-escaped otherwise gawk complains a lot.
       sub("\\\x5b","`",vin);
       sub("\x5d","`",vin);
       curv=vin;
#DBG# printf("curv=%s\n", curv);
       varlist=varlist " " curv;
}
#DBG#        printf("%s %s __VARLIST__%s __REST__ %s\n", $1, $2, varlist, rest);
       printf("INSERT INTO %s%s %s\n", $2, varlist, rest);
}

{
  if ($1!="INSERT"){ print;}
}
