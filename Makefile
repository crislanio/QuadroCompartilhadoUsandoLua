all:
	rm -rf Lousa.love
	zip -r Lousa *
	mv Lousa.zip Lousa.love
	love Lousa.love &
	love Lousa.love &
