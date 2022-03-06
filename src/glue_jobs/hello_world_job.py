import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext


def main():
    args = getResolvedOptions(sys.argv, ["JOB_NAME"])

    sc = SparkContext()
    glueContext = GlueContext(sc)

    spark = glueContext.spark_session

    job = Job(glueContext)
    job.init(args["JOB_NAME"], args)

    df = spark.createDataFrame(
        [
            ["foo", "bar"],
            ["hello", "world"],
        ]
    )

    s3_path = "s3://jszafran-data-lake/curated-layer/hello_world_parquet"

    # glue dynamic dataframe does not support saving parquet in overwrite mode yet
    (df.write.mode("overwrite").format("parquet").save(s3_path))


if __name__ == "__main__":
    main()
