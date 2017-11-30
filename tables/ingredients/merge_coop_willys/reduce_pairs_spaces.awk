{
  bingo = 0;
  w1 = $1;
  w2 = $2;
  l = length (w1);
  j = 1;
  for (i = 1; i <= l; i++)
    {
      c1 = substr (w1, i, 1);
      c2 = substr (w2, j, 1);
#DBG#      printf ("i=%d j=%d c1=<%s> c2=<%s>\n", i, j, c1, c2);
      if (c1 != c2)
	{
#DBG#	  printf (" BREAK at i=%d j=%d c1=%s c2=%s\n", i, j, c1, c2);
	  if ((c2 != " ")&&(c2 != ""))
	    {
#DBG#	      printf (" ERROR c2=<%s> but expect <%s>\n", c2, " ");
	      break;
	    };
	  j++;
	};
      j++;
    };
  if ((j == i + 1) && (i >= l))
    {
      bingo = 1;
    };
  print bingo;
}
