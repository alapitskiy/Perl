#!/bin/sh
#fix empty

echo files "$@" 1>&2

sed -b -i '
/\/\/ TODO: Auto-generated Javadoc/d;
# s/\/\*\* The\( Constant\)\? log\. \*\//\/\*\* The logger. \*\//
/\(^\|\s\)\(class\|interface\|enum\)\s/{
 # /^\s*\*/!{
 /\*/!{
  N;
  s/\n\s*$//;
  b justread;
 }
}
b end;
:justread
${n;q;}
n
b justread
:end
' "$@"

perl -i.fxtmpk -we "require q(ALAP/Fitech/javadoc/PreProcess.pl); ALAP::Fitech::javadoc::PreProcess::main(\&ALAP::Fitech::javadoc::PreProcess::revertComment, \&ALAP::Fitech::javadoc::PreProcess::postProcessFields);" "$@"

for file in "$@"; do
  rm -fr "${file}.fxtmpk"
done

<<'EOF'
find . -follow -name '.svn' -prune -o -name '*.java' -print |
 xargs  "D:/link/Dropbox/portable/project/breakdown/bash/perl/ALAP/Fitech/javadoc/finish.sh"


find . -follow -name '.svn' -prune -o -name '*.java' -print |
  xargs --replace=ID "D:/link/Dropbox/portable/project/breakdown/bash/perl/ALAP/Fitech/javadoc/finish.sh" ID 2>&1 | tee finish.out

?time
EOF
