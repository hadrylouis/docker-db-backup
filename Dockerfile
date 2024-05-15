FROM tiredofit/db-backup

WORKDIR /app

ADD restore-s3.sh /app/restore-s3.sh

RUN chmod +x /app/restore-s3.sh