"""
Part 1: Extract + Load (the only Python that touches data).
Loads the seaborn Titanic dataset into MySQL table raw_titanic AS IS
(all columns, all nulls) plus load_timestamp and batch_id.
Idempotent: the table is emptied inside the same transaction before the load,
so running the script twice never creates duplicates.
"""
import os
import uuid
from datetime import datetime

import pandas as pd
import seaborn as sns
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

DB_NAME = os.getenv("MYSQL_DATABASE", "titanic_elt")


def _url(database=None):
    return URL.create(
        "mysql+pymysql",
        username=os.getenv("MYSQL_USER", "root"),
        password=os.getenv("MYSQL_PASSWORD", ""),
        host=os.getenv("MYSQL_HOST", "127.0.0.1"),
        port=int(os.getenv("MYSQL_PORT", "3306")),
        database=database,
    )


def get_engine():
    # make sure the database exists, then connect to it
    with create_engine(_url()).begin() as conn:
        conn.execute(text(f"CREATE DATABASE IF NOT EXISTS `{DB_NAME}`"))
    return create_engine(_url(DB_NAME))


# Explicit DDL so the column types are predictable.
# row_id = original row position in the seaborn file (the dataset has no
# passenger id, and we need a key for the duplicate check later).
RAW_DDL = """
CREATE TABLE IF NOT EXISTS raw_titanic (
    row_id         INT          NOT NULL,
    survived       TINYINT,
    pclass         TINYINT,
    sex            VARCHAR(10),
    age            DOUBLE,
    sibsp          TINYINT,
    parch          TINYINT,
    fare           DOUBLE,
    embarked       VARCHAR(5),
    `class`        VARCHAR(10),
    who            VARCHAR(10),
    adult_male     TINYINT(1),
    deck           VARCHAR(5),
    embark_town    VARCHAR(20),
    alive          VARCHAR(5),
    alone          TINYINT(1),
    load_timestamp DATETIME     NOT NULL,
    batch_id       VARCHAR(36)  NOT NULL,
    PRIMARY KEY (row_id)
)
"""


def extract():
    df = sns.load_dataset("titanic")
    # category dtype -> plain object so NaN becomes SQL NULL cleanly
    for col in df.select_dtypes(include="category").columns:
        df[col] = df[col].astype(object)
    return df


def extract_and_load():
    df = extract()
    df.insert(0, "row_id", range(1, len(df) + 1))
    df["load_timestamp"] = datetime.now().replace(microsecond=0)
    df["batch_id"] = str(uuid.uuid4())

    engine = get_engine()
    with engine.begin() as conn:  # one transaction: delete + insert
        conn.execute(text(RAW_DDL))
        conn.execute(text("DELETE FROM raw_titanic"))
        df.to_sql("raw_titanic", conn, if_exists="append", index=False)
    print(f"[LOAD] {len(df)} rows loaded into raw_titanic (batch {df['batch_id'][0]})")
    return engine


if __name__ == "__main__":
    extract_and_load()
