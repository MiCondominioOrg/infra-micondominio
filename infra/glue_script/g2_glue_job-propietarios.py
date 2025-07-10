import sys
import boto3
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext, DynamicFrame
from awsglue.job import Job
from pyspark.sql.functions import col, lit, current_timestamp, to_date

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
route = "csv"
prefixTable = "g2_"
suffixTable = "_tb"

# Diccionario que mapea nombre de archivo y campos tipo date
campos_fecha = {
    "cuotas": ["fecha_emision", "fecha_vencimiento"],
    "edificios": ["fecha_construccion"],
    "facturas": ["fecha_emision"],
    "gastos": ["fecha"],
    "inquilinos": ["fecha_inicio", "fecha_fin"],
    "notificaciones": ["fecha_envio"],
    "pagos": ["fecha_pago"],
    "propietarios": ["fecha_inicio", "fecha_fin"]
}

# Diccionario que mapea nombre de archivo y campos tipo double
campos_double = {
    "cuotas": ["monto"],
    "departamentos": ["area_m2"],
    "facturas": ["monto"],
    "gastos": ["monto"],
    "pagos": ["monto"],
    "presupuestos": ["total_mantenimiento", "total_seguridad", "total_limpieza"]
}

def get_hudi_settings(dbName, targetTableName, targetPath, primary_key):
    # Configuración común de Hudi
    hudi_common_settings = {
        "className": "org.apache.hudi",
        "hoodie.table.name": targetTableName,
        "hoodie.datasource.write.table.type": "COPY_ON_WRITE",
        "hoodie.datasource.write.operation": "upsert",
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

# Main
table = 'propietarios'
primary_key="id_propietario"
sourcePath = "s3://{b}/{r}/{t}.csv".format(b=sourceBucketName, r=route, t=table)
targetTableName = f"{prefixTable}{table}{suffixTable}"
targetPath = "s3://{b}/{t}".format(b=targetBucketName, t=targetTableName)
df = spark.read.option("header", True).csv(sourcePath)
df = df.withColumn("transaction_date_time", current_timestamp())
#print(df.show(5, False))

# Cast a date (formato yyyy-MM-dd)
for campo in campos_fecha.get(table, []):
    if campo in df.columns:
        df = df.withColumn(campo, to_date(col(campo), "yyyy-MM-dd"))

# Cast a double
for campo in campos_double.get(table, []):
    if campo in df.columns:
        df = df.withColumn(campo, col(campo).cast("double"))
        
hudi_settings = get_hudi_settings(
    dbName=dbName,
    targetTableName=targetTableName,
            targetPath=targetPath,
            primary_key=primary_key
        )
df.write.format('hudi').options(**hudi_settings).mode('append').save()
        