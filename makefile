build:
	cd ./blog && hugo -t hugo_theme_pickles

deploy: build
	aws s3 sync ./blog/public/ s3://blog-martinlee-org/

dev:
	cd ./blog && hugo server -t hugo_theme_pickles -w -D

invalid:
	aws cloudfront create-invalidation --distribution-id E734L0F2WYJ6 --paths /posts/* / /index.html /images/*
