import datetime

import awswrangler as wr
import pandas as pd
from etl_common import hash_tracker, messages


def dbgprint(text):
    """
    Debugging helper to understand what stage takes the most time
    """
    # TODO: implement some kind of logging and make it a lambda layer
    print(f"{datetime.datetime.utcnow().isoformat()}: {text}")


def transform_eurostat_raw_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Processes raw Eurostat data. Transformations:
    1. Split first column by comma to extract age, sex, country data
    2. Melt dataframe to have a wide dataframe instead of long one
    3. Split yearweek (i.e. 2020W01) into two separate, integer columns: year & week
    """
    dbgprint("Start transforming data")
    metadata_df = df[df.columns[0]].str.split(",", expand=True).drop(columns=[2])
    metadata_df_columns = ["age", "sex", "country"]
    metadata_df.columns = metadata_df_columns
    dbgprint("Finished splitting metadata columns")
    dbgprint("Merge back dfs")
    df = pd.concat([metadata_df, df.iloc[:, 1:]], axis=1)
    dbgprint("Start melting")
    df = df.melt(
        id_vars=metadata_df_columns,
        value_vars=[col for col in df.columns if col not in metadata_df_columns],
        var_name="year_week",
        value_name="weekly_deaths",
    )
    dbgprint("Process year week")
    df[["year", "week"]] = df["year_week"].str.split("W", expand=True).astype("int")
    df = df.drop(columns=["year_week"])
    dbgprint("Extract deaths")
    df["weekly_deaths"] = df["weekly_deaths"].apply(
        lambda x: int(x.replace("p", "")) if ":" not in x else None
    )
    dbgprint("End")
    return df


def lambda_handler(event, context):
    s3_input_path = event.get("s3_input_path")
    source_hash = event.get("source_hash")

    dbgprint("Starting processing")
    # read & transform df
    dbgprint("Reading df with awswrangler")
    df = wr.s3.read_csv(s3_input_path, delimiter="\t")
    dbgprint("Read df. Start processing.")
    transformed_df = transform_eurostat_raw_data(df)
    dbgprint("Transformed raw data")

    dbgprint("Creating parquet")
    # create parquet
    wr.s3.to_parquet(
        transformed_df,
        path="s3://jszafran-data-lake/curated-layer/eurostat",
        dataset=True,
        partition_cols=["country", "year"],
    )
    dbgprint("Saved parquet")

    # update ingested hash & move raw data to archive
    dbgprint("Updating hash")
    hash_tracker.save_source_hash(source_hash)
    dbgprint("Updated hash")
    dbgprint("Moving file to archive")
    wr.s3.copy_objects(
        paths=[s3_input_path],
        source_path=s3_input_path.split("s3://jszafran-data-lake/raw-layer/eurostat/"),
        target_path="s3://jszafran-data-lake/raw-layer/eurostat/archived/",
    )
    dbgprint("Finishing func")

    return {
        "message": messages.SOURCE_SUCCESSFULLY_INGESTED,
    }
