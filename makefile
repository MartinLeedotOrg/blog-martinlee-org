build:
	cd ./blog && hugo -t hugo_theme_pickles

deploy:
	aws s3 sync ./blog/public/ s3://blog-martinlee-org/

dev:
	cd ./blog && hugo server -t hugo_theme_pickles -w -D