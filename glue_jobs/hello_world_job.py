import sys

from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame


def main():
    args = getResolvedOptions(sys.argv, ['JOB_NAME'])

    sc = SparkContext()
    glueContext = GlueContext(sc)

    spark = glueContext.spark_session

    job = Job(glueContext)
    job.init(args['JOB_NAME'], args)

    df = spark.createDataFrame(
        [
            ["foo", "bar"],
            ["hello", "world"],
        ]
    )

    dframe = DynamicFrame.fromDF(df, glueContext, "hello_world_frame")

    glueContext.write_dynamic_frame_from_options(
        frame=dframe,
        connection_type="s3",
        connection_options={"path": "s3://jszafran-data-lake/curated-layer/hello_world_parquet"},
        format="parquet",
    )


if __name__ == "__main__":
    main()
