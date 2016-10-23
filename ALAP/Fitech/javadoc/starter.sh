#!/bin/sh
#
# TODO:
# 1. Expand abbreviations in the fields.
# 2. If an abbreviation consists only of consonants, expand it depending on the type.
#
# To comment out sources you should do the following:
#
# 0. Create db links on multiple folders (the script at the end of this file) so that it will be possible to work with it in one go.
# 1. Execute the starter.sh on each file by the "find . ..." string from the bottom of the file. (cygwin and perl 15.12 is needed)
# 2. Open your java sources in eclipse, or refresh (it is necessary!) them if they are already open.
#    Click by the right mouse button on the necessary packages in the Package Explorer and choose
#         JAutodoc -> add javadoc for Members.
#      note: it is better to choose the maximum number of packages and do excessive generation, else it can generate @see tags instead of {@inheritDoc}.
#    Save all by "Ctrl+Shift+S"
# 3. Execute the finish.sh on each file by the "find . ..." string from the bottom of the file.
#
# Note: you also need JAutodoc plugin for eclipse. You can load preferences from the preferences.epf file.

echo files "$@" 1>&2

sed -b -i '
:start
/^\s*\*.*\bTBD\b.*/d;
# Remove strings with one descr. parameter
/^\s*\*.*\(@param\|@throws\|@exception\)\s\+\w\+\s*$/ {
  N;
  /.*\n\s*\*\s*\w\+/{
    # Remove TDBs
    /\bTBD\b/d;
    n;
  }
  s/^.*\n//;
  b start;
}' "$@"

perl -i.fxtmpk -we "require q(ALAP/Fitech/javadoc/PreProcess.pl); ALAP::Fitech::javadoc::PreProcess::main();" "$@"

for file in "$@"; do
  rm -fr "${file}.fxtmpk"
done

<<'EOF'
find . -follow -name '.svn' -prune -o -name '*.java' -print |
 xargs  "D:/link/Dropbox/portable/project/breakdown/bash/perl/ALAP/Fitech/javadoc/starter.sh"
1

find . -follow -name '.svn' -prune -o -name '*.java' -print |
 xargs --replace=ID "D:/link/Dropbox/portable/project/breakdown/bash/perl/ALAP/Fitech/javadoc/starter.sh" ID 2>&1 | tee out.out

?time

perl -wlE '
my @pr = qw(
oas10g-mk
wls7-mk
wls8-mk
wls9-mk
);
for my $pr (@pr) {
 say qq(`junction $pr "E:/fproject/svn/x-tier/src/java/$pr"`);
 # say qq(`mklink /J $pr "E:/fproject/svn/x-tier/src/java/$pr"`);
}
'

EOF
