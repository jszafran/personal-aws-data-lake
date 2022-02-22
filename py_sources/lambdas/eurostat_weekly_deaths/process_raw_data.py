import pathlib

# import awswrangler as wr
import pandas as pd
from dotenv import load_dotenv

path = (
    pathlib.Path(__file__).parent.parent.parent.parent
    / "raw_data/eurostat_weekly_deaths.gz"
)
load_dotenv(pathlib.Path(__file__).parent.parent.parent.parent / ".env")

# split metadata columns and drop redundant one
df = pd.read_csv(path, delimiter="\t")
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

# TODO: implement as lambda
# TODO: remember about saving hash after successful processing
df.to_parquet("parquet")
df.to_csv("just_csv.csv")
