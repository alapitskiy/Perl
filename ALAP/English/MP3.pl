#copy /b Eni*mp3 join
perl -E 'use MP3::Splitter;
mp3split(q(w100.mp3), {verbose => 1, lax => 300},
  ["0", 300,],
([">0", 300,])x100,
[">0", "=INF"],
);'
