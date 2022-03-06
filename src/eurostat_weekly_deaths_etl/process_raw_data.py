import awswrangler as wr
import pandas as pd
from etl_common import hash_tracker, messages


def transform_eurostat_raw_data(df: pd.DataFrame) -> pd.DataFrame:
    """
    Processes raw Eurostat data. Transformations:
    1. Split first column by comma to extract age, sex, country data
    2. Melt dataframe to have a wide dataframe instead of long one
    3. Split yearweek (i.e. 2020W01) into two separate, integer columns: year & week
    """
    metadata_df = df[df.columns[0]].str.split(",", expand=True).drop(columns=[2])
    metadata_df_columns = ["age", "sex", "country"]
    metadata_df.columns = metadata_df_columns

    df = pd.concat([metadata_df, df.iloc[:, 1:]], axis=1)

    df = df.melt(
        id_vars=metadata_df_columns,
        value_vars=[col for col in df.columns if col not in metadata_df_columns],
        var_name="year_week",
        value_name="weekly_deaths",
    )

    df[["year", "week"]] = df["year_week"].str.split("W", expand=True).astype("int")
    df = df.drop(columns=["year_week"])

    df["weekly_deaths"] = df["weekly_deaths"].apply(
        lambda x: int(x.replace("p", "")) if ":" not in x else None
    )

    # Filter out incorrect week data. ISO8601 year can have 52 or 53 weeks.
    # There's a bug (probably temporary) in eurostat data - week=99
    df = df[df["week"] <= 53]
    return df


def lambda_handler(event, context):
    s3_input_path = event.get("s3_input_path")
    source_hash = event.get("source_hash")

    # read & transform df
    df = wr.s3.read_csv(s3_input_path, delimiter="\t")
    transformed_df = transform_eurostat_raw_data(df)

    # create parquet
    wr.s3.to_parquet(
        transformed_df,
        path="s3://jszafran-data-lake/curated-layer/eurostat-weekly-deaths",
        dataset=True,
        partition_cols=["country"],
        mode="overwrite",
    )

    # update ingested hash & move raw data to archive
    hash_tracker.save_source_hash(source_hash)
    wr.s3.copy_objects(
        paths=[s3_input_path],
        source_path="s3://jszafran-data-lake/raw-layer/eurostat-weekly-deaths/",
        target_path="s3://jszafran-data-lake/raw-layer/eurostat-weekly-deaths/archived/",
    )
    wr.s3.delete_objects(path=[s3_input_path])

    return {
        "message": messages.SOURCE_SUCCESSFULLY_INGESTED,
    }
