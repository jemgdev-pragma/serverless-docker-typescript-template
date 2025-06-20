docker build -t template-image .
docker run --env-file .env -p 3000:3000 template-image