import sys
import boto3
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext, DynamicFrame
from awsglue.job import Job
from pyspark.sql.functions import col, lit, current_timestamp, to_date, date_format, sum

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME']) 

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
logger = glueContext.get_logger()


# Parametros
dbName = "micondominio_lakehouse_db"
sourceBucketName = "${source_bucket}"
targetBucketName = "${target_bucket}"
prefixTable = "g2_product_"
suffixTable = "_tb"


def get_hudi_settings(dbName, targetTableName, targetPath, primary_key):
    # Configuración común de Hudi
    hudi_common_settings = {
        "className": "org.apache.hudi",
        "hoodie.table.name": targetTableName,
        "hoodie.datasource.write.table.type": "COPY_ON_WRITE",
        "hoodie.datasource.write.operation": "insert_overwrite_table",
        "hoodie.datasource.write.recordkey.field": primary_key,
        "hoodie.datasource.write.precombine.field": "transaction_date_time",
        "path": targetPath,
    }

    # Configuración del índice
    hudi_index_settings = {
        "hoodie.index.type": "BLOOM",
    }

    # Configuración para sincronizar con Glue Catalog
    hudi_hive_sync_settings = {
        "hoodie.parquet.compression.codec": "gzip",
        "hoodie.datasource.hive_sync.enable": "true",
        "hoodie.datasource.hive_sync.database": dbName,
        "hoodie.datasource.hive_sync.table": targetTableName,
        "hoodie.datasource.hive_sync.use_jdbc": "false",
        "hoodie.datasource.hive_sync.mode": "hms",
    }

    # Configuración del cleaner
    hudi_cleaner_options = {
        "hoodie.clean.automatic": "true",
        "hoodie.clean.async": "true",
        "hoodie.cleaner.policy": "KEEP_LATEST_COMMITS",
        "hoodie.cleaner.commits.retained": 10,
        "hoodie-conf hoodie.cleaner.parallelism": "200",
    }

    # Configuración para tablas sin partición
    unpartition_settings = {
        "hoodie.datasource.hive_sync.partition_extractor_class": "org.apache.hudi.hive.NonPartitionedExtractor",
        "hoodie.datasource.write.keygenerator.class": "org.apache.hudi.keygen.NonpartitionedKeyGenerator",
    }

    # Unión de todos los settings
    hudi_final_settings = {
        **hudi_common_settings,
        **hudi_index_settings,
        **hudi_hive_sync_settings,
        **hudi_cleaner_options,
        **unpartition_settings
    }

    return hudi_final_settings

# Inicio Programa
table = "presu_vs_gasto"
targetTableName = f"{prefixTable}{table}{suffixTable}"
targetPath = "s3://{b}/{t}".format(b=targetBucketName, t=targetTableName)

sourcePathGastos = f"s3://{sourceBucketName}/g2_gastos_tb/"
df_gastos = spark.read.format("hudi").load(sourcePathGastos)

sourcePathFacturas = f"s3://{sourceBucketName}/g2_facturas_tb/"
df_facturas = spark.read.format("hudi").load(sourcePathFacturas)

sourcePathPresupuestos = f"s3://{sourceBucketName}/g2_presupuestos_tb/"
df_presupuestos = spark.read.format("hudi").load(sourcePathPresupuestos)

df_pagos_agrup = df_gastos.alias('g')\
    .join(df_facturas.alias('f'), col('g.id_factura') == col('f.id_factura'), 'inner')\
    .withColumn("periodo_gasto", date_format(col("g.fecha"), "yyyy-MM"))\
    .groupBy(col("f.tipo_servicio"), col("periodo_gasto"))\
    .agg(
        sum(col("g.monto")).alias("monto_pagado"),
        sum(col("f.monto") - col("g.monto")).alias("deuda_pendiente")
    )

dfFinal = df_presupuestos.alias('h')\
    .join(df_pagos_agrup.alias('m'), col('h.periodo') == col('m.periodo_gasto'), 'inner')\
    .select('h.id_presupuesto', 'h.periodo', 'h.total_mantenimiento', 'h.total_limpieza', 'h.total_seguridad', 'm.tipo_servicio', 'm.monto_pagado', 'm.deuda_pendiente', 'm.periodo_gasto')

hudi_settings = get_hudi_settings(
    dbName=dbName,
    targetTableName=targetTableName,
    targetPath=targetPath,
    primary_key="periodo,tipo_servicio"
)

dfFinal = dfFinal.withColumn("transaction_date_time", current_timestamp())
#dfFinal.show(10, False)
dfFinal.write.format('hudi').options(**hudi_settings).mode('Overwrite').save()
        