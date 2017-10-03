jekyll build
mv _site blog
scp -r blog noverish@noverish.me:/home/noverish/node-project/noverish/
mv blog _site
