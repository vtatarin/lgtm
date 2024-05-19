FROM python:3.12-bookworm

ENV FLASK_APP=foo.py
ENV FLASK_RUN_HOST=0.0.0.0

WORKDIR /code

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY foo.py ./

EXPOSE 5000

ENTRYPOINT ["flask", "run"]
