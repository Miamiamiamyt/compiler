const  a=10;
var    b,c;
procedure p;
procedure q;
  begin
    c:=b+a;
  end;
  begin
     call q;
  end;
procedure m;
  begin
  write(a);
  end;
begin
  read(b);
  while b<>0 do
  begin
    call p;
    call m;
    write(2*c);
    read(b);
  end;
end.



